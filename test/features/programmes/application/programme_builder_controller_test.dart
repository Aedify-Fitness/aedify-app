import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_validator.dart';
import 'package:aedify/features/programmes/application/load_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/save_programme_builder_draft_use_case.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';

ProgrammeBuilderDraft _defaultDraft() {
  return ProgrammeBuilderDraft(
    id: 'test-id',
    name: 'Test Programme',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.draft,
    weeks: [],
    templates: [],
  );
}

ProgrammeBuilderDraft _draftWithOneWeek() {
  return _defaultDraft().copyWith(
    weeks: [ProgrammeBuilderWeekDraft(id: 'week-1', weekNumber: 1, slots: [])],
  );
}

ProgrammeBuilderDraft _draftWithSlots() {
  return _defaultDraft().copyWith(
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'week-1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(slotIndex: 0, scheduledDayIndex: 0),
          ProgrammeBuilderWorkoutSlotDraft(slotIndex: 1, scheduledDayIndex: 1),
          ProgrammeBuilderWorkoutSlotDraft(slotIndex: 2, scheduledDayIndex: 2),
        ],
      ),
    ],
  );
}

ProgrammeBuilderDraft _validDraft() {
  return _defaultDraft().copyWith(
    name: 'Valid Programme',
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'week-1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 't-1',
              templateKey: 't-1',
              name: 'Push Day',
            ),
          ),
        ],
      ),
    ],
    templates: ['t-1'],
  );
}

class _FakeLoadUseCase implements LoadProgrammeBuilderDraftUseCase {
  _FakeLoadUseCase({ProgrammeBuilderDraft? draftToReturn})
    : _draft = draftToReturn;

  ProgrammeBuilderDraft? _draft;
  bool shouldThrow = false;

  set draftToReturn(ProgrammeBuilderDraft? d) => _draft = d;

  @override
  Future<ProgrammeBuilderDraft> createEmptyDraft() async {
    if (shouldThrow) throw Exception('load failed');
    return _draft ?? _defaultDraft();
  }

  @override
  Future<ProgrammeBuilderDraft> loadForEdit(String programmeId) async {
    if (shouldThrow) throw Exception('load failed');
    return (_draft ?? _defaultDraft()).copyWith(id: programmeId);
  }

  @override
  Future<ProgrammeBuilderDraft> loadDuplicate(String programmeId) async {
    if (shouldThrow) throw Exception('load failed');
    return (_draft ?? _defaultDraft()).copyWith(
      id: 'duplicated-id',
      name: '${(_draft ?? _defaultDraft()).name} (Copy)',
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: ProgramStatus.draft,
      active: false,
    );
  }
}

class _FakeSaveUseCase implements SaveProgrammeBuilderDraftUseCase {
  String saveResult = 'saved-id';
  bool shouldThrow = false;
  ProgrammeBuilderDraft? lastSavedDraft;

  @override
  Future<String> save(ProgrammeBuilderDraft builderDraft) async {
    if (shouldThrow) throw Exception('save failed');
    lastSavedDraft = builderDraft;
    return saveResult;
  }
}

void main() {
  late _FakeLoadUseCase fakeLoadUseCase;
  late _FakeSaveUseCase fakeSaveUseCase;
  const validator = ProgrammeBuilderValidator();

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        AppProviders.loadProgrammeBuilderDraftUseCaseProvider.overrideWithValue(
          fakeLoadUseCase,
        ),
        AppProviders.saveProgrammeBuilderDraftUseCaseProvider.overrideWithValue(
          fakeSaveUseCase,
        ),
        AppProviders.programmeBuilderValidatorProvider.overrideWithValue(
          validator,
        ),
      ],
    );
  }

  setUp(() {
    fakeLoadUseCase = _FakeLoadUseCase();
    fakeSaveUseCase = _FakeSaveUseCase();
  });

  group('ProgrammeBuilderController (create mode)', () {
    test('initial build returns editing state with empty draft', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, ProgrammeBuilderPhase.editing);
      expect(state.mode, ProgrammeBuilderMode.create);
      expect(state.draft.name, 'Test Programme');
      expect(state.draft.weeks, isEmpty);
      expect(state.isDirty, isFalse);
    });

    test('initial build returns failure state when loading throws', () async {
      fakeLoadUseCase.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, ProgrammeBuilderPhase.failure);
    });

    test('updateName sets name and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateName('New Name');

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.name, 'New Name');
      expect(state.isDirty, isTrue);
    });

    test('addWeek adds a week and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addWeek();

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, hasLength(1));
      expect(state.draft.weeks![0].weekNumber, 1);
      expect(state.isDirty, isTrue);
    });

    test('addWeek increments week numbers', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addWeek();
      await controller.addWeek();

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, hasLength(2));
      expect(state.draft.weeks![0].weekNumber, 1);
      expect(state.draft.weeks![1].weekNumber, 2);
    });

    test('removeWeek removes week and reindexes', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addWeek();
      await controller.addWeek();
      await controller.addWeek();
      await controller.removeWeek(1);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, hasLength(2));
      expect(state.draft.weeks![0].weekNumber, 1);
      expect(state.draft.weeks![1].weekNumber, 2);
    });

    test('duplicateWeek duplicates the week', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addWeek();
      await controller.duplicateWeek(0);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, hasLength(2));
      expect(state.draft.weeks![0].weekNumber, 1);
      expect(state.draft.weeks![1].weekNumber, 2);
      expect(state.draft.weeks![1].id, isNot(state.draft.weeks![0].id));
    });

    group('slot operations with pre-populated week', () {
      test('addSlot adds slot to a week', () async {
        fakeLoadUseCase.draftToReturn = _draftWithOneWeek();
        final container = createContainer();
        final controller = container.read(
          AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          )).notifier,
        );
        await controller.future;

        await controller.addSlot(weekIndex: 0, scheduledDayIndex: 2);

        final state = container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue;
        expect(state.draft.weeks![0].slots, hasLength(1));
        expect(state.draft.weeks![0].slots![0].scheduledDayIndex, 2);
      });

      test('removeSlot removes slot and reindexes', () async {
        fakeLoadUseCase.draftToReturn = _draftWithSlots();
        final container = createContainer();
        final controller = container.read(
          AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          )).notifier,
        );
        await controller.future;

        await controller.removeSlot(0, 1);

        final state = container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue;
        expect(state.draft.weeks![0].slots, hasLength(2));
        expect(state.draft.weeks![0].slots![0].slotIndex, 0);
        expect(state.draft.weeks![0].slots![1].slotIndex, 1);
      });

      test('assignTemplateToSlot assigns template', () async {
        fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'week-1',
              weekNumber: 1,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                ),
              ],
            ),
          ],
        );
        final container = createContainer();
        final controller = container.read(
          AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          )).notifier,
        );
        await controller.future;

        final template = ProgrammeBuilderTemplateDraft(
          id: 't-1',
          templateKey: 't-1',
          name: 'Push Day',
        );
        await controller.assignTemplateToSlot(
          weekIndex: 0,
          slotIndex: 0,
          template: template,
        );

        final state = container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue;
        expect(state.draft.weeks![0].slots![0].template?.id, 't-1');
      });
    });

    group('save', () {
      test('saveProgramme transitions to editing with saved id', () async {
        fakeLoadUseCase.draftToReturn = _validDraft();
        final container = createContainer();
        final controller = container.read(
          AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          )).notifier,
        );
        await controller.future;

        await controller.saveProgramme();

        final state = container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue;
        expect(state.phase, ProgrammeBuilderPhase.editing);
        expect(state.programmeId, 'saved-id');
        expect(state.isDirty, isFalse);
        expect(fakeSaveUseCase.lastSavedDraft, isNotNull);
      });

      test(
        'saveProgramme sets validation errors when draft is invalid',
        () async {
          final container = createContainer();
          final controller = container.read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )).notifier,
          );
          await controller.future;

          await controller.saveProgramme();

          final state = container
              .read(
                AppProviders.programmeBuilderControllerProvider((
                  mode: ProgrammeBuilderMode.create,
                  programmeId: null,
                )),
              )
              .requireValue;
          expect(state.phase, ProgrammeBuilderPhase.editing);
          expect(state.validationErrors, isNotEmpty);
          expect(fakeSaveUseCase.lastSavedDraft, isNull);
        },
      );

      test('saveProgramme sets failure state when save throws', () async {
        fakeLoadUseCase.draftToReturn = _validDraft();
        fakeSaveUseCase.shouldThrow = true;
        final container = createContainer();
        final controller = container.read(
          AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          )).notifier,
        );
        await controller.future;

        await controller.saveProgramme();

        final state = container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue;
        expect(state.phase, ProgrammeBuilderPhase.failure);
      });
    });

    test('clearValidationErrors clears validation errors', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.saveProgramme();
      expect(
        container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue
            .validationErrors,
        isNotEmpty,
      );

      controller.clearValidationErrors();
      expect(
        container
            .read(
              AppProviders.programmeBuilderControllerProvider((
                mode: ProgrammeBuilderMode.create,
                programmeId: null,
              )),
            )
            .requireValue
            .validationErrors,
        isEmpty,
      );
    });
  });

  group('ProgrammeBuilderController (edit mode)', () {
    test('initial build loads draft for given programmeId', () async {
      fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
        id: 'existing-id',
        name: 'Existing Programme',
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.edit,
          programmeId: 'existing-id',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.mode, ProgrammeBuilderMode.edit);
      expect(state.draft.id, 'existing-id');
      expect(state.draft.name, 'Existing Programme');
      expect(state.programmeId, 'existing-id');
    });

    test('initial build is dirty for edit mode', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.edit,
          programmeId: 'existing-id',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.isDirty, isTrue);
    });
  });

  group('ProgrammeBuilderController (duplicate mode)', () {
    test('initial build loads duplicate draft', () async {
      fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
        name: 'Original',
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.duplicate,
          programmeId: 'original-id',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.mode, ProgrammeBuilderMode.duplicate);
      expect(state.draft.name, 'Original (Copy)');
      expect(state.isDirty, isTrue);
    });
  });

  group('edge cases', () {
    test('removeWeek does nothing for out-of-range index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.removeWeek(5);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, isEmpty);
    });

    test('addSlot does nothing for out-of-range week index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addSlot(weekIndex: 5, scheduledDayIndex: 0);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, isEmpty);
    });

    test('removeSlot does nothing for out-of-range indices', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.removeSlot(0, 0);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, isEmpty);
    });

    test('duplicateWeek does nothing for out-of-range index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.duplicateWeek(5);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks, isEmpty);
    });
  });
}
