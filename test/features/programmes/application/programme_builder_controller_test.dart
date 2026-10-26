import '../../../app/m3/fake_m3_dependencies.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/application/programme_builder_validation_adapter.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/core/validation/default_draft_validation_service.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_validator.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/application/load_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/save_programme_builder_draft_use_case.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/domain/training_day.dart';

ProgrammeBuilderDraft _defaultDraft() {
  return ProgrammeBuilderDraft(
    id: 'test-id',
    name: 'Test Programme',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.draft,
    goalTags: const {GoalTag.buildMuscle},
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

ProgrammeBuilderDraft _draftWithTemplateExercises() {
  return _defaultDraft().copyWith(
    name: 'Test Programme',
    trainingBlocks: const [
      ProgrammeTrainingBlockDraft(id: 'base', name: 'Base', weekCount: 1),
    ],
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
              exercises: [
                ProgrammeExerciseDraft(
                  id: 'e1',
                  exerciseId: 1,
                  sortOrder: 0,
                  sets: [],
                  exerciseRef: 'Bench Press',
                ),
                ProgrammeExerciseDraft(
                  id: 'e2',
                  exerciseId: 2,
                  sortOrder: 1,
                  sets: [],
                  exerciseRef: 'Fly',
                ),
                ProgrammeExerciseDraft(
                  id: 'e3',
                  exerciseId: 3,
                  sortOrder: 2,
                  sets: [],
                  exerciseRef: 'Press',
                ),
              ],
            ),
          ),
        ],
      ),
    ],
    templates: ['t-1'],
  );
}

ProgrammeBuilderDraft _validDraft() {
  return _defaultDraft().copyWith(
    name: 'Valid Programme',
    trainingBlocks: const [
      ProgrammeTrainingBlockDraft(id: 'base', name: 'Base', weekCount: 1),
    ],
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

class _UnavailableProfileRepository extends FakeProfileRepository {
  @override
  Future<ProfileViewData?> getProfile() async =>
      throw StateError('unavailable');
}

void main() {
  late _FakeLoadUseCase fakeLoadUseCase;
  late _FakeSaveUseCase fakeSaveUseCase;
  late FakeProfileRepository profileRepository;
  final validator = ProgrammeBuilderValidator(
    validationService: const DefaultDraftValidationService(),
    adapter: const ProgrammeBuilderValidationAdapter(),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        AppProviders.profileRepositoryProvider.overrideWithValue(
          profileRepository,
        ),
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
    profileRepository = FakeProfileRepository();
  });

  group('profile workout-day defaults', () {
    test(
      'new blocks preselect profile days and create matching slots in every week',
      () async {
        await profileRepository.saveProfile(
          const ProfileEditDraft(
            trainingDays: [
              TrainingDay.friday,
              TrainingDay.monday,
              TrainingDay.wednesday,
            ],
          ),
        );
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.addTrainingBlock();
        var draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.single.trainingDays, {
          TrainingDay.monday,
          TrainingDay.wednesday,
          TrainingDay.friday,
        });
        expect(draft.daysPerWeek, 3);
        expect(draft.weeks, hasLength(4));
        for (final week in draft.weeks!) {
          expect(week.slots!.map((slot) => slot.scheduledDay), [
            TrainingDay.monday,
            TrainingDay.wednesday,
            TrainingDay.friday,
          ]);
          expect(week.slots!.map((slot) => slot.scheduledDayIndex), [0, 2, 4]);
          expect(week.slots!.map((slot) => slot.slotIndex), [0, 1, 2]);
          expect(week.slots!.every((slot) => slot.template == null), isTrue);
        }
        controller.setBlockTrainingDay(
          draft.trainingBlocks.single.id,
          TrainingDay.monday,
          false,
        );
        controller.addTrainingBlock();
        draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.first.trainingDays, {
          TrainingDay.wednesday,
          TrainingDay.friday,
        });
        expect(draft.trainingBlocks.last.trainingDays, {
          TrainingDay.monday,
          TrainingDay.wednesday,
          TrainingDay.friday,
        });
        expect((await profileRepository.getProfile())!.trainingDays, [
          TrainingDay.friday,
          TrainingDay.monday,
          TrainingDay.wednesday,
        ]);
        await controller.saveDraft();
        expect(
          fakeSaveUseCase.lastSavedDraft!.trainingBlocks.last.trainingDays,
          {TrainingDay.monday, TrainingDay.wednesday, TrainingDay.friday},
        );
      },
    );

    for (final emptyProfile in [false, true]) {
      test(
        'no chosen profile days leaves new block days empty: profile=$emptyProfile',
        () async {
          if (emptyProfile) {
            await profileRepository.saveProfile(const ProfileEditDraft());
          }
          final container = createContainer();
          addTearDown(container.dispose);
          final provider = AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          ));
          await container.read(provider.future);
          container.read(provider.notifier).addTrainingBlock();
          final draft = container.read(provider).requireValue.draft;
          expect(draft.trainingBlocks.single.trainingDays, isEmpty);
          expect(draft.weeks!.every((week) => week.slots!.isEmpty), isTrue);
        },
      );
    }

    for (final mode in [
      ProgrammeBuilderMode.edit,
      ProgrammeBuilderMode.duplicate,
    ]) {
      test(
        '$mode preserves saved workout days instead of using profile defaults',
        () async {
          await profileRepository.saveProfile(
            const ProfileEditDraft(trainingDays: [TrainingDay.sunday]),
          );
          fakeLoadUseCase.draftToReturn = _draftWithSlots().copyWith(
            trainingBlocks: const [
              ProgrammeTrainingBlockDraft(
                id: 'block',
                name: 'Saved block',
                weekCount: 1,
                trainingDays: {
                  TrainingDay.monday,
                  TrainingDay.tuesday,
                  TrainingDay.wednesday,
                },
              ),
            ],
          );
          final container = createContainer();
          addTearDown(container.dispose);
          final provider = AppProviders.programmeBuilderControllerProvider((
            mode: mode,
            programmeId: 'saved',
          ));
          final state = await container.read(provider.future);
          expect(state.draft.trainingBlocks.single.trainingDays, {
            TrainingDay.monday,
            TrainingDay.tuesday,
            TrainingDay.wednesday,
          });
          expect(
            state.draft.weeks!.single.slots!.map(
              (slot) => slot.scheduledDayIndex,
            ),
            [0, 1, 2],
          );
        },
      );
    }

    test(
      'unavailable profile does not block manual programme creation',
      () async {
        profileRepository = _UnavailableProfileRepository();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        final state = await container.read(provider.future);
        expect(state.phase, ProgrammeBuilderPhase.editing);
        container.read(provider.notifier).addTrainingBlock();
        expect(
          container
              .read(provider)
              .requireValue
              .draft
              .trainingBlocks
              .single
              .trainingDays,
          isEmpty,
        );
      },
    );
  });

  group('Define Workouts template editing', () {
    test(
      'assigning a reusable template gives each workout day independent identities',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithSlots();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        final source =
            _draftWithTemplateExercises().weeks!.first.slots!.first.template!;
        await controller.assignTemplateToSlot(
          weekIndex: 0,
          slotIndex: 0,
          template: source,
        );
        await controller.assignTemplateToSlot(
          weekIndex: 0,
          slotIndex: 1,
          template: source,
        );
        final slots = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .single
            .slots!;
        final first = slots[0].template!;
        final second = slots[1].template!;
        expect(first.id, source.id);
        expect(second.id, isNot(first.id));
        expect(second.templateKey, isNot(first.templateKey));
        expect(second.exercises.first.id, isNot(first.exercises.first.id));
        controller.removeTemplateExercise(second.id, second.exercises.first.id);
        final updated = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .single
            .slots!;
        expect(updated[0].template!.exercises, hasLength(3));
        expect(updated[1].template!.exercises, hasLength(2));
      },
    );

    test(
      'duplicated weeks retain prescriptions and independent superset groups',
      () async {
        final draft = _draftWithTemplateExercises();
        final source = draft.weeks!.first.slots!.first.template!;
        final grouped = source.copyWith(
          exercises: [
            for (var i = 0; i < 2; i++)
              source.exercises[i].copyWith(
                supersetGroupId: 'group',
                supersetOrder: i,
                sets: [
                  SetPrescriptionDraft(
                    id: 'set-$i',
                    setIndex: 0,
                    setType: SetType.working,
                    prescribedRepsExact: 8,
                    prescribedWeightKg: 60,
                    prescribedWeightPct1rm: 70,
                    loadSelectionNote: 'Keep this target',
                    isCalibrationEstimate: true,
                    warmupWeightRuleJson: '{}',
                  ),
                ],
              ),
          ],
        );
        fakeLoadUseCase.draftToReturn = draft.copyWith(
          weeks: [
            draft.weeks!.first.copyWith(
              slots: [
                draft.weeks!.first.slots!.first.copyWith(template: grouped),
              ],
            ),
          ],
        );
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        await controller.duplicateWeek(0);
        final weeks = container.read(provider).requireValue.draft.weeks!;
        final first = weeks.first.slots!.single.template!;
        final second = weeks.last.slots!.single.template!;
        expect(second.id, isNot(first.id));
        expect(
          second.exercises.map((exercise) => exercise.supersetGroupId).toSet(),
          hasLength(1),
        );
        expect(
          second.exercises.first.supersetGroupId,
          isNot(first.exercises.first.supersetGroupId),
        );
        expect(second.exercises.map((exercise) => exercise.supersetOrder), [
          0,
          1,
        ]);
        final copiedSet = second.exercises.first.sets.single;
        expect(copiedSet.id, isNot(first.exercises.first.sets.single.id));
        expect(copiedSet.prescribedWeightKg, 60);
        expect(copiedSet.prescribedWeightPct1rm, 70);
        expect(copiedSet.loadSelectionNote, 'Keep this target');
        expect(copiedSet.isCalibrationEstimate, isTrue);
        expect(copiedSet.warmupWeightRuleJson, '{}');
        controller.removeTemplateExercise(second.id, second.exercises.first.id);
        final updated = container.read(provider).requireValue.draft.weeks!;
        expect(updated.first.slots!.single.template!.exercises, hasLength(2));
        expect(updated.last.slots!.single.template!.exercises, hasLength(1));
      },
    );

    test(
      'edits one day, preserves targets on other days, and reindexes its sets',
      () async {
        final draft = _draftWithTemplateExercises();
        final template = draft.weeks!.first.slots!.first.template!;
        final set = SetPrescriptionDraft(
          id: 'set',
          setIndex: 0,
          setType: SetType.working,
          prescribedRepsExact: 8,
          prescribedWeightKg: 60,
          prescribedRpeMin: 8,
          prescribedRpeMax: 9,
          durationSeconds: 30,
          distanceMeters: 100,
          prescribedWeightPct1rm: 70,
          loadSelectionNote: 'Keep the existing target',
          isCalibrationEstimate: true,
        );
        final shared = template.copyWith(
          exercises: [
            template.exercises.first.copyWith(sets: [set]),
          ],
        );
        final slot = draft.weeks!.first.slots!.first.copyWith(template: shared);
        fakeLoadUseCase.draftToReturn = draft.copyWith(
          weeks: [
            draft.weeks!.first.copyWith(
              slots: [slot, slot.copyWith(slotIndex: 1, scheduledDayIndex: 2)],
            ),
            ProgrammeBuilderWeekDraft(
              id: 'week-2',
              weekNumber: 2,
              slots: [slot],
            ),
          ],
        );
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.updateTemplateExercise(
          't-1',
          shared.exercises.first.copyWith(
            notes: 'Local note',
            sets: [
              set.copyWith(
                prescribedRepsExact: null,
                prescribedRepsMin: 10,
                prescribedRepsMax: 12,
                prescribedWeightKg: null,
                prescribedRpeMin: null,
                prescribedRpeMax: null,
              ),
            ],
          ),
        );
        controller.addTemplateSet('t-1', 'e1');
        var state = container.read(provider).requireValue;
        final occurrences = state.draft.weeks!
            .expand((week) => week.slots!)
            .map((slot) => slot.template!)
            .toList();
        expect(occurrences, hasLength(3));
        for (final occurrence in occurrences.take(1)) {
          final exercise = occurrence.exercises.single;
          expect(exercise.notes, 'Local note');
          expect(exercise.sets, hasLength(2));
          expect(exercise.sets.last.id, isNot(exercise.sets.first.id));
          for (final updated in exercise.sets) {
            expect(updated.prescribedRepsExact, isNull);
            expect(updated.prescribedRepsMin, 10);
            expect(updated.prescribedRepsMax, 12);
            expect(updated.prescribedWeightKg, isNull);
            expect(updated.prescribedRpeMin, isNull);
            expect(updated.prescribedRpeMax, isNull);
            expect(updated.durationSeconds, 30);
            expect(updated.distanceMeters, 100);
            expect(updated.prescribedWeightPct1rm, 70);
            expect(updated.loadSelectionNote, 'Keep the existing target');
            expect(updated.isCalibrationEstimate, isTrue);
          }
        }
        expect(occurrences.map((item) => item.id).toSet(), hasLength(3));
        expect(
          occurrences.map((item) => item.templateKey).toSet(),
          hasLength(3),
        );
        for (final occurrence in occurrences.skip(1)) {
          final exercise = occurrence.exercises.single;
          expect(exercise.notes, isNull);
          expect(exercise.sets, hasLength(1));
          expect(exercise.sets.single.prescribedRepsExact, 8);
          expect(exercise.sets.single.prescribedWeightKg, 60);
          expect(exercise.sets.single.prescribedWeightPct1rm, 70);
          expect(
            exercise.sets.single.loadSelectionNote,
            'Keep the existing target',
          );
          expect(exercise.sets.single.isCalibrationEstimate, isTrue);
        }
        controller.removeTemplateSet('t-1', 'e1', 'set');
        state = container.read(provider).requireValue;
        expect(
          state
              .draft
              .weeks!
              .first
              .slots!
              .first
              .template!
              .exercises
              .single
              .sets
              .single
              .setIndex,
          0,
        );
        expect(state.isDirty, isTrue);
        await controller.saveProgramme();
        expect(
          fakeSaveUseCase
              .lastSavedDraft!
              .weeks!
              .last
              .slots!
              .first
              .template!
              .exercises
              .single
              .notes,
          isNull,
        );
        expect(
          fakeSaveUseCase
              .lastSavedDraft!
              .weeks!
              .first
              .slots!
              .first
              .template!
              .exercises
              .single
              .notes,
          'Local note',
        );
      },
    );

    test(
      'adds references, reorders, removes exercises and dissolves a singleton superset',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.addTemplateExercises('t-1', [
          const ExerciseReference(
            exerciseId: -1,
            name: 'Custom exercise',
            modality: 'strength',
            isCustom: true,
          ),
        ]);
        var exercises = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .first
            .slots!
            .first
            .template!
            .exercises;
        expect(exercises.last.exerciseId, -1);
        expect(exercises.last.exerciseRef, 'Custom exercise');
        expect(exercises.last.sets.single.setType, SetType.working);
        expect(exercises.last.sets.single.prescribedRepsExact, isNull);
        controller.reorderTemplateExercises('t-1', 3, 0);
        await controller.createTemplateSuperset(
          templateId: 't-1',
          selectedExerciseIds: ['e1', 'e2'],
        );
        controller.removeTemplateExercise('t-1', 'e1');
        exercises = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .first
            .slots!
            .first
            .template!
            .exercises;
        expect(exercises.first.exerciseId, -1);
        expect(exercises.map((item) => item.sortOrder), [0, 1, 2]);
        expect(
          exercises.firstWhere((item) => item.id == 'e2').supersetGroupId,
          isNull,
        );
        expect(
          exercises.firstWhere((item) => item.id == 'e2').supersetOrder,
          isNull,
        );
      },
    );
  });

  group('builder schedule controls', () {
    test(
      'addWorkoutDay adds empty weekdays only to the selected week and stops at seven',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.resizeWeeks(2);
        await controller.addWorkoutDay(1);
        var weeks = container.read(provider).requireValue.draft.weeks!;
        expect(weeks.first.slots, hasLength(1));
        expect(weeks.last.slots, hasLength(2));
        expect(weeks.last.slots!.last.scheduledDay, TrainingDay.tuesday);
        expect(weeks.last.slots!.last.template, isNull);
        await controller.addWorkoutDay(1);
        weeks = container.read(provider).requireValue.draft.weeks!;
        expect(weeks.last.slots, hasLength(3));
        expect(weeks.last.slots!.last.scheduledDay, TrainingDay.wednesday);
        expect(weeks.last.slots!.last.template, isNull);
        for (var i = 0; i < 8; i++) {
          await controller.addWorkoutDay(1);
        }
        weeks = container.read(provider).requireValue.draft.weeks!;
        expect(weeks.first.slots, hasLength(1));
        expect(weeks.last.slots, hasLength(7));
        expect(
          weeks.last.slots!
              .map((slot) => TrainingDay.values[slot.scheduledDayIndex])
              .toSet(),
          TrainingDay.values.toSet(),
        );
        expect(
          weeks.last.slots!.skip(1).every((slot) => slot.template == null),
          isTrue,
        );
      },
    );

    test(
      'extends weeks with independent assignments while preserving existing weeks',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.resizeWeeks(4);
        final draft = container.read(provider).requireValue.draft;
        expect(draft.weeks!.map((week) => week.weekNumber), [1, 2, 3, 4]);
        expect(draft.weeks!.map((week) => week.id).toSet(), hasLength(4));
        expect(draft.weeks!.first.id, 'week-1');
        expect(draft.weeks!.first.slots!.first.template!.id, 't-1');
        expect(
          draft.weeks!.map((week) => week.slots!.first.template!.id).toSet(),
          hasLength(4),
        );
        controller.resizeWeeks(2);
        expect(container.read(provider).requireValue.draft.weeks, hasLength(2));
        expect(
          container.read(provider).requireValue.draft.weeks!.first.id,
          'week-1',
        );
      },
    );

    test(
      'typical training days repeat across weeks and week edits stay isolated',
      () async {
        fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
          daysPerWeek: 5,
        );
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        controller.resizeWeeks(4);
        controller.setTrainingDay(TrainingDay.monday, true);
        controller.setTrainingDay(TrainingDay.monday, true);
        controller.setTrainingDay(TrainingDay.friday, true, weekIndex: 2);
        final weeks = container.read(provider).requireValue.draft.weeks!;
        expect(weeks.map((week) => week.slots!.length), [1, 1, 2, 1]);
        expect(weeks[2].slots!.last.scheduledDay, TrainingDay.friday);
        expect(container.read(provider).requireValue.draft.daysPerWeek, 2);
        controller.setTrainingDay(TrainingDay.monday, false, weekIndex: 2);
        final updated = container.read(provider).requireValue.draft.weeks!;
        expect(updated[0].slots!.first.scheduledDay, TrainingDay.monday);
        expect(updated[2].slots!.single.slotIndex, 0);
        expect(updated[2].slots!.single.scheduledDay, TrainingDay.friday);
        expect(container.read(provider).requireValue.draft.daysPerWeek, 1);
      },
    );

    test(
      'clears a workout assignment without deleting its training day',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
        final container = createContainer();
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        await container.read(provider.future);
        container.read(provider.notifier).clearSlotTemplate(0, 0);
        final slot = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .single
            .slots!
            .single;
        expect(slot.template, isNull);
        expect(slot.scheduledDayIndex, 0);
        expect(container.read(provider).requireValue.isDirty, isTrue);
      },
    );
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

    test(
      'block days apply only to their weeks while weekly overrides remain independent',
      () async {
        final original = _draftWithTemplateExercises();
        final week = original.weeks!.single;
        fakeLoadUseCase.draftToReturn = original.copyWith(
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(
              id: 'first',
              name: 'First',
              weekCount: 2,
            ),
            ProgrammeTrainingBlockDraft(
              id: 'second',
              name: 'Second',
              weekCount: 1,
            ),
          ],
          weeks: [
            week,
            week.copyWith(id: 'week-2', weekNumber: 2),
            week.copyWith(id: 'week-3', weekNumber: 3),
          ],
        );
        final container = createContainer();
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        final controller = container.read(provider.notifier);
        await controller.future;
        final originalWeeks = container
            .read(provider)
            .requireValue
            .draft
            .weeks!;
        controller.setBlockTrainingDay('first', TrainingDay.monday, true);
        controller.setBlockTrainingDay('first', TrainingDay.friday, true);
        var draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.first.trainingDays, {
          TrainingDay.monday,
          TrainingDay.friday,
        });
        expect(draft.weeks![0].slots!.map((s) => s.scheduledDayIndex), [0, 4]);
        expect(draft.weeks![1].slots!.map((s) => s.scheduledDayIndex), [0, 4]);
        expect(draft.weeks!.last.id, originalWeeks.last.id);
        expect(draft.weeks!.last.slots!.single.scheduledDayIndex, 0);
        expect(
          draft.weeks!.last.slots!.single.template!.id,
          originalWeeks.last.slots!.single.template!.id,
        );
        expect(
          draft.weeks!.first.slots!.first.template!.id,
          originalWeeks.first.slots!.single.template!.id,
        );
        controller.setTrainingDay(TrainingDay.friday, false, weekIndex: 1);
        controller.setTrainingDay(TrainingDay.tuesday, true, weekIndex: 1);
        controller.updateTrainingBlock(
          'first',
          name: 'Renamed',
          progressionNotes: 'Notes',
        );
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks![1].slots!.map((s) => s.scheduledDayIndex), [0, 1]);
        expect(draft.trainingBlocks.first.trainingDays, {
          TrainingDay.monday,
          TrainingDay.friday,
        });
        controller.updateTrainingBlock('first', weekCount: 3);
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks![2].slots!.map((s) => s.scheduledDayIndex), [0, 4]);
        expect(
          draft.weeks![2].slots!.first.template!.id,
          isNot(draft.weeks!.first.slots!.first.template!.id),
        );
        expect(draft.weeks!.last.id, originalWeeks.last.id);
        controller.setTrainingDay(TrainingDay.monday, false, weekIndex: 0);
        controller.updateTrainingBlock('first', weekCount: 4);
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks![3].slots!.map((s) => s.scheduledDayIndex), [0, 4]);
        controller.setBlockTrainingDay('first', TrainingDay.monday, false);
        draft = container.read(provider).requireValue.draft;
        expect(
          draft.weeks!
              .take(4)
              .every((w) => w.slots!.every((s) => s.scheduledDayIndex != 0)),
          isTrue,
        );
        expect(draft.weeks![1].slots!.single.scheduledDayIndex, 1);
        expect(draft.weeks!.last.slots!.single.scheduledDayIndex, 0);
        controller.setBlockTrainingDay('missing', TrainingDay.sunday, true);
        expect(container.read(provider).requireValue.draft, same(draft));
      },
    );

    test(
      'training blocks preserve later weeks when resized and removed',
      () async {
        final initial = _draftWithTemplateExercises();
        final week = initial.weeks!.single;
        fakeLoadUseCase.draftToReturn = initial.copyWith(
          weeks: [
            week,
            week.copyWith(id: 'week-2', weekNumber: 2),
          ],
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(id: 'base', name: 'Base', weekCount: 1),
            ProgrammeTrainingBlockDraft(
              id: 'strength',
              name: 'Strength',
              weekCount: 1,
              focus: TrainingBlockFocus.strengthBiased,
            ),
          ],
        );
        final container = createContainer();
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        final controller = container.read(provider.notifier);
        await controller.future;
        final later = container.read(provider).requireValue.draft.weeks!.last;
        controller.updateTrainingBlock(
          'base',
          weekCount: 3,
          name: 'Volume',
          progressionNotes: 'Add a rep each week',
          focus: TrainingBlockFocus.hypertrophyBiased,
        );
        var draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.map((block) => block.weekCount), [3, 1]);
        expect(draft.weeks, hasLength(4));
        expect(draft.weeks!.last.id, later.id);
        expect(
          draft.weeks!.last.slots!.single.template!.id,
          later.slots!.single.template!.id,
        );
        expect(
          draft.weeks!.take(3).every((w) => w.weekType == WeekType.hypertrophy),
          isTrue,
        );
        expect(
          draft.weeks!
              .expand((w) => w.slots!)
              .map((slot) => slot.template!.id)
              .toSet(),
          hasLength(4),
        );
        controller.updateTrainingBlock('base', weekCount: 1);
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks!.last.id, later.id);
        expect(draft.weeks!.map((w) => w.weekNumber), [1, 2]);
        expect(
          draft.trainingBlocks.first.progressionNotes,
          'Add a rep each week',
        );
        controller.removeTrainingBlock('base');
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks!.single.id, later.id);
        expect(draft.weeks!.single.weekNumber, 1);
        expect(draft.trainingBlocks.single.id, 'strength');
        controller.removeTrainingBlock('strength');
        expect(container.read(provider).requireValue.draft.weeks, isEmpty);
        expect(
          container.read(provider).requireValue.draft.trainingBlocks,
          isEmpty,
        );
      },
    );

    test(
      'legacy weeks receive an unnamed base block and week controls update membership',
      () async {
        fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises().copyWith(
          trainingBlocks: [],
        );
        final container = createContainer();
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        final controller = container.read(provider.notifier);
        await controller.future;
        expect(
          container
              .read(provider)
              .requireValue
              .draft
              .trainingBlocks
              .single
              .name,
          isEmpty,
        );
        expect(
          container
              .read(provider)
              .requireValue
              .draft
              .trainingBlocks
              .single
              .weekCount,
          1,
        );
        await controller.duplicateWeek(0);
        expect(
          container
              .read(provider)
              .requireValue
              .draft
              .trainingBlocks
              .single
              .weekCount,
          2,
        );
        await controller.removeWeek(0);
        expect(
          container
              .read(provider)
              .requireValue
              .draft
              .trainingBlocks
              .single
              .weekCount,
          1,
        );
        controller.addTrainingBlock();
        var draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.last.name, isEmpty);
        expect(draft.trainingBlocks.map((block) => block.weekCount), [1, 4]);
        expect(draft.weeks, hasLength(5));
        final lastBlockId = draft.trainingBlocks.last.id;
        controller.setBlockTrainingDay(lastBlockId, TrainingDay.thursday, true);
        controller.setTrainingDay(TrainingDay.tuesday, true, weekIndex: 1);
        await controller.addWeek();
        draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.map((block) => block.weekCount), [1, 5]);
        expect(
          draft.weeks!.last.slots!.single.scheduledDay,
          TrainingDay.thursday,
        );
        controller.updateTrainingBlock(
          draft.trainingBlocks.last.id,
          weekCount: 0,
        );
        expect(container.read(provider).requireValue.draft, same(draft));
      },
    );

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

      test(
        'removeSlot updates frequency and template references without changing other weeks',
        () async {
          final original = _draftWithTemplateExercises();
          final week = original.weeks!.single;
          fakeLoadUseCase.draftToReturn = original.copyWith(
            weeks: [
              week.copyWith(
                slots: [
                  week.slots!.single,
                  week.slots!.single.copyWith(
                    slotIndex: 1,
                    scheduledDayIndex: 2,
                  ),
                ],
              ),
              week.copyWith(id: 'week-2', weekNumber: 2),
            ],
          );
          final container = createContainer();
          final provider = AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          ));
          final controller = container.read(provider.notifier);
          await controller.future;
          final otherWeek = container
              .read(provider)
              .requireValue
              .draft
              .weeks!
              .last;
          await controller.removeSlot(0, 0);
          final draft = container.read(provider).requireValue.draft;
          expect(draft.daysPerWeek, 1);
          expect(draft.weeks!.first.slots!.single.slotIndex, 0);
          expect(draft.weeks!.last, same(otherWeek));
          expect(draft.templates, [
            draft.weeks!.first.slots!.single.template!.id,
            otherWeek.slots!.single.template!.id,
          ]);
          await controller.removeSlot(-1, 0);
          await controller.removeSlot(0, -1);
          await controller.removeSlot(0, 99);
          expect(container.read(provider).requireValue.draft, same(draft));
        },
      );

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

    test(
      'repeating targets the same weekday only within its block and clones editable data',
      () async {
        final original = _draftWithTemplateExercises();
        final source = original.weeks!.single;
        fakeLoadUseCase.draftToReturn = original.copyWith(
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(id: 'a', name: 'Base', weekCount: 3),
            ProgrammeTrainingBlockDraft(
              id: 'b',
              name: 'Strength',
              weekCount: 1,
            ),
          ],
          weeks: [
            source,
            source.copyWith(id: 'week-2', weekNumber: 2),
            source.copyWith(
              id: 'week-3',
              weekNumber: 3,
              slots: [source.slots!.single.copyWith(scheduledDayIndex: 2)],
            ),
            source.copyWith(id: 'week-4', weekNumber: 4),
          ],
        );
        final container = createContainer();
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        ));
        final controller = container.read(provider.notifier);
        await controller.future;
        final before = container.read(provider).requireValue.draft;
        controller.repeatWorkoutAcrossBlock(weekIndex: 0, slotIndex: 0);
        final after = container.read(provider).requireValue.draft;
        final sourceTemplate = after.weeks!.first.slots!.single.template!;
        final repeated = after.weeks![1].slots!.single.template!;
        expect(repeated.name, sourceTemplate.name);
        expect(repeated.id, isNot(sourceTemplate.id));
        expect(repeated.templateKey, isNot(sourceTemplate.templateKey));
        expect(
          repeated.exercises.first.id,
          isNot(sourceTemplate.exercises.first.id),
        );
        expect(after.weeks![2].slots!.map((slot) => slot.scheduledDayIndex), [
          2,
          0,
        ]);
        expect(
          after.weeks![2].slots!.first,
          same(before.weeks![2].slots!.first),
        );
        expect(after.weeks![3], same(before.weeks![3]));
        controller.updateTemplateExercise(
          repeated.id,
          repeated.exercises.first.copyWith(notes: 'Custom afterwards'),
        );
        final edited = container.read(provider).requireValue.draft;
        expect(
          edited.weeks!.first.slots!.single.template!.exercises.first.notes,
          sourceTemplate.exercises.first.notes,
        );
        expect(
          edited.weeks![1].slots!.single.template!.exercises.first.notes,
          'Custom afterwards',
        );
        expect(container.read(provider).requireValue.isDirty, isTrue);
      },
    );

    group('save', () {
      test(
        'saveDraft accepts unfinished structure and persists inactive draft status',
        () async {
          fakeLoadUseCase.draftToReturn = _draftWithSlots().copyWith(
            goalTags: {},
            trainingBlocks: [
              const ProgrammeTrainingBlockDraft(
                id: 'block',
                name: '',
                weekCount: 1,
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
          await controller.saveProgramme();
          expect(fakeSaveUseCase.lastSavedDraft, isNull);
          await controller.saveDraft();
          final saved = fakeSaveUseCase.lastSavedDraft!;
          expect(saved.status, ProgramStatus.draft);
          expect(saved.active, isFalse);
          expect(saved.goalTags, isEmpty);
          expect(saved.trainingBlocks.single.name, isEmpty);
          expect(saved.weeks!.single.slots, hasLength(3));
          final state = container
              .read(
                AppProviders.programmeBuilderControllerProvider((
                  mode: ProgrammeBuilderMode.create,
                  programmeId: null,
                )),
              )
              .requireValue;
          expect(state.validationErrors, isEmpty);
          expect(state.isDirty, isFalse);
        },
      );

      test(
        'publishing a draft promotes it to inactive after full validation',
        () async {
          fakeLoadUseCase.draftToReturn = _validDraft();
          final container = createContainer();
          final controller = container.read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.edit,
              programmeId: 'test-id',
            )).notifier,
          );
          await controller.future;
          await controller.saveProgramme();
          expect(
            fakeSaveUseCase.lastSavedDraft!.status,
            ProgramStatus.inactive,
          );
          expect(fakeSaveUseCase.lastSavedDraft!.active, isFalse);
          expect(
            container
                .read(
                  AppProviders.programmeBuilderControllerProvider((
                    mode: ProgrammeBuilderMode.edit,
                    programmeId: 'test-id',
                  )),
                )
                .requireValue
                .draft
                .status,
            ProgramStatus.inactive,
          );
        },
      );

      test(
        'failed draft save retains the edited status and contents for retry',
        () async {
          fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
            status: ProgramStatus.inactive,
          );
          fakeSaveUseCase.shouldThrow = true;
          final container = createContainer();
          final provider = AppProviders.programmeBuilderControllerProvider((
            mode: ProgrammeBuilderMode.create,
            programmeId: null,
          ));
          final controller = container.read(provider.notifier);
          await controller.future;
          await controller.updateName('Unfinished work');
          await controller.saveDraft();
          expect(
            container.read(provider).requireValue.phase,
            ProgrammeBuilderPhase.failure,
          );
          expect(
            container.read(provider).requireValue.draft.name,
            'Unfinished work',
          );
          expect(
            container.read(provider).requireValue.draft.status,
            ProgramStatus.inactive,
          );
          expect(container.read(provider).requireValue.isDirty, isTrue);
          fakeSaveUseCase.shouldThrow = false;
          await controller.saveDraft();
          expect(fakeSaveUseCase.lastSavedDraft!.status, ProgramStatus.draft);
        },
      );

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
        expect(state.programmeId, isNull);
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

          fakeLoadUseCase.draftToReturn = _defaultDraft();
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

  group('Validation error clearing on mutations', () {
    late ProviderContainer container;
    late ProgrammeBuilderController controller;

    Future<void> setupAndTriggerErrors({ProgrammeBuilderDraft? draft}) async {
      container = createContainer();
      controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;
      await controller.saveProgramme();
      final stateAfterSave = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(stateAfterSave.validationErrors, isNotEmpty);
    }

    test('updateName clears validation errors', () async {
      await setupAndTriggerErrors();

      await controller.updateName('New Name');
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('addWeek clears validation errors', () async {
      await setupAndTriggerErrors();

      await controller.addWeek();
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('removeWeek clears validation errors', () async {
      fakeLoadUseCase.draftToReturn = _draftWithOneWeek();
      await setupAndTriggerErrors();

      await controller.removeWeek(0);
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('duplicateWeek clears validation errors', () async {
      fakeLoadUseCase.draftToReturn = _draftWithOneWeek();
      await setupAndTriggerErrors();

      await controller.duplicateWeek(0);
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('addSlot clears validation errors', () async {
      fakeLoadUseCase.draftToReturn = _draftWithOneWeek();
      await setupAndTriggerErrors();

      await controller.addSlot(weekIndex: 0, scheduledDayIndex: 0);
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('removeSlot clears validation errors', () async {
      fakeLoadUseCase.draftToReturn = _draftWithSlots();
      await setupAndTriggerErrors();

      await controller.removeSlot(0, 0);
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
    });

    test('assignTemplateToSlot clears validation errors', () async {
      fakeLoadUseCase.draftToReturn = _draftWithSlots();
      await setupAndTriggerErrors();

      await controller.assignTemplateToSlot(
        weekIndex: 0,
        slotIndex: 0,
        template: ProgrammeBuilderTemplateDraft(
          id: 't-new',
          templateKey: 't-new',
          name: 'Push Day',
        ),
      );
      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.validationErrors, isEmpty);
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

    test('createTemplateSuperset groups template exercises', () async {
      fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.createTemplateSuperset(
        templateId: 't-1',
        selectedExerciseIds: ['e1', 'e2'],
      );

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      final slot = state.draft.weeks![0].slots![0];
      final exercises = slot.template!.exercises;

      final e1 = exercises.firstWhere((e) => e.id == 'e1');
      final e2 = exercises.firstWhere((e) => e.id == 'e2');
      final e3 = exercises.firstWhere((e) => e.id == 'e3');

      expect(e1.supersetGroupId, isNotNull);
      expect(e1.supersetOrder, 0);
      expect(e2.supersetGroupId, isNotNull);
      expect(e2.supersetOrder, 1);
      expect(e3.supersetGroupId, isNull);
      expect(e3.supersetOrder, isNull);
      expect(state.isDirty, isTrue);
    });

    test('createTemplateSuperset ignores fewer than 2', () async {
      fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.createTemplateSuperset(
        templateId: 't-1',
        selectedExerciseIds: ['e1'],
      );

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      final exercises = state.draft.weeks![0].slots![0].template!.exercises;
      expect(exercises.every((e) => e.supersetGroupId == null), isTrue);
    });

    test('deleteTemplateSuperset clears group fields', () async {
      fakeLoadUseCase.draftToReturn = _draftWithTemplateExercises();
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.create,
          programmeId: null,
        )).notifier,
      );
      await controller.future;

      await controller.createTemplateSuperset(
        templateId: 't-1',
        selectedExerciseIds: ['e1', 'e2'],
      );

      var state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      final groupId = state.draft.weeks![0].slots![0].template!.exercises
          .firstWhere((e) => e.id == 'e1')
          .supersetGroupId!;

      await controller.deleteTemplateSuperset(
        templateId: 't-1',
        groupId: groupId,
      );

      state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      final exercises = state.draft.weeks![0].slots![0].template!.exercises;
      expect(exercises.every((e) => e.supersetGroupId == null), isTrue);
      expect(exercises.every((e) => e.supersetOrder == null), isTrue);
    });

    test('setWeekType updates week type', () async {
      fakeLoadUseCase.draftToReturn = _defaultDraft().copyWith(
        weeks: [
          ProgrammeBuilderWeekDraft(id: 'week-1', weekNumber: 1, slots: []),
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

      await controller.setWeekType(weekIndex: 0, type: WeekType.deload);

      final state = container
          .read(
            AppProviders.programmeBuilderControllerProvider((
              mode: ProgrammeBuilderMode.create,
              programmeId: null,
            )),
          )
          .requireValue;
      expect(state.draft.weeks![0].weekType, WeekType.deload);
      expect(state.isDirty, isTrue);
    });
  });
}
