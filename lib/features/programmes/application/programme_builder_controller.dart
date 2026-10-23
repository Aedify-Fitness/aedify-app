import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/application/workout_draft_to_programme_template_converter.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';

class ProgrammeBuilderController extends AsyncNotifier<ProgrammeBuilderState> {
  ProgrammeBuilderController(this.mode, this.programmeId);

  static final _logger = AppLogger(name: 'ProgrammeBuilderController');

  final ProgrammeBuilderMode mode;
  final String? programmeId;

  @override
  Future<ProgrammeBuilderState> build() async {
    _logger.info('build — mode: $mode');
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
        draft: _independentAssignments(draft),
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
        validationErrors: [],
      ),
    );
  }

  /// Updates the optional local programme notes.
  void updateDescription(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(description: value),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  void addTrainingBlock() {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final block = ProgrammeTrainingBlockDraft(
      id: _newId(),
      name: '',
      weekCount: 4,
    );
    final weeks = List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks ?? []);
    for (var i = 0; i < block.weekCount; i++) {
      weeks.add(
        ProgrammeBuilderWeekDraft(
          id: _newId(),
          weekNumber: weeks.length + 1,
          slots: const [],
          weekType: block.focus.weekType,
        ),
      );
    }
    _setBlockStructure(current, [
      ...current.draft.trainingBlocks,
      block,
    ], weeks);
  }

  void updateTrainingBlock(
    String id, {
    String? name,
    TrainingBlockFocus? focus,
    String? progressionNotes,
    int? weekCount,
  }) {
    final current = state.asData?.value;
    if (current == null ||
        current.isSaving ||
        (weekCount != null && weekCount < 1)) {
      return;
    }
    final blocks = List<ProgrammeTrainingBlockDraft>.of(
      current.draft.trainingBlocks,
    );
    final index = blocks.indexWhere((block) => block.id == id);
    if (index < 0) return;
    final block = blocks[index];
    final start = blocks
        .take(index)
        .fold<int>(0, (total, b) => total + b.weekCount);
    final weeks = List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks ?? []);
    final count = weekCount ?? block.weekCount;
    if (count < block.weekCount) {
      weeks.removeRange(start + count, start + block.weekCount);
    } else {
      final source = weeks.elementAtOrNull(start);
      for (var i = block.weekCount; i < count; i++) {
        weeks.insert(
          start + i,
          ProgrammeBuilderWeekDraft(
            id: _newId(),
            weekNumber: start + i + 1,
            slots: _newBlockWeekSlots(block, source),
            weekType: (focus ?? block.focus).weekType,
          ),
        );
      }
    }
    if (focus != null) {
      for (var i = start; i < start + count; i++) {
        weeks[i] = weeks[i].copyWith(weekType: focus.weekType);
      }
    }
    blocks[index] = block.copyWith(
      name: name,
      focus: focus,
      progressionNotes: progressionNotes,
      weekCount: count,
    );
    _setBlockStructure(current, blocks, weeks);
  }

  void setBlockTrainingDay(String id, TrainingDay day, bool enabled) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final blocks = List<ProgrammeTrainingBlockDraft>.of(
      current.draft.trainingBlocks,
    );
    final index = blocks.indexWhere((block) => block.id == id);
    if (index < 0) return;
    final block = blocks[index];
    final days = Set<TrainingDay>.of(block.trainingDays);
    if (enabled) {
      days.add(day);
    } else {
      days.remove(day);
    }
    blocks[index] = block.copyWith(trainingDays: days);
    final start = blocks
        .take(index)
        .fold<int>(0, (sum, item) => sum + item.weekCount);
    final weeks = List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks ?? []);
    for (var wi = start; wi < start + block.weekCount; wi++) {
      weeks[wi] = _setWeekTrainingDay(weeks[wi], day, enabled);
    }
    _setBlockStructure(current, blocks, weeks);
  }

  ProgrammeBuilderWeekDraft _setWeekTrainingDay(
    ProgrammeBuilderWeekDraft week,
    TrainingDay day,
    bool enabled,
  ) {
    final slots = List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots ?? []);
    final dayIndex = TrainingDay.values.indexOf(day);
    final hasDay = slots.any((slot) => slot.scheduledDayIndex == dayIndex);
    if (enabled && !hasDay) {
      slots.add(
        ProgrammeBuilderWorkoutSlotDraft(
          slotIndex: slots.length,
          scheduledDayIndex: dayIndex,
          scheduledDay: day,
        ),
      );
    } else if (!enabled) {
      slots.removeWhere((slot) => slot.scheduledDayIndex == dayIndex);
    }
    return week.copyWith(
      slots: [
        for (var si = 0; si < slots.length; si++)
          slots[si].copyWith(slotIndex: si),
      ],
    );
  }

  List<ProgrammeBuilderWorkoutSlotDraft> _newBlockWeekSlots(
    ProgrammeTrainingBlockDraft block,
    ProgrammeBuilderWeekDraft? source,
  ) {
    if (block.trainingDays.isEmpty) return source?.slots ?? const [];
    final slots = <ProgrammeBuilderWorkoutSlotDraft>[];
    for (final day in TrainingDay.values) {
      if (!block.trainingDays.contains(day)) continue;
      final existing = source?.slots
          ?.where((slot) => slot.scheduledDayIndex == day.index)
          .firstOrNull;
      slots.add(
        (existing ??
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: slots.length,
                  scheduledDayIndex: day.index,
                  scheduledDay: day,
                ))
            .copyWith(slotIndex: slots.length),
      );
    }
    return slots;
  }

  void removeTrainingBlock(String id) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final blocks = List<ProgrammeTrainingBlockDraft>.of(
      current.draft.trainingBlocks,
    );
    final index = blocks.indexWhere((block) => block.id == id);
    if (index < 0) return;
    final start = blocks
        .take(index)
        .fold<int>(0, (total, b) => total + b.weekCount);
    final weeks = List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks ?? []);
    weeks.removeRange(start, start + blocks[index].weekCount);
    blocks.removeAt(index);
    _setBlockStructure(current, blocks, weeks);
  }

  void _setBlockStructure(
    ProgrammeBuilderState current,
    List<ProgrammeTrainingBlockDraft> blocks,
    List<ProgrammeBuilderWeekDraft> weeks,
  ) {
    state = AsyncData(
      current.copyWith(
        draft: _independentAssignments(
          current.draft.copyWith(
            trainingBlocks: blocks,
            weeks: [
              for (var i = 0; i < weeks.length; i++)
                weeks[i].copyWith(weekNumber: i + 1),
            ],
            weeksTotal: weeks.length,
            daysPerWeek: _maximumWeekSlots(weeks),
          ),
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  List<ProgrammeTrainingBlockDraft> _adjustBlockWeeks(
    ProgrammeBuilderDraft draft,
    int weekIndex,
    int delta,
  ) {
    final blocks = List<ProgrammeTrainingBlockDraft>.of(draft.trainingBlocks);
    var end = 0;
    for (var i = 0; i < blocks.length; i++) {
      end += blocks[i].weekCount;
      if (weekIndex < end || i == blocks.length - 1) {
        final count = blocks[i].weekCount + delta;
        if (count < 1) {
          blocks.removeAt(i);
        } else {
          blocks[i] = blocks[i].copyWith(weekCount: count);
        }
        break;
      }
    }
    return blocks;
  }

  List<ProgrammeTrainingBlockDraft> _fitTrainingBlocks(
    ProgrammeBuilderDraft draft,
    int weekCount,
  ) {
    final blocks = List<ProgrammeTrainingBlockDraft>.of(draft.trainingBlocks);
    if (weekCount == 0) return [];
    if (blocks.isEmpty) {
      return [
        ProgrammeTrainingBlockDraft(
          id: _newId(),
          name: '',
          weekCount: weekCount,
        ),
      ];
    }
    var delta =
        weekCount - blocks.fold<int>(0, (sum, block) => sum + block.weekCount);
    while (delta < 0 && blocks.isNotEmpty) {
      final last = blocks.removeLast();
      final count = last.weekCount + delta;
      if (count > 0) {
        blocks.add(last.copyWith(weekCount: count));
        delta = 0;
      } else {
        delta = count;
      }
    }
    if (delta > 0) {
      blocks[blocks.length - 1] = blocks.last.copyWith(
        weekCount: blocks.last.weekCount + delta,
      );
    }
    return blocks;
  }

  /// Keeps existing weeks and repeats the first week's schedule when extending.
  void resizeWeeks(int count) {
    if (count < 1) return;
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = List<ProgrammeBuilderWeekDraft>.from(
      current.draft.weeks ?? [],
    );
    if (count < weeks.length) weeks.removeRange(count, weeks.length);
    while (weeks.length < count) {
      weeks.add(
        ProgrammeBuilderWeekDraft(
          id: _newId(),
          weekNumber: weeks.length + 1,
          slots: List<ProgrammeBuilderWorkoutSlotDraft>.from(
            weeks.firstOrNull?.slots ?? [],
          ),
        ),
      );
    }
    state = AsyncData(
      current.copyWith(
        draft: _independentAssignments(
          current.draft.copyWith(
            weeks: weeks,
            weeksTotal: count,
            daysPerWeek: _maximumWeekSlots(weeks),
          ),
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  /// Sets a training day for one week, or the typical schedule across all weeks.
  void setTrainingDay(TrainingDay day, bool enabled, {int? weekIndex}) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = List<ProgrammeBuilderWeekDraft>.from(
      current.draft.weeks ?? [],
    );
    if (weeks.isEmpty) {
      weeks.add(
        ProgrammeBuilderWeekDraft(id: _newId(), weekNumber: 1, slots: const []),
      );
    }
    if (weekIndex != null && (weekIndex < 0 || weekIndex >= weeks.length)) {
      return;
    }
    for (var wi = 0; wi < weeks.length; wi++) {
      if (weekIndex != null && wi != weekIndex) continue;
      weeks[wi] = _setWeekTrainingDay(weeks[wi], day, enabled);
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          weeks: weeks,
          weeksTotal: weeks.length,
          daysPerWeek: _maximumWeekSlots(weeks),
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  int _maximumWeekSlots(List<ProgrammeBuilderWeekDraft> weeks) => weeks.fold(
    0,
    (maximum, week) =>
        (week.slots?.length ?? 0) > maximum ? week.slots!.length : maximum,
  );

  /// Clears a template while keeping its scheduled training slot.
  void clearSlotTemplate(int weekIndex, int slotIndex) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = List<ProgrammeBuilderWeekDraft>.from(
      current.draft.weeks ?? [],
    );
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final slots = List<ProgrammeBuilderWorkoutSlotDraft>.from(
      weeks[weekIndex].slots ?? [],
    );
    if (slotIndex < 0 || slotIndex >= slots.length) return;
    slots[slotIndex] = slots[slotIndex].copyWith(clearTemplate: true);
    weeks[weekIndex] = weeks[weekIndex].copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> setProgrammeStatus(ProgramStatus value) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          status: value,
          active: value == ProgramStatus.active,
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> addWeek() async {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    final block = current.draft.trainingBlocks.lastOrNull;
    final sourceIndex = block == null ? 0 : weeks.length - block.weekCount;
    final source = weeks.elementAtOrNull(sourceIndex);
    final weekNumber = weeks.length + 1;
    _logger.info('addWeek — count: $weekNumber');
    weeks.add(
      ProgrammeBuilderWeekDraft(
        id: _newId(),
        weekNumber: weekNumber,
        slots: block != null && block.trainingDays.isNotEmpty
            ? _newBlockWeekSlots(block, source)
            : const [],
        weekType: block?.focus.weekType,
      ),
    );
    state = AsyncData(
      current.copyWith(
        draft: _independentAssignments(
          current.draft.copyWith(
            weeks: weeks,
            weeksTotal: weeks.length,
            daysPerWeek: _maximumWeekSlots(weeks),
            trainingBlocks: _adjustBlockWeeks(
              current.draft,
              weeks.length - 1,
              1,
            ),
          ),
        ),
        isDirty: true,
        validationErrors: [],
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
        draft: current.draft.copyWith(
          weeks: reindexed,
          weeksTotal: reindexed.length,
          trainingBlocks: _adjustBlockWeeks(current.draft, weekIndex, -1),
        ),
        isDirty: true,
        validationErrors: [],
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
        weekType: source.weekType,
      ),
    );
    final reindexed = weeks.asMap().entries.map((entry) {
      return entry.value.copyWith(weekNumber: entry.key + 1);
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: _independentAssignments(
          current.draft.copyWith(
            weeks: reindexed,
            weeksTotal: reindexed.length,
            trainingBlocks: _adjustBlockWeeks(current.draft, weekIndex, 1),
          ),
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  /// Adds the next unused weekday without assigning or creating a workout.
  Future<void> addWorkoutDay(int weekIndex) async {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks ?? [];
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final assigned = (weeks[weekIndex].slots ?? [])
        .map((slot) => slot.scheduledDayIndex)
        .toSet();
    final nextDay = TrainingDay.values.indexWhere(
      (day) => !assigned.contains(TrainingDay.values.indexOf(day)),
    );
    if (nextDay < 0) return;
    await addSlot(
      weekIndex: weekIndex,
      scheduledDayIndex: nextDay,
      scheduledDay: TrainingDay.values[nextDay],
    );
  }

  Future<void> addSlot({
    required int weekIndex,
    required int scheduledDayIndex,
    TrainingDay? scheduledDay,
  }) async {
    _logger.info('addSlot — weekIndex: $weekIndex');
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
        scheduledDay: scheduledDay,
      ),
    );
    weeks[weekIndex] = week.copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> updateSlotDay({
    required int weekIndex,
    required int slotIndex,
    required TrainingDay day,
  }) async {
    _logger.info(
      'updateSlotDay — weekIndex: $weekIndex, slotIndex: $slotIndex, day: $day',
    );
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
    final dayIndex = TrainingDay.values.indexOf(day);
    slots[slotIndex] = slots[slotIndex].copyWith(
      scheduledDayIndex: dayIndex,
      scheduledDay: day,
    );
    weeks[weekIndex] = week.copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> removeSlot(int weekIndex, int slotIndex) async {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final week = weeks[weekIndex];
    final slots = week.slots != null
        ? List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots!)
        : <ProgrammeBuilderWorkoutSlotDraft>[];
    if (slotIndex < 0 || slotIndex >= slots.length) return;
    slots.removeAt(slotIndex);
    final reindexed = slots.asMap().entries.map((entry) {
      return entry.value.copyWith(slotIndex: entry.key);
    }).toList();
    weeks[weekIndex] = week.copyWith(slots: reindexed);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          weeks: weeks,
          daysPerWeek: _maximumWeekSlots(weeks),
          templates: [
            for (final week in weeks)
              for (final slot
                  in week.slots ?? <ProgrammeBuilderWorkoutSlotDraft>[])
                if (slot.template != null) slot.template!.id,
          ],
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  /// Adds a workout authored for this programme without saving a library copy.
  Future<void> assignWorkoutDraftToSlot({
    required int weekIndex,
    required int? slotIndex,
    required WorkoutBuilderDraft draft,
  }) async {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks ?? [];
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    if (slotIndex == null) {
      final slots = weeks[weekIndex].slots ?? [];
      final assigned = slots.map((slot) => slot.scheduledDayIndex).toSet();
      final dayIndex = TrainingDay.values.indexWhere(
        (day) => !assigned.contains(TrainingDay.values.indexOf(day)),
      );
      final nextDay = dayIndex < 0
          ? slots.length % TrainingDay.values.length
          : dayIndex;
      slotIndex = slots.length;
      await addSlot(
        weekIndex: weekIndex,
        scheduledDayIndex: nextDay,
        scheduledDay: TrainingDay.values[nextDay],
      );
    }
    final template = const WorkoutDraftToProgrammeTemplateConverter().convert(
      draft,
    );
    await assignTemplateToSlot(
      weekIndex: weekIndex,
      slotIndex: slotIndex,
      template: template,
    );
  }

  Future<void> assignTemplateToSlot({
    required int weekIndex,
    required int slotIndex,
    required ProgrammeBuilderTemplateDraft template,
  }) async {
    _logger.info(
      'assignTemplateToSlot — weekIndex: $weekIndex, slotIndex: $slotIndex, template: ${template.templateKey}',
    );
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final week = weeks[weekIndex];
    final slots = week.slots != null
        ? List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots!)
        : <ProgrammeBuilderWorkoutSlotDraft>[];
    if (slotIndex < 0 || slotIndex >= slots.length) return;
    final usedElsewhere = weeks.asMap().entries.any(
      (entry) => (entry.value.slots ?? []).asMap().entries.any(
        (slot) =>
            (entry.key != weekIndex || slot.key != slotIndex) &&
            (slot.value.template?.id == template.id ||
                slot.value.template?.templateKey == template.templateKey),
      ),
    );
    slots[slotIndex] = slots[slotIndex].copyWith(
      template: usedElsewhere ? _copyAssignmentTemplate(template) : template,
    );
    weeks[weekIndex] = week.copyWith(slots: slots);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  /// Copies the selected workout onto the same weekday in its training block.
  void repeatWorkoutAcrossBlock({
    required int weekIndex,
    required int slotIndex,
  }) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks ?? []);
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final sourceSlots = weeks[weekIndex].slots ?? [];
    if (slotIndex < 0 || slotIndex >= sourceSlots.length) return;
    final source = sourceSlots[slotIndex];
    final template = source.template;
    final block = ProgrammeTrainingBlockDraft.forWeek(
      current.draft.trainingBlocks,
      weekIndex,
    );
    if (template == null || block == null || block.weekCount < 2) return;
    final blockIndex = current.draft.trainingBlocks.indexOf(block);
    final start = current.draft.trainingBlocks
        .take(blockIndex)
        .fold<int>(0, (sum, block) => sum + block.weekCount);
    for (
      var wi = start;
      wi < start + block.weekCount && wi < weeks.length;
      wi++
    ) {
      if (wi == weekIndex) continue;
      final slots = List<ProgrammeBuilderWorkoutSlotDraft>.of(
        weeks[wi].slots ?? [],
      );
      final target = slots.indexWhere(
        (slot) => slot.scheduledDayIndex == source.scheduledDayIndex,
      );
      final copy = _copyAssignmentTemplate(template);
      if (target < 0) {
        slots.add(
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: slots.length,
            scheduledDayIndex: source.scheduledDayIndex,
            scheduledDay: source.scheduledDay,
            template: copy,
          ),
        );
      } else {
        slots[target] = slots[target].copyWith(template: copy);
      }
      weeks[wi] = weeks[wi].copyWith(slots: slots);
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          weeks: weeks,
          daysPerWeek: _maximumWeekSlots(weeks),
          templates: [
            for (final week in weeks)
              for (final slot
                  in week.slots ?? <ProgrammeBuilderWorkoutSlotDraft>[])
                if (slot.template != null) slot.template!.id,
          ],
        ),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  void addTemplateExercises(
    String templateId,
    List<ExerciseReference> selected,
  ) {
    final additions = [
      for (final exercise in selected)
        ProgrammeExerciseDraft(
          id: _newId(),
          exerciseId: exercise.exerciseId,
          exerciseRef: exercise.name,
          sortOrder: 0,
          sets: [
            SetPrescriptionDraft(
              id: _newId(),
              setIndex: 0,
              setType: SetType.working,
            ),
          ],
        ),
    ];
    if (additions.isEmpty) return;
    _editExercises(
      templateId,
      (exercises) => [
        ...exercises,
        for (var i = 0; i < additions.length; i++)
          additions[i].copyWith(sortOrder: exercises.length + i),
      ],
    );
  }

  void updateTemplateExercise(
    String templateId,
    ProgrammeExerciseDraft updated,
  ) {
    _editExercises(
      templateId,
      (exercises) => [
        for (final exercise in exercises)
          exercise.id == updated.id ? updated : exercise,
      ],
    );
  }

  void removeTemplateExercise(String templateId, String exerciseId) {
    _editExercises(templateId, (exercises) {
      final remaining = exercises
          .where((exercise) => exercise.id != exerciseId)
          .toList();
      final groupCounts = <String, int>{};
      for (final exercise in remaining) {
        final group = exercise.supersetGroupId;
        if (group != null) groupCounts[group] = (groupCounts[group] ?? 0) + 1;
      }
      final groupOrders = <String, int>{};
      return [
        for (var i = 0; i < remaining.length; i++)
          if (remaining[i].supersetGroupId != null &&
              groupCounts[remaining[i].supersetGroupId] == 1)
            ProgrammeExerciseDraft(
              id: remaining[i].id,
              exerciseId: remaining[i].exerciseId,
              sortOrder: i,
              sets: remaining[i].sets,
              exerciseRef: remaining[i].exerciseRef,
              exerciseRole: remaining[i].exerciseRole,
              programmeRole: remaining[i].programmeRole,
              notes: remaining[i].notes,
              cuesJson: remaining[i].cuesJson,
              restBetweenExercisesSeconds:
                  remaining[i].restBetweenExercisesSeconds,
            )
          else
            remaining[i].copyWith(
              sortOrder: i,
              supersetOrder: remaining[i].supersetGroupId == null
                  ? null
                  : (groupOrders.update(
                      remaining[i].supersetGroupId!,
                      (order) => order + 1,
                      ifAbsent: () => 0,
                    )),
            ),
      ];
    });
  }

  void reorderTemplateExercises(String templateId, int oldIndex, int newIndex) {
    _editExercises(templateId, (exercises) {
      if (oldIndex < 0 ||
          oldIndex >= exercises.length ||
          newIndex < 0 ||
          newIndex > exercises.length) {
        return exercises;
      }
      if (newIndex > oldIndex) newIndex--;
      exercises.insert(newIndex, exercises.removeAt(oldIndex));
      return [
        for (var i = 0; i < exercises.length; i++)
          exercises[i].copyWith(sortOrder: i),
      ];
    });
  }

  void addTemplateSet(String templateId, String exerciseId) {
    final id = _newId();
    _editExercises(
      templateId,
      (exercises) => [
        for (final exercise in exercises)
          if (exercise.id == exerciseId)
            exercise.copyWith(
              sets: [
                ...exercise.sets,
                if (exercise.sets.isEmpty)
                  SetPrescriptionDraft(
                    id: id,
                    setIndex: 0,
                    setType: SetType.working,
                  )
                else
                  exercise.sets.last.copyWith(
                    id: id,
                    setIndex: exercise.sets.length,
                  ),
              ],
            )
          else
            exercise,
      ],
    );
  }

  void removeTemplateSet(String templateId, String exerciseId, String setId) {
    _editExercises(
      templateId,
      (exercises) => [
        for (final exercise in exercises)
          if (exercise.id == exerciseId)
            exercise.copyWith(
              sets: _reindexSets(
                exercise.sets.where((set) => set.id != setId).toList(),
              ),
            )
          else
            exercise,
      ],
    );
  }

  List<SetPrescriptionDraft> _reindexSets(List<SetPrescriptionDraft> sets) => [
    for (var i = 0; i < sets.length; i++) sets[i].copyWith(setIndex: i),
  ];

  void _editExercises(
    String templateId,
    List<ProgrammeExerciseDraft> Function(List<ProgrammeExerciseDraft>)
    transform,
  ) {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final updated = _updateTemplateExercises(current, templateId, transform);
    if (updated != null) state = AsyncData(updated);
  }

  Future<void> setWeekType({
    required int weekIndex,
    required WeekType type,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    if (weekIndex >= weeks.length) return;
    weeks[weekIndex] = weeks[weekIndex].copyWith(weekType: type);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(weeks: weeks),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> updateTemplateRestBetweenExercises(int? restSeconds) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(restBetweenExercisesSeconds: restSeconds),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> setGoalTags(Set<GoalTag> tags) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(goalTags: tags),
        isDirty: true,
        validationErrors: [],
      ),
    );
  }

  Future<void> saveDraft() => _save(asDraft: true);

  Future<void> saveProgramme() => _save(asDraft: false);

  Future<void> _save({required bool asDraft}) async {
    _logger.info('saveProgramme — start, asDraft: $asDraft');
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final draft = current.draft.copyWith(
      status: asDraft
          ? ProgramStatus.draft
          : current.draft.status == ProgramStatus.draft
          ? ProgramStatus.inactive
          : current.draft.status,
      active: !asDraft && current.draft.status == ProgramStatus.active,
    );
    final validator = ref.read(AppProviders.programmeBuilderValidatorProvider);
    final errors = asDraft
        ? <ProgrammeBuilderValidationError>[
            if (draft.name.trim().isEmpty)
              const ProgrammeBuilderValidationError(
                scope: ProgrammeBuilderValidationScope.programme,
                code: AppErrorCodes.missingName,
                message: AppStrings.programmeNameRequired,
              ),
          ]
        : validator.validate(draft);

    if (errors.isNotEmpty) {
      _logger.info('saveProgramme — validation fail, ${errors.length} errors');
      state = AsyncData(
        current.copyWith(
          phase: ProgrammeBuilderPhase.editing,
          validationErrors: errors,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        phase: ProgrammeBuilderPhase.saving,
        validationErrors: [],
      ),
    );

    try {
      final saveUseCase = ref.read(
        AppProviders.saveProgrammeBuilderDraftUseCaseProvider,
      );
      final savedId = await saveUseCase.save(draft);
      _logger.info('saveProgramme — success: $savedId');
      if (mode == ProgrammeBuilderMode.create) {
        final loadUseCase = ref.read(
          AppProviders.loadProgrammeBuilderDraftUseCaseProvider,
        );
        final freshDraft = await loadUseCase.createEmptyDraft();
        state = AsyncData(
          current.copyWith(
            phase: ProgrammeBuilderPhase.editing,
            draft: freshDraft,
            validationErrors: [],
            programmeId: null,
            isDirty: false,
          ),
        );
      } else {
        state = AsyncData(
          current.copyWith(
            phase: ProgrammeBuilderPhase.editing,
            programmeId: savedId,
            draft: draft,
            isDirty: false,
            validationErrors: [],
          ),
        );
      }
    } catch (e) {
      _logger.error('saveProgramme — failure', error: e);
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

  // V1-M4-008 — superset / execution groups

  Future<void> createTemplateSuperset({
    required String templateId,
    required List<String> selectedExerciseIds,
  }) async {
    _logger.debug(
      'createTemplateSuperset — templateId: $templateId, members: ${selectedExerciseIds.length}',
    );
    final current = state.asData?.value;
    if (current == null || selectedExerciseIds.length < 2) return;

    final service = ref.read(
      AppProviders.programmeBuilderSupersetServiceProvider,
    );
    final updated = _updateTemplateExercises(
      current,
      templateId,
      (exercises) => service.createSuperset(
        exercises: exercises,
        selectedExerciseIds: selectedExerciseIds,
        groupId: _newId(),
      ),
    );
    if (updated == null) return;
    state = AsyncData(updated);
  }

  Future<void> removeTemplateExerciseFromSuperset({
    required String templateId,
    required String exerciseId,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final service = ref.read(
      AppProviders.programmeBuilderSupersetServiceProvider,
    );
    final updated = _updateTemplateExercises(
      current,
      templateId,
      (exercises) => service.removeExerciseFromSuperset(
        exercises: exercises,
        exerciseId: exerciseId,
      ),
    );
    if (updated == null) return;
    state = AsyncData(updated);
  }

  Future<void> deleteTemplateSuperset({
    required String templateId,
    required String groupId,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final service = ref.read(
      AppProviders.programmeBuilderSupersetServiceProvider,
    );
    final updated = _updateTemplateExercises(
      current,
      templateId,
      (exercises) =>
          service.deleteSupersetGroup(exercises: exercises, groupId: groupId),
    );
    if (updated == null) return;
    state = AsyncData(updated);
  }

  Future<void> reorderTemplateSupersetMember({
    required String templateId,
    required String exerciseId,
    required int newOrder,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final service = ref.read(
      AppProviders.programmeBuilderSupersetServiceProvider,
    );
    final updated = _updateTemplateExercises(current, templateId, (exercises) {
      final target = exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => exercises.first,
      );
      final groupId = target.supersetGroupId;
      if (groupId == null) return exercises;
      return service.reorderWithinSuperset(
        exercises: exercises,
        groupId: groupId,
        exerciseId: exerciseId,
        newOrder: newOrder,
      );
    });
    if (updated == null) return;
    state = AsyncData(updated);
  }

  ProgrammeBuilderState? _updateTemplateExercises(
    ProgrammeBuilderState current,
    String templateId,
    List<ProgrammeExerciseDraft> Function(List<ProgrammeExerciseDraft>)
    transform,
  ) {
    final weeks = current.draft.weeks != null
        ? List<ProgrammeBuilderWeekDraft>.of(current.draft.weeks!)
        : <ProgrammeBuilderWeekDraft>[];
    ProgrammeBuilderTemplateDraft? updatedTemplate;

    final updatedWeeks = weeks.map((week) {
      final slots = week.slots != null
          ? List<ProgrammeBuilderWorkoutSlotDraft>.of(week.slots!)
          : <ProgrammeBuilderWorkoutSlotDraft>[];
      for (var i = 0; i < slots.length; i++) {
        final slot = slots[i];
        if (slot.template?.id == templateId) {
          final template = slot.template!;
          updatedTemplate ??= template.copyWith(
            exercises: transform(
              List<ProgrammeExerciseDraft>.of(template.exercises),
            ),
          );
          slots[i] = slot.copyWith(template: updatedTemplate);
        }
      }
      return week.copyWith(slots: slots);
    }).toList();

    if (updatedTemplate == null) return null;

    return current.copyWith(
      draft: current.draft.copyWith(weeks: updatedWeeks),
      isDirty: true,
      validationErrors: [],
    );
  }

  /// Separates legacy shared assignments while preserving an open draft.
  void ensureIndependentAssignments() {
    final current = state.asData?.value;
    if (current == null || current.isSaving) return;
    final ids = <String>{};
    final keys = <String>{};
    for (final week in current.draft.weeks ?? <ProgrammeBuilderWeekDraft>[]) {
      for (final slot in week.slots ?? <ProgrammeBuilderWorkoutSlotDraft>[]) {
        final template = slot.template;
        if (template != null &&
            (!ids.add(template.id) || !keys.add(template.templateKey))) {
          state = AsyncData(
            current.copyWith(
              draft: _independentAssignments(current.draft),
              isDirty: true,
            ),
          );
          return;
        }
      }
    }
  }

  ProgrammeBuilderDraft _independentAssignments(ProgrammeBuilderDraft draft) {
    final seenIds = <String>{};
    final seenKeys = <String>{};
    final templates = <String>[];
    final weeks = <ProgrammeBuilderWeekDraft>[];
    for (final week in draft.weeks ?? <ProgrammeBuilderWeekDraft>[]) {
      final slots = <ProgrammeBuilderWorkoutSlotDraft>[];
      for (final slot in week.slots ?? <ProgrammeBuilderWorkoutSlotDraft>[]) {
        final original = slot.template;
        if (original == null) {
          slots.add(slot);
          continue;
        }
        final template =
            seenIds.contains(original.id) ||
                seenKeys.contains(original.templateKey)
            ? _copyAssignmentTemplate(original)
            : original;
        seenIds.add(template.id);
        seenKeys.add(template.templateKey);
        templates.add(template.id);
        slots.add(slot.copyWith(template: template));
      }
      weeks.add(week.copyWith(slots: slots));
    }
    return draft.copyWith(
      weeks: weeks,
      templates: templates,
      trainingBlocks: _fitTrainingBlocks(draft, weeks.length),
    );
  }

  ProgrammeBuilderTemplateDraft _copyAssignmentTemplate(
    ProgrammeBuilderTemplateDraft template,
  ) {
    final groups = <String, String>{};
    return template.copyWith(
      id: _newId(),
      templateKey: _newId(),
      exercises: [
        for (final exercise in template.exercises)
          exercise.copyWith(
            id: _newId(),
            supersetGroupId: exercise.supersetGroupId == null
                ? null
                : groups.putIfAbsent(exercise.supersetGroupId!, _newId),
            sets: [for (final set in exercise.sets) set.copyWith(id: _newId())],
          ),
      ],
    );
  }

  String _newId() => const Uuid().v4();
}
