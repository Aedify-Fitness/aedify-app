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
      database: db,
      programDao: ProgramDao(db),
      programWorkoutTemplateDao: ProgramWorkoutTemplateDao(db),
      programTemplateExerciseDao: ProgramTemplateExerciseDao(db),
      programTemplateExerciseSetDao: ProgramTemplateExerciseSetDao(db),
      programWeekDao: ProgramWeekDao(db),
      programWorkoutDao: ProgramWorkoutDao(db),
      programExerciseDao: ProgramExerciseDao(db),
      programExerciseSetDao: ProgramExerciseSetDao(db),
      programRevisionDao: ProgramRevisionDao(db),
      uuid: uuid,
    );
  });

  tearDown(() {
    db.close();
  });

  group('DriftProgrammeRepository', () {
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
}
