import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';

class ProgrammeBuilderController extends AsyncNotifier<ProgrammeBuilderState> {
  ProgrammeBuilderController(this.mode, this.programmeId);

  final ProgrammeBuilderMode mode;
  final String? programmeId;

  @override
  Future<ProgrammeBuilderState> build() async {
    final loadUseCase = ref.read(
      AppProviders.loadProgrammeBuilderDraftUseCaseProvider,
    );

    try {
      ProgrammeBuilderDraft draft;
      if (mode == ProgrammeBuilderMode.create) {
        draft = await loadUseCase.createEmptyDraft();
      } else if (mode == ProgrammeBuilderMode.duplicate) {
        draft = await loadUseCase.loadDuplicate(programmeId!);
      } else {
        draft = await loadUseCase.loadForEdit(programmeId!);
      }

      return ProgrammeBuilderState(
        mode: mode,
        phase: ProgrammeBuilderPhase.editing,
        draft: draft,
        validationErrors: [],
        isDirty: mode != ProgrammeBuilderMode.create,
        programmeId: programmeId,
      );
    } catch (e) {
      return ProgrammeBuilderState(
        mode: mode,
        phase: ProgrammeBuilderPhase.failure,
        draft: ProgrammeBuilderDraft(
          id: '',
          name: '',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
        ),
        validationErrors: [],
        isDirty: false,
        programmeId: programmeId,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.programmeLoadFailed,
      );
    }
  }

  Future<void> updateName(String value) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(name: value),
        isDirty: true,
      ),
    );
  }

  Future<void> addWeek() async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    final weekNumber = weeks.length + 1;
    weeks.add(
      ProgrammeBuilderWeekDraft(
        id: _newId(),
        weekNumber: weekNumber,
        slots: [],
      ),
    );
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
      ),
    );
  }

  Future<void> removeWeek(int weekIndex) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex >= weeks.length) return;
    weeks.removeAt(weekIndex);
    final reindexed = weeks.asMap().entries.map((entry) {
      return entry.value.copyWith(weekNumber: entry.key + 1);
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: reindexed),
        isDirty: true,
      ),
    );
  }

  Future<void> duplicateWeek(int weekIndex) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex >= weeks.length) return;
    final source = weeks[weekIndex];
    weeks.insert(
      weekIndex + 1,
      ProgrammeBuilderWeekDraft(
        id: _newId(),
        weekNumber: weekIndex + 2,
        slots:
            source.slots
                ?.map((s) => s.copyWith(slotIndex: s.slotIndex))
                .toList() ??
            [],
        name: source.name,
        notes: source.notes,
      ),
    );
    final reindexed = weeks.asMap().entries.map((entry) {
      return entry.value.copyWith(weekNumber: entry.key + 1);
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: reindexed),
        isDirty: true,
      ),
    );
  }

  Future<void> addSlot({
    required int weekIndex,
    required int scheduledDayIndex,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = List<ProgrammeBuilderWeekDraft>.from(
      current.draft.weeks ?? [],
    );
    if (weekIndex >= weeks.length) return;
    final week = weeks[weekIndex];
    final slots = List<ProgrammeBuilderWorkoutSlotDraft>.from(week.slots ?? []);
    slots.add(
      ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: slots.length,
        scheduledDayIndex: scheduledDayIndex,
      ),
    );
    weeks[weekIndex] = week.copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
      ),
    );
  }

  Future<void> removeSlot(int weekIndex, int slotIndex) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex >= weeks.length) return;
    final week = weeks[weekIndex];
    final slots = week.slots != null
        ? List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots!)
        : <ProgrammeBuilderWorkoutSlotDraft>[];
    slots.removeAt(slotIndex);
    final reindexed = slots.asMap().entries.map((entry) {
      return entry.value.copyWith(slotIndex: entry.key);
    }).toList();
    weeks[weekIndex] = week.copyWith(slots: reindexed);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
      ),
    );
  }

  Future<void> assignTemplateToSlot({
    required int weekIndex,
    required int slotIndex,
    required ProgrammeBuilderTemplateDraft template,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex >= weeks.length) return;
    final week = weeks[weekIndex];
    final slots = week.slots != null
        ? List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots!)
        : <ProgrammeBuilderWorkoutSlotDraft>[];
    if (slotIndex >= slots.length) return;
    slots[slotIndex] = slots[slotIndex].copyWith(template: template);
    weeks[weekIndex] = week.copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
      ),
    );
  }

  Future<void> saveProgramme() async {
    final current = state.asData?.value;
    if (current == null) return;

    final validator = ref.read(AppProviders.programmeBuilderValidatorProvider);
    final errors = validator.validate(current.draft);

    if (errors.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          phase: ProgrammeBuilderPhase.editing,
          validationErrors: errors,
        ),
      );
      return;
    }

    state = AsyncData(current.copyWith(phase: ProgrammeBuilderPhase.saving));

    try {
      final saveUseCase = ref.read(
        AppProviders.saveProgrammeBuilderDraftUseCaseProvider,
      );
      final savedId = await saveUseCase.save(current.draft);
      state = AsyncData(
        current.copyWith(
          phase: ProgrammeBuilderPhase.editing,
          programmeId: savedId,
          isDirty: false,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          phase: ProgrammeBuilderPhase.failure,
          errorCode: AppErrorCodes.programmeSaveFailed,
          errorMessage: AppStrings.programmeSaveFailed,
        ),
      );
    }
  }

  Future<void> discardChanges() async {
    final current = state.asData?.value;
    if (current == null) return;
    final loadUseCase = ref.read(
      AppProviders.loadProgrammeBuilderDraftUseCaseProvider,
    );
    if (mode == ProgrammeBuilderMode.create) {
      final draft = await loadUseCase.createEmptyDraft();
      state = AsyncData(
        current.copyWith(draft: draft, isDirty: false, validationErrors: []),
      );
    } else if (programmeId != null) {
      final draft = await loadUseCase.loadForEdit(programmeId!);
      state = AsyncData(
        current.copyWith(draft: draft, isDirty: false, validationErrors: []),
      );
    }
  }

  void clearValidationErrors() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(validationErrors: []));
  }

  String _newId() => const Uuid().v4();
}
