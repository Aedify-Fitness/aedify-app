import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_repetition.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/load_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/save_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/program_dao.dart';
import 'package:aedify/core/db/daos/program_workout_template_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/program_week_dao.dart';
import 'package:aedify/core/db/daos/program_workout_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/program_revision_dao.dart';
import 'package:aedify/features/programmes/data/drift_programme_repository.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/core/db/transactions/drift_transaction_executor.dart';
import 'package:aedify/core/db/transactions/no_op_transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_execution_failure.dart';
import '../../../support/transactions/throwing_transaction_failure_injection.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/exercise_role.dart';
import 'package:aedify/shared/domain/loading_model.dart';

void main() {
  late AppDatabase db;
  late ProgrammeRepository repository;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final uuid = const Uuid();
    repository = DriftProgrammeRepository(
      programDao: ProgramDao(db),
      programWorkoutTemplateDao: ProgramWorkoutTemplateDao(db),
      programTemplateExerciseDao: ProgramTemplateExerciseDao(db),
      programTemplateExerciseSetDao: ProgramTemplateExerciseSetDao(db),
      programWeekDao: ProgramWeekDao(db),
      programWorkoutDao: ProgramWorkoutDao(db),
      programExerciseDao: ProgramExerciseDao(db),
      programExerciseSetDao: ProgramExerciseSetDao(db),
      programRevisionDao: ProgramRevisionDao(db),
      transactionExecutor: DriftTransactionExecutor(
        database: db,
        failureInjection: const NoOpTransactionFailureInjection(),
      ),
      uuid: uuid,
    );
  });

  tearDown(() {
    db.close();
  });

  group('DriftProgrammeRepository', () {
    test(
      'repeated workout goals and independent assignments survive reloading',
      () async {
        final save = SaveProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final load = LoadProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        const template = ProgrammeBuilderTemplateDraft(
          id: 'goal-template',
          templateKey: 'goal-template',
          name: 'Push',
          goalTags: ['Strength'],
        );
        final draft = ProgrammeBuilderDraft(
          id: 'goal-programme',
          name: 'Goal programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          templates: [],
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(
              id: 'goal-block',
              name: 'Base',
              weekCount: 2,
            ),
          ],
          weeks: [
            for (var i = 0; i < 2; i++)
              ProgrammeBuilderWeekDraft(
                id: 'goal-week-$i',
                weekNumber: i + 1,
                slots: [
                  ProgrammeBuilderWorkoutSlotDraft(
                    slotIndex: 0,
                    scheduledDayIndex: 0,
                    template: template.copyWith(
                      id: 'goal-template-$i',
                      templateKey: 'goal-template-$i',
                    ),
                  ),
                ],
              ),
          ],
        );
        await save.save(draft);
        final restored = await load.loadForEdit(draft.id);
        expect(ProgrammeWorkoutRepetition.repeatedSlots(restored, 0), {0});
        expect(ProgrammeWorkoutRepetition.repeatedSlots(restored, 1), {0});
        expect(
          restored.weeks!.map((week) => week.slots!.single.template!.goalTags),
          [
            ['Strength'],
            ['Strength'],
          ],
        );
        expect(
          restored.weeks!
              .map((week) => week.slots!.single.template!.id)
              .toSet(),
          hasLength(2),
        );
      },
    );

    test(
      'unfinished drafts retain unassigned days and empty weeks through save/load',
      () async {
        final save = SaveProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final load = LoadProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final draft = ProgrammeBuilderDraft(
          id: 'unfinished',
          name: 'Unfinished plan',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          goalTags: {},
          templates: [],
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(
              id: 'unfinished-block',
              name: '',
              weekCount: 2,
            ),
          ],
          weeks: const [
            ProgrammeBuilderWeekDraft(
              id: 'draft-week-1',
              weekNumber: 1,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                ),
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 1,
                  scheduledDayIndex: 4,
                ),
              ],
            ),
            ProgrammeBuilderWeekDraft(
              id: 'draft-week-2',
              weekNumber: 2,
              slots: [],
            ),
          ],
        );
        await save.save(draft);
        final restored = await load.loadForEdit(draft.id);
        expect(restored.status, ProgramStatus.draft);
        expect(restored.active, isFalse);
        expect(restored.goalTags, isEmpty);
        expect(restored.trainingBlocks.single.name, isEmpty);
        expect(restored.weeks!.first.slots!.map((s) => s.scheduledDayIndex), [
          0,
          4,
        ]);
        expect(
          restored.weeks!.first.slots!.every((s) => s.template == null),
          isTrue,
        );
        expect(restored.weeks!.last.slots, isEmpty);
        await expectLater(
          repository.activateProgramme(draft.id),
          throwsStateError,
        );
        expect(
          (await repository.getProgramme(draft.id))!.program.active,
          isFalse,
        );
        await save.save(restored.copyWith(weeks: [], trainingBlocks: []));
        final detailsOnly = await load.loadForEdit(draft.id);
        expect(detailsOnly.name, draft.name);
        expect(detailsOnly.status, ProgramStatus.draft);
        expect(detailsOnly.weeks, isEmpty);
      },
    );

    test(
      'weekly day overrides survive reloading a block with default days',
      () async {
        const block = ProgrammeTrainingBlockDraft(
          id: 'block',
          name: 'Base',
          weekCount: 2,
          trainingDays: {TrainingDay.monday, TrainingDay.wednesday},
        );
        await repository.saveProgramme(
          const ProgrammeDraft(
            id: 'day-overrides',
            name: 'Weekly overrides',
            source: WorkoutSource.manual,
            creationMethod: CreationMethod.manual,
            status: ProgramStatus.inactive,
            active: false,
            goalTags: {GoalTag.buildMuscle},
            equipment: {},
            trainingBlocks: [block],
            weeksTotal: 2,
            weekSlotDayIndices: [
              [0, 2],
              [0, 4],
            ],
            weekSlotTemplateIds: [
              ['workout', 'workout'],
              ['workout', 'workout'],
            ],
            templates: [
              ProgrammeWorkoutTemplateDraft(
                id: 'workout',
                templateKey: 'workout',
                name: 'Workout',
                sortOrder: 0,
                exercises: [],
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [
            AppProviders.loadProgrammeBuilderDraftUseCaseProvider
                .overrideWithValue(
                  LoadProgrammeBuilderDraftUseCase(
                    programmeRepository: repository,
                  ),
                ),
          ],
        );
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.edit,
          programmeId: 'day-overrides',
        ));
        await container.read(provider.future);
        var draft = container.read(provider).requireValue.draft;
        expect(draft.trainingBlocks.single.trainingDays, block.trainingDays);
        expect(draft.weeks!.first.slots!.map((s) => s.scheduledDayIndex), [
          0,
          2,
        ]);
        expect(draft.weeks!.last.slots!.map((s) => s.scheduledDayIndex), [
          0,
          4,
        ]);
        container
            .read(provider.notifier)
            .updateTrainingBlock('block', name: 'Renamed');
        draft = container.read(provider).requireValue.draft;
        expect(draft.weeks!.last.slots!.map((s) => s.scheduledDayIndex), [
          0,
          4,
        ]);
        expect(draft.trainingBlocks.single.trainingDays, block.trainingDays);
      },
    );

    test(
      'training blocks save, reload, duplicate, update and delete with a programme',
      () async {
        final save = SaveProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final load = LoadProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final draft = ProgrammeBuilderDraft(
          id: 'blocks-programme',
          name: 'Block programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.inactive,
          templates: const [],
          trainingBlocks: const [
            ProgrammeTrainingBlockDraft(
              id: 'volume',
              name: 'Volume',
              weekCount: 1,
              focus: TrainingBlockFocus.hypertrophyBiased,
              progressionNotes: 'Add reps',
              trainingDays: {TrainingDay.monday, TrainingDay.wednesday},
            ),
            ProgrammeTrainingBlockDraft(
              id: 'strength',
              name: 'Strength',
              weekCount: 2,
              focus: TrainingBlockFocus.strengthBiased,
              progressionNotes: 'Add load',
            ),
          ],
          weeks: [
            for (var i = 1; i <= 3; i++)
              ProgrammeBuilderWeekDraft(
                id: 'week-$i',
                weekNumber: i,
                slots: const [],
              ),
          ],
        );
        await save.save(draft);
        var restored = await load.loadForEdit(draft.id);
        expect(restored.trainingBlocks.map((b) => b.name), [
          'Volume',
          'Strength',
        ]);
        expect(restored.trainingBlocks.map((b) => b.weekCount), [1, 2]);
        expect(
          restored.trainingBlocks.last.focus,
          TrainingBlockFocus.strengthBiased,
        );
        expect(restored.trainingBlocks.last.progressionNotes, 'Add load');
        expect(restored.trainingBlocks.first.trainingDays, {
          TrainingDay.monday,
          TrainingDay.wednesday,
        });
        final duplicate = await load.loadDuplicate(draft.id);
        expect(
          duplicate.trainingBlocks.first.id,
          isNot(restored.trainingBlocks.first.id),
        );
        expect(duplicate.trainingBlocks.last.progressionNotes, 'Add load');
        expect(
          duplicate.trainingBlocks.first.trainingDays,
          restored.trainingBlocks.first.trainingDays,
        );
        await save.save(
          restored.copyWith(
            trainingBlocks: [
              restored.trainingBlocks.first.copyWith(name: 'Updated volume'),
              restored.trainingBlocks.last,
            ],
          ),
        );
        restored = await load.loadForEdit(draft.id);
        expect(restored.trainingBlocks.first.name, 'Updated volume');
        expect(await db.select(db.programTrainingBlocks).get(), hasLength(2));
        await repository.deleteProgramme(draft.id);
        expect(await db.select(db.programTrainingBlocks).get(), isEmpty);
      },
    );

    test(
      'day-specific template targets remain independent after saving and reloading',
      () async {
        final programmeId = await repository.saveProgramme(
          ProgrammeDraft(
            id: const Uuid().v4(),
            name: 'Day-specific programme',
            source: WorkoutSource.manual,
            creationMethod: CreationMethod.manual,
            status: ProgramStatus.inactive,
            active: false,
            goalTags: const {GoalTag.buildMuscle},
            equipment: {},
            weeksTotal: 1,
            daysPerWeek: 2,
            slotDayIndices: const [0, 2],
            slotTemplateIds: const ['push', 'push'],
            templates: [
              ProgrammeWorkoutTemplateDraft(
                id: 'push',
                templateKey: 'push',
                name: 'Push Day',
                sortOrder: 0,
                exercises: [
                  ProgrammeExerciseDraft(
                    id: 'bench',
                    exerciseId: 1,
                    exerciseRef: 'Bench Press',
                    sortOrder: 0,
                    sets: [
                      SetPrescriptionDraft(
                        id: 'set',
                        setIndex: 0,
                        setType: SetType.working,
                        prescribedRepsExact: 8,
                        prescribedWeightKg: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        final load = LoadProgrammeBuilderDraftUseCase(
          programmeRepository: repository,
        );
        final container = ProviderContainer(
          overrides: [
            AppProviders.loadProgrammeBuilderDraftUseCaseProvider
                .overrideWithValue(load),
            AppProviders.saveProgrammeBuilderDraftUseCaseProvider
                .overrideWithValue(
                  SaveProgrammeBuilderDraftUseCase(
                    programmeRepository: repository,
                  ),
                ),
          ],
        );
        addTearDown(container.dispose);
        final provider = AppProviders.programmeBuilderControllerProvider((
          mode: ProgrammeBuilderMode.edit,
          programmeId: programmeId,
        ));
        await container.read(provider.future);
        final block = container
            .read(provider)
            .requireValue
            .draft
            .trainingBlocks
            .single;
        expect(block.name, isEmpty);
        container
            .read(provider.notifier)
            .updateTrainingBlock(block.id, name: 'Base');
        final slots = container
            .read(provider)
            .requireValue
            .draft
            .weeks!
            .single
            .slots!;
        expect(slots[0].template!.id, isNot(slots[1].template!.id));
        final wednesday = slots[1].template!;
        final exercise = wednesday.exercises.single;
        container
            .read(provider.notifier)
            .updateTemplateExercise(
              wednesday.id,
              exercise.copyWith(
                sets: [
                  exercise.sets.single.copyWith(
                    prescribedRepsExact: 12,
                    prescribedWeightKg: 50.0,
                  ),
                ],
              ),
            );
        await container.read(provider.notifier).saveProgramme();
        final reloaded = await load.loadForEdit(programmeId);
        final savedSlots = reloaded.weeks!.single.slots!;
        expect(savedSlots[0].template!.id, isNot(savedSlots[1].template!.id));
        expect(
          savedSlots[0]
              .template!
              .exercises
              .single
              .sets
              .single
              .prescribedRepsExact,
          8,
        );
        expect(
          savedSlots[0]
              .template!
              .exercises
              .single
              .sets
              .single
              .prescribedWeightKg,
          40,
        );
        expect(
          savedSlots[1]
              .template!
              .exercises
              .single
              .sets
              .single
              .prescribedRepsExact,
          12,
        );
        expect(
          savedSlots[1]
              .template!
              .exercises
              .single
              .sets
              .single
              .prescribedWeightKg,
          50,
        );
      },
    );

    test('getProgramme returns null for unknown id', () async {
      final result = await repository.getProgramme('nonexistent');
      expect(result, isNull);
    });

    test(
      'saveProgramme persists expanded exercise and set rows from template data',
      () async {
        final programmeId = 'prog-1';
        final templateId = 'tmpl-1';
        final exerciseId = 'tmpl-ex-1';
        final setId = 'tmpl-set-1';

        final draft = ProgrammeDraft(
          id: programmeId,
          name: 'Test Programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.active,
          active: true,
          goalTags: {GoalTag.buildMuscle},
          equipment: {EquipmentTag.dumbbell},
          weeksTotal: 1,
          daysPerWeek: 1,
          sessionLengthMinutes: 45,
          templates: [
            ProgrammeWorkoutTemplateDraft(
              id: templateId,
              templateKey: 'day1',
              name: 'Day 1',
              sortOrder: 0,
              estimatedDurationMinutes: 45,
              exercises: [
                ProgrammeExerciseDraft(
                  id: exerciseId,
                  exerciseId: 101,
                  sortOrder: 0,
                  exerciseRole: ExerciseRole.primary,
                  notes: 'Go heavy',
                  sets: [
                    SetPrescriptionDraft(
                      id: setId,
                      setIndex: 0,
                      setType: SetType.working,
                      setIntent: SetIntent.hypertrophy,
                      prescribedRepsMin: 8,
                      prescribedRepsMax: 12,
                      prescribedWeightKg: 80.0,
                      restSeconds: 90,
                      loadingModel: LoadingModel.linear,
                      isCalibrationEstimate: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await repository.saveProgramme(draft);
        final aggregate = await repository.getProgramme(programmeId);

        expect(aggregate, isNotNull);
        expect(aggregate!.program.name, equals('Test Programme'));

        // Expanded weeks
        expect(aggregate.weeks, hasLength(1));
        expect(aggregate.weeks.first.weekNumber, equals(1));

        // Expanded workouts
        expect(aggregate.workouts, hasLength(1));
        expect(aggregate.workouts.first.name, equals('Day 1'));

        // Expanded exercises copied from template
        expect(aggregate.exercises, isNotEmpty);
        expect(aggregate.exercises.length, equals(1));
        final expandedExercise = aggregate.exercises.first;
        expect(expandedExercise.exerciseId, equals(101));
        expect(expandedExercise.exerciseRole, equals('primary'));
        expect(expandedExercise.notes, equals('Go heavy'));

        // Expanded exercise sets copied from template
        expect(aggregate.sets, isNotEmpty);
        expect(aggregate.sets.length, equals(1));
        final expandedSet = aggregate.sets.first;
        expect(expandedSet.prescribedRepsMin, equals(8));
        expect(expandedSet.prescribedRepsMax, equals(12));
        expect(expandedSet.prescribedWeightKg, equals(80.0));
        expect(expandedSet.restSeconds, equals(90));
        expect(expandedSet.setIndex, equals(0));
        expect(expandedSet.setType, equals('working'));
      },
    );

    test('saveProgramme second call replaces expanded rows', () async {
      final programmeId = 'prog-2';
      final templateId = 'tmpl-2';
      final exerciseId = 'tmpl-ex-2';
      final setId = 'tmpl-set-2';

      final draft = ProgrammeDraft(
        id: programmeId,
        name: 'Replaced Programme',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: ProgramStatus.active,
        active: false,
        goalTags: {GoalTag.increaseStrength},
        equipment: {EquipmentTag.barbell},
        weeksTotal: 1,
        daysPerWeek: 1,
        sessionLengthMinutes: 60,
        templates: [
          ProgrammeWorkoutTemplateDraft(
            id: templateId,
            templateKey: 'day1',
            name: 'Day 1',
            sortOrder: 0,
            estimatedDurationMinutes: 60,
            exercises: [
              ProgrammeExerciseDraft(
                id: exerciseId,
                exerciseId: 201,
                sortOrder: 0,
                exerciseRole: ExerciseRole.primary,
                sets: [
                  SetPrescriptionDraft(
                    id: setId,
                    setIndex: 0,
                    setType: SetType.working,
                    prescribedRepsMin: 5,
                    prescribedRepsMax: 5,
                    prescribedWeightKg: 100.0,
                    restSeconds: 120,
                    loadingModel: LoadingModel.linear,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await repository.saveProgramme(draft);

      // Second save with modified data
      final updatedDraft = ProgrammeDraft(
        id: programmeId,
        name: 'Replaced Programme Updated',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: ProgramStatus.active,
        active: false,
        goalTags: {GoalTag.increaseStrength},
        equipment: {EquipmentTag.barbell},
        weeksTotal: 1,
        daysPerWeek: 1,
        sessionLengthMinutes: 60,
        templates: [
          ProgrammeWorkoutTemplateDraft(
            id: templateId,
            templateKey: 'day1',
            name: 'Day 1',
            sortOrder: 0,
            estimatedDurationMinutes: 60,
            exercises: [
              ProgrammeExerciseDraft(
                id: exerciseId,
                exerciseId: 202,
                sortOrder: 0,
                exerciseRole: ExerciseRole.primary,
                sets: [
                  SetPrescriptionDraft(
                    id: setId,
                    setIndex: 0,
                    setType: SetType.working,
                    prescribedRepsMin: 3,
                    prescribedRepsMax: 3,
                    prescribedWeightKg: 120.0,
                    restSeconds: 150,
                    loadingModel: LoadingModel.linear,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await repository.saveProgramme(updatedDraft);
      final aggregate = await repository.getProgramme(programmeId);

      expect(aggregate, isNotNull);
      expect(aggregate!.program.name, equals('Replaced Programme Updated'));

      // Old expanded rows replaced
      expect(aggregate.exercises, hasLength(1));
      expect(aggregate.exercises.first.exerciseId, equals(202));
      expect(aggregate.sets, hasLength(1));
      expect(aggregate.sets.first.prescribedWeightKg, equals(120.0));
      expect(aggregate.sets.first.prescribedRepsMin, equals(3));

      // Verify only one set of expanded rows exists
      expect(aggregate.weeks, hasLength(1));
      expect(aggregate.workouts, hasLength(1));
    });

    test('archiveProgramme sets archived status', () async {
      final programmeId = 'prog-3';

      await repository.saveProgramme(
        ProgrammeDraft(
          id: programmeId,
          name: 'To Archive',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.active,
          active: false,
          goalTags: const <GoalTag>{},
          equipment: const <EquipmentTag>{},
          templates: [],
        ),
      );

      await repository.archiveProgramme(programmeId);
      final aggregate = await repository.getProgramme(programmeId);

      expect(aggregate, isNotNull);
      expect(aggregate!.program.status, equals('archived'));
    });

    test('deleteProgramme soft-deletes programme', () async {
      final programmeId = 'prog-4';

      await repository.saveProgramme(
        ProgrammeDraft(
          id: programmeId,
          name: 'To Delete',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.active,
          active: false,
          goalTags: const <GoalTag>{},
          equipment: const <EquipmentTag>{},
          templates: [],
        ),
      );

      await repository.deleteProgramme(programmeId);

      // Deleted programme should still be retrievable (soft-delete)
      final aggregate = await repository.getProgramme(programmeId);
      expect(aggregate, isNotNull);
      expect(aggregate!.program.deletedAt, isNotNull);
    });

    test('activateProgramme sets active and clears other active', () async {
      final firstId = 'prog-5a';
      final secondId = 'prog-5b';

      await repository.saveProgramme(
        ProgrammeDraft(
          id: firstId,
          name: 'First',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.active,
          active: true,
          goalTags: const <GoalTag>{},
          equipment: const <EquipmentTag>{},
          templates: [],
        ),
      );

      await repository.saveProgramme(
        ProgrammeDraft(
          id: secondId,
          name: 'Second',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.active,
          active: true,
          goalTags: const <GoalTag>{},
          equipment: const <EquipmentTag>{},
          templates: [],
        ),
      );

      await repository.activateProgramme(firstId);
      await repository.deactivateProgramme(secondId);

      final first = await repository.getProgramme(firstId);
      final second = await repository.getProgramme(secondId);

      expect(first!.program.active, isTrue);
      expect(second!.program.active, isFalse);
    });
  });

  group('transaction rollback', () {
    test(
      'injected failure during template insertion leaves no partial programme',
      () async {
        final injection = ThrowingTransactionFailureInjection(
          failOnOperationName: 'programme.insert_templates',
          failBefore: true,
        );
        final rollbackDb = AppDatabase(NativeDatabase.memory());
        final uuid = const Uuid();
        final rollbackRepo = DriftProgrammeRepository(
          programDao: ProgramDao(rollbackDb),
          programWorkoutTemplateDao: ProgramWorkoutTemplateDao(rollbackDb),
          programTemplateExerciseDao: ProgramTemplateExerciseDao(rollbackDb),
          programTemplateExerciseSetDao: ProgramTemplateExerciseSetDao(
            rollbackDb,
          ),
          programWeekDao: ProgramWeekDao(rollbackDb),
          programWorkoutDao: ProgramWorkoutDao(rollbackDb),
          programExerciseDao: ProgramExerciseDao(rollbackDb),
          programExerciseSetDao: ProgramExerciseSetDao(rollbackDb),
          programRevisionDao: ProgramRevisionDao(rollbackDb),
          transactionExecutor: DriftTransactionExecutor(
            database: rollbackDb,
            failureInjection: injection,
          ),
          uuid: uuid,
        );

        try {
          await rollbackRepo.saveProgramme(
            ProgrammeDraft(
              id: 'rollback-test-1',
              name: 'Rollback Test',
              source: WorkoutSource.manual,
              creationMethod: CreationMethod.manual,
              status: ProgramStatus.draft,
              active: false,
              goalTags: const <GoalTag>{},
              equipment: const <EquipmentTag>{},
              templates: [
                ProgrammeWorkoutTemplateDraft(
                  id: 't1',
                  templateKey: 't1',
                  name: 'Push Day',
                  sortOrder: 0,
                  exercises: [
                    ProgrammeExerciseDraft(
                      id: 'e1',
                      exerciseId: 1,
                      sortOrder: 0,
                      sets: [
                        SetPrescriptionDraft(
                          id: 's1',
                          setIndex: 0,
                          setType: SetType.working,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
          fail('Expected exception');
        } on TransactionExecutionFailure {
          // expected — rollback should have occurred
        }

        final programme = await rollbackRepo.getProgramme('rollback-test-1');
        expect(programme, isNull);

        await rollbackDb.close();
      },
    );

    test(
      'injected failure during expanded row insertion leaves no partial expanded hierarchy',
      () async {
        final injection = ThrowingTransactionFailureInjection(
          failOnOperationName: 'programme.insert_expanded',
          failBefore: true,
        );
        final rollbackDb = AppDatabase(NativeDatabase.memory());
        final uuid = const Uuid();
        final rollbackRepo = DriftProgrammeRepository(
          programDao: ProgramDao(rollbackDb),
          programWorkoutTemplateDao: ProgramWorkoutTemplateDao(rollbackDb),
          programTemplateExerciseDao: ProgramTemplateExerciseDao(rollbackDb),
          programTemplateExerciseSetDao: ProgramTemplateExerciseSetDao(
            rollbackDb,
          ),
          programWeekDao: ProgramWeekDao(rollbackDb),
          programWorkoutDao: ProgramWorkoutDao(rollbackDb),
          programExerciseDao: ProgramExerciseDao(rollbackDb),
          programExerciseSetDao: ProgramExerciseSetDao(rollbackDb),
          programRevisionDao: ProgramRevisionDao(rollbackDb),
          transactionExecutor: DriftTransactionExecutor(
            database: rollbackDb,
            failureInjection: injection,
          ),
          uuid: uuid,
        );

        try {
          await rollbackRepo.saveProgramme(
            ProgrammeDraft(
              id: 'rollback-test-2',
              name: 'Rollback Test 2',
              source: WorkoutSource.manual,
              creationMethod: CreationMethod.manual,
              status: ProgramStatus.draft,
              active: false,
              goalTags: const <GoalTag>{},
              equipment: const <EquipmentTag>{},
              templates: [],
            ),
          );
          fail('Expected exception');
        } on TransactionExecutionFailure {
          // expected
        }

        final programme = await rollbackRepo.getProgramme('rollback-test-2');
        expect(programme, isNull);

        await rollbackDb.close();
      },
    );

    test('injected failure after root write rolls back root', () async {
      final injection = ThrowingTransactionFailureInjection(
        failOnOperationName: 'programme.insert_templates',
        failBefore: true,
      );
      final rollbackDb = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final rollbackRepo = DriftProgrammeRepository(
        programDao: ProgramDao(rollbackDb),
        programWorkoutTemplateDao: ProgramWorkoutTemplateDao(rollbackDb),
        programTemplateExerciseDao: ProgramTemplateExerciseDao(rollbackDb),
        programTemplateExerciseSetDao: ProgramTemplateExerciseSetDao(
          rollbackDb,
        ),
        programWeekDao: ProgramWeekDao(rollbackDb),
        programWorkoutDao: ProgramWorkoutDao(rollbackDb),
        programExerciseDao: ProgramExerciseDao(rollbackDb),
        programExerciseSetDao: ProgramExerciseSetDao(rollbackDb),
        programRevisionDao: ProgramRevisionDao(rollbackDb),
        transactionExecutor: DriftTransactionExecutor(
          database: rollbackDb,
          failureInjection: injection,
        ),
        uuid: uuid,
      );

      try {
        await rollbackRepo.saveProgramme(
          ProgrammeDraft(
            id: 'rollback-test-3',
            name: 'Rollback Root',
            source: WorkoutSource.manual,
            creationMethod: CreationMethod.manual,
            status: ProgramStatus.draft,
            active: false,
            goalTags: const <GoalTag>{},
            equipment: const <EquipmentTag>{},
            templates: [
              ProgrammeWorkoutTemplateDraft(
                id: 't1',
                templateKey: 't1',
                name: 'Push Day',
                sortOrder: 0,
                exercises: [],
              ),
            ],
          ),
        );
        fail('Expected exception');
      } on TransactionExecutionFailure {
        // expected
      }

      // Root should also be rolled back
      final programme = await rollbackRepo.getProgramme('rollback-test-3');
      expect(programme, isNull);

      await rollbackDb.close();
    });
  });
}
