import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_template_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_exercise_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [AppProviders.appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'saved workout captures duration, distance, RIR and saved logging type durably',
    () async {
      final exerciseRepository = container.read(
        AppProviders.exerciseRepositoryProvider,
      );
      final exerciseId = await _StartFixture.createExercise(
        container,
        'Local interval',
        ExerciseLoggingType.duration,
      );
      final savedRepository = container.read(
        AppProviders.savedWorkoutRepositoryProvider,
      );
      await savedRepository.saveSavedWorkout(
        _StartFixture.savedWorkout(exerciseId),
      );
      // A saved occurrence owns its logging mode even after library metadata changes.
      await exerciseRepository.updateCustomExercise(
        exerciseId: exerciseId,
        seed: const CustomExerciseSeed(
          name: 'Local interval',
          muscleGroups: {BodymapBucket.quads},
          modality: ExerciseModality.cardio,
          loggingType: ExerciseLoggingType.repsOnly,
        ),
      );
      final session = await container
          .read(AppProviders.startWorkoutSessionUseCaseProvider)
          .startFromSavedWorkout('saved-workout');
      final exercise = session.exercises.single;
      final set = exercise.sets.single;
      expect(exercise.loggingType, ExerciseLoggingType.duration);
      expect(exercise.sourceSavedWorkoutExerciseId, 'saved-exercise');
      expect(exercise.id, isNot('saved-exercise'));
      expect(set.id, isNot('saved-set'));
      expect(set.prescribedDurationSeconds, 120);
      expect(set.prescribedDistanceMeters, 500);
      expect(set.prescribedRir, 3);
      expect(set.actualDurationSeconds, isNull);
      expect(set.actualDistanceMeters, isNull);
      expect(set.actualRpe, 7);
      expect(set.actualRir, 3);

      await savedRepository.saveSavedWorkout(
        _StartFixture.savedWorkout(
          exerciseId,
          duration: 180,
          distance: 900,
          rir: 1,
        ),
      );
      final restored = (await container
          .read(AppProviders.workoutSessionRepositoryProvider)
          .getSession(session.sessionId))!;
      expect(
        restored.exercises.single.loggingType,
        ExerciseLoggingType.duration.dbValue,
      );
      expect(restored.setLogs.single.prescribedDurationSeconds, 120);
      expect(restored.setLogs.single.prescribedDistanceMeters, 500);
      expect(restored.setLogs.single.prescribedRir, 3);
      expect(restored.setLogs.single.actualRpe, 7);
      expect(restored.setLogs.single.actualRir, 3);
    },
  );

  test(
    'programme session captures time/distance/RIR and library logging mode at launch',
    () async {
      final exerciseId = await _StartFixture.createExercise(
        container,
        'Programme interval',
        ExerciseLoggingType.duration,
      );
      final programmeRepository = container.read(
        AppProviders.programmeRepositoryProvider,
      );
      await programmeRepository.saveProgramme(
        ProgrammeDraft(
          id: 'programme',
          name: 'Local programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.inactive,
          active: false,
          goalTags: const {},
          equipment: const {},
          weeksTotal: 1,
          daysPerWeek: 1,
          slotDayIndices: const [0],
          slotTemplateIds: const ['template'],
          templates: [
            ProgrammeWorkoutTemplateDraft(
              id: 'template',
              templateKey: 'interval',
              name: 'Interval day',
              sortOrder: 0,
              exercises: [
                ProgrammeExerciseDraft(
                  id: 'template-exercise',
                  exerciseId: exerciseId,
                  sortOrder: 0,
                  sets: const [
                    SetPrescriptionDraft(
                      id: 'template-set',
                      setIndex: 0,
                      setType: SetType.working,
                      durationSeconds: 90,
                      distanceMeters: 400,
                      prescribedRir: 2,
                      restSeconds: 30,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      final programme = (await programmeRepository.getProgramme('programme'))!;
      final workout = programme.workouts.single;
      final session = await container
          .read(AppProviders.startWorkoutSessionUseCaseProvider)
          .startFromProgramWorkout(
            programId: 'programme',
            programWorkoutId: workout.id,
          );
      expect(session.source, SessionSource.program);
      final exercise = session.exercises.single;
      final set = exercise.sets.single;
      expect(exercise.loggingType, ExerciseLoggingType.duration);
      expect(exercise.sourceProgramExerciseId, programme.exercises.single.id);
      expect(set.prescribedDurationSeconds, 90);
      expect(set.prescribedDistanceMeters, 400);
      expect(set.prescribedRir, 2);
      expect(set.restSeconds, 30);
      expect(set.actualDurationSeconds, isNull);
      await container
          .read(AppProviders.exerciseRepositoryProvider)
          .updateCustomExercise(
            exerciseId: exerciseId,
            seed: const CustomExerciseSeed(
              name: 'Changed later',
              muscleGroups: {BodymapBucket.quads},
              modality: ExerciseModality.cardio,
              loggingType: ExerciseLoggingType.repsOnly,
            ),
          );
      await (database.update(
        database.programExerciseSets,
      )..where((t) => t.id.equals(programme.sets.single.id))).write(
        const ProgramExerciseSetsCompanion(
          durationSeconds: Value(180),
          distanceMeters: Value(800),
          prescribedRir: Value(1),
        ),
      );
      final restored = (await container
          .read(AppProviders.workoutSessionRepositoryProvider)
          .getSession(session.sessionId))!;
      expect(
        restored.exercises.single.exerciseNameSnapshot,
        'Programme interval',
      );
      expect(
        restored.exercises.single.loggingType,
        ExerciseLoggingType.duration.dbValue,
      );
      expect(restored.setLogs.single.prescribedDurationSeconds, 90);
      expect(restored.setLogs.single.prescribedDistanceMeters, 400);
      expect(restored.setLogs.single.prescribedRir, 2);
    },
  );

  test(
    'repeat splits swapped logs, keeps prescriptions and creates independent clean identities',
    () async {
      final originalId = await _StartFixture.createExercise(
        container,
        'Original press',
        ExerciseLoggingType.repsWeight,
      );
      final replacementId = await _StartFixture.createExercise(
        container,
        'Replacement interval',
        ExerciseLoggingType.duration,
      );
      final companionId = await _StartFixture.createExercise(
        container,
        'Companion movement',
        ExerciseLoggingType.repsOnly,
      );
      await _StartFixture.seedMixedCompletedSession(
        database,
        originalId,
        replacementId,
        companionId,
      );
      final previousSession = await (database.select(
        database.workoutSessions,
      )..where((t) => t.id.equals('previous'))).getSingle();
      final previousExercises = await database
          .select(database.workoutSessionExercises)
          .get();
      final previousLogs = await database.select(database.setLogs).get();
      final repeated = await container
          .read(AppProviders.startWorkoutSessionUseCaseProvider)
          .repeatCompleted('previous');
      expect(repeated.sessionId, isNot('previous'));
      expect(repeated.source, SessionSource.standalone);
      expect(repeated.programId, isNull);
      expect(repeated.programWorkoutId, isNull);
      expect(repeated.savedWorkoutId, isNull);
      expect(repeated.notes, isNull);
      expect(
        repeated.exercises.map((exercise) => exercise.exerciseId).toSet(),
        {originalId, replacementId, companionId},
      );
      final oldIds = previousExercises.map((e) => e.id).toSet();
      final oldSetIds = previousLogs.map((set) => set.id).toSet();
      final groupIds = repeated.exercises.map((e) => e.supersetGroupId).toSet();
      expect(groupIds, hasLength(1));
      expect(groupIds.single, isNot('previous-group'));
      for (final exercise in repeated.exercises) {
        expect(oldIds.contains(exercise.id), isFalse);
        expect(exercise.sourceProgramExerciseId, isNull);
        expect(exercise.sourceSavedWorkoutExerciseId, isNull);
        final set = exercise.sets.single;
        expect(set.exerciseId, exercise.exerciseId);
        expect(oldSetIds.contains(set.id), isFalse);
        expect(set.setIndex, 0);
        expect(set.actualReps, isNull);
        expect(set.actualWeightKg, isNull);
        expect(set.actualDurationSeconds, isNull);
        expect(set.actualDistanceMeters, isNull);
        final initialRpe = SetEffort.initialRpe(
          rir: set.prescribedRir,
          rpeMin: set.prescribedRpeMin,
          rpeMax: set.prescribedRpeMax,
        );
        expect(set.actualRpe, initialRpe);
        expect(set.actualRir, SetEffort.rirFromRpe(initialRpe));
        expect(set.notes, isNull);
        expect(set.completed, isFalse);
        expect(set.skipped, isFalse);
      }
      final original = repeated.exercises.singleWhere(
        (e) => e.exerciseId == originalId,
      );
      expect(original.loggingType, ExerciseLoggingType.repsWeight);
      expect(original.sets.single.setType, SetType.working);
      expect(original.sets.single.prescribedRepsMin, 6);
      expect(original.sets.single.prescribedRepsMax, 10);
      expect(original.sets.single.prescribedRepsExact, isNull);
      expect(original.sets.single.prescribedWeightKg, 80);
      expect(original.sets.single.prescribedRir, 2);
      final replacement = repeated.exercises.singleWhere(
        (e) => e.exerciseId == replacementId,
      );
      expect(replacement.exerciseName, 'Recorded replacement snapshot');
      expect(replacement.loggingType, ExerciseLoggingType.duration);
      expect(replacement.sets.single.prescribedDurationSeconds, 75);
      expect(replacement.sets.single.prescribedDistanceMeters, 500);
      expect(
        repeated.exercises
            .singleWhere((e) => e.exerciseId == companionId)
            .sets
            .single
            .setType,
        SetType.warmup,
      );
      final persisted = (await container
          .read(AppProviders.workoutSessionRepositoryProvider)
          .getSession(repeated.sessionId))!;
      expect(
        persisted.setLogs.every(
          (set) => !set.isPr && set.estimated1rmKg == null,
        ),
        isTrue,
      );
      expect(
        (await (database.select(
          database.workoutSessions,
        )..where((t) => t.id.equals('previous'))).getSingle()),
        previousSession,
      );
      expect(
        await (database.select(
          database.workoutSessionExercises,
        )..where((t) => t.workoutSessionId.equals('previous'))).get(),
        previousExercises,
      );
      expect(
        await (database.select(
          database.setLogs,
        )..where((t) => t.id.isIn(oldSetIds))).get(),
        unorderedEquals(previousLogs),
      );
    },
  );
}

class _StartFixture {
  _StartFixture._();

  static Future<int> createExercise(
    ProviderContainer container,
    String name,
    ExerciseLoggingType type,
  ) => container
      .read(AppProviders.exerciseRepositoryProvider)
      .createCustomExercise(
        CustomExerciseSeed(
          name: name,
          muscleGroups: const {BodymapBucket.quads},
          modality: type == ExerciseLoggingType.duration
              ? ExerciseModality.cardio
              : ExerciseModality.strength,
          loggingType: type,
        ),
      );

  static SavedWorkoutDraft savedWorkout(
    int exerciseId, {
    int duration = 120,
    double distance = 500,
    int rir = 3,
  }) => SavedWorkoutDraft(
    id: 'saved-workout',
    name: 'Local interval session',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: SavedWorkoutStatus.active,
    goalTags: const {},
    equipment: const {},
    exercises: [
      SavedWorkoutExerciseDraft(
        id: 'saved-exercise',
        exerciseId: exerciseId,
        exerciseRef: 'Saved occurrence name',
        loggingType: ExerciseLoggingType.duration.dbValue,
        sortOrder: 0,
        sets: [
          SetPrescriptionDraft(
            id: 'saved-set',
            setIndex: 0,
            setType: SetType.working,
            durationSeconds: duration,
            distanceMeters: distance,
            prescribedRir: rir,
          ),
        ],
      ),
    ],
  );

  static Future<void> seedMixedCompletedSession(
    AppDatabase database,
    int originalId,
    int replacementId,
    int companionId,
  ) async {
    final at = DateTime(2026, 10, 23, 8);
    await database
        .into(database.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: 'previous',
            source: 'program',
            name: 'Recorded session',
            startedAt: at,
            completedAt: Value(at.add(const Duration(hours: 1))),
            status: 'completed',
            programId: const Value('source-program'),
            programWorkoutId: const Value('source-workout'),
            savedWorkoutId: const Value('source-saved'),
            notes: const Value('Private session note'),
            createdAt: at,
            updatedAt: at,
          ),
        );
    for (final (id, exerciseId, name, type, order) in [
      ('mixed', replacementId, 'Recorded replacement snapshot', 'duration', 0),
      ('companion', companionId, 'Recorded companion snapshot', 'repsOnly', 1),
    ]) {
      await database
          .into(database.workoutSessionExercises)
          .insert(
            WorkoutSessionExercisesCompanion.insert(
              id: id,
              workoutSessionId: 'previous',
              exerciseId: exerciseId,
              exerciseNameSnapshot: name,
              sortOrder: order,
              loggingType: Value(type),
              sourceProgramExerciseId: Value('source-$id'),
              sourceSavedWorkoutExerciseId: Value('saved-$id'),
              supersetGroupId: const Value('previous-group'),
              restBetweenExercisesSeconds: const Value(15),
            ),
          );
    }
    await database
        .into(database.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'original-log',
            workoutSessionExerciseId: 'mixed',
            exerciseId: originalId,
            performedAt: at,
            setIndex: 0,
            setType: const Value('working'),
            prescribedRepsMin: const Value(6),
            prescribedRepsMax: const Value(10),
            prescribedWeightKg: const Value(80),
            prescribedRir: const Value(2),
            actualReps: const Value(8),
            actualWeightKg: const Value(85),
            actualRpe: const Value(8),
            actualRir: const Value(2),
            notes: const Value('Private original actuals'),
            completed: const Value(true),
            isPr: const Value(true),
            estimated1rmKg: const Value(108),
            createdAt: at,
            updatedAt: at,
          ),
        );
    await database
        .into(database.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'replacement-log',
            workoutSessionExerciseId: 'mixed',
            exerciseId: replacementId,
            performedAt: at,
            setIndex: 1,
            actualDurationSeconds: const Value(75),
            actualDistanceMeters: const Value(500),
            actualRpe: const Value(7),
            notes: const Value('Private replacement actuals'),
            completed: const Value(true),
            createdAt: at,
            updatedAt: at,
          ),
        );
    await database
        .into(database.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'companion-log',
            workoutSessionExerciseId: 'companion',
            exerciseId: companionId,
            performedAt: at,
            setIndex: 0,
            setType: const Value('warmup'),
            actualReps: const Value(12),
            completed: const Value(true),
            createdAt: at,
            updatedAt: at,
          ),
        );
  }
}
