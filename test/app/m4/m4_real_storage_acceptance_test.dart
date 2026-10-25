import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
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
    'standalone session logs custom exercise offline, corrects and repeats its immutable snapshot',
    () async {
      final network = _RejectNetwork();
      await HttpOverrides.runWithHttpOverrides(() async {
        final exerciseRepository = container.read(
          AppProviders.exerciseRepositoryProvider,
        );
        final exerciseId = await exerciseRepository.createCustomExercise(
          const CustomExerciseSeed(
            name: 'Local press',
            muscleGroups: {BodymapBucket.chest},
            modality: ExerciseModality.strength,
            loggingType: ExerciseLoggingType.repsWeight,
            steps: ['Press smoothly.'],
          ),
        );
        final historyProvider = AppProviders.workoutHistoryControllerProvider;
        final exerciseHistoryProvider =
            WorkoutHistoryProviders.exerciseHistoryProvider(exerciseId);
        final historySubscription = container.listen(
          historyProvider,
          (_, _) {},
        );
        final exerciseHistorySubscription = container.listen(
          exerciseHistoryProvider,
          (_, _) {},
        );
        addTearDown(historySubscription.close);
        addTearDown(exerciseHistorySubscription.close);
        expect((await container.read(historyProvider.future)).items, isEmpty);
        expect(await container.read(exerciseHistoryProvider.future), isEmpty);
        final start = container.read(
          AppProviders.startWorkoutSessionUseCaseProvider,
        );
        final session = await start.startStandalone();
        expect(session.exercises, isEmpty);
        final provider = AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        ));
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        await controller.resumeRecoveredSession();
        await controller.addExercises([
          ExerciseReference(
            exerciseId: exerciseId,
            name: 'Local press',
            modality: ExerciseModality.strength.dbValue,
            loggingType: ExerciseLoggingType.repsWeight.dbValue,
            isCustom: true,
          ),
        ]);
        var exercise = container
            .read(provider)
            .requireValue
            .session!
            .exercises
            .single;
        final set = exercise.sets.single.copyWith(
          actualReps: 8,
          actualWeightKg: 40,
          actualRpe: 8,
          actualRir: 2,
          notes: 'Private set note',
        );
        await controller.updateSet(
          exerciseId: exercise.id,
          setId: set.id,
          updatedSet: set,
        );
        await controller.toggleSetCompleted(
          exerciseId: exercise.id,
          setId: set.id,
          completed: true,
        );
        await controller.saveProgress();
        await controller.completeWorkout();
        expect(
          (await container.read(historyProvider.future)).items.single.sessionId,
          session.sessionId,
        );
        expect(
          (await container.read(
            exerciseHistoryProvider.future,
          )).single.sessionId,
          session.sessionId,
        );
        expect(
          container.read(provider).requireValue.session!.status,
          WorkoutSessionStatus.completed,
        );
        final history = container.read(
          AppProviders.workoutHistoryRepositoryProvider,
        );
        var detail = (await history.getSessionDetail(session.sessionId))!;
        expect(detail.exercises.single.sets.single.actualRir, 2);
        final expected = detail.exercises.single.sets.single;
        await history.correctSession(
          sessionId: session.sessionId,
          corrections: [
            WorkoutHistorySetCorrection(
              expected: expected,
              actualReps: 9,
              actualWeightKg: 42,
              actualRpe: 8,
              actualRir: 2,
              notes: 'Corrected private note',
            ),
          ],
        );
        await exerciseRepository.updateCustomExercise(
          exerciseId: exerciseId,
          seed: const CustomExerciseSeed(
            name: 'Renamed press',
            muscleGroups: {BodymapBucket.chest},
            modality: ExerciseModality.strength,
          ),
        );
        detail = (await history.getSessionDetail(session.sessionId))!;
        expect(detail.exercises.single.exerciseName, 'Local press');
        expect(
          (await history.listExerciseHistory(exerciseId)).single.sessionId,
          session.sessionId,
        );
        final repeated = await start.repeatCompleted(session.sessionId);
        exercise = repeated.exercises.single;
        expect(repeated.sessionId, isNot(session.sessionId));
        expect(exercise.exerciseName, 'Local press');
        expect(exercise.sets.single.id, isNot(expected.id));
        expect(exercise.sets.single.actualReps, isNull);
        expect(exercise.sets.single.actualWeightKg, isNull);
        expect(exercise.sets.single.prescribedWeightKg, 42);
        expect(exercise.sets.single.prescribedRepsExact, 9);
        expect(exercise.sets.single.notes, isNull);
        expect(exercise.sourceProgramExerciseId, isNull);
        expect(repeated.programId, isNull);
        expect(
          (await history.getSessionDetail(
            session.sessionId,
          ))!.exercises.single.sets.single.actualReps,
          9,
        );
        expect(network.attempts, 0);
      }, network);
    },
  );

  test(
    'standalone start cannot replace an active session and repeat rejects an unfinished session',
    () async {
      final start = container.read(
        AppProviders.startWorkoutSessionUseCaseProvider,
      );
      final active = await start.startStandalone();
      await expectLater(start.startStandalone(), throwsA(anything));
      await expectLater(
        start.repeatCompleted(active.sessionId),
        throwsStateError,
      );
      expect(
        (await container
                .read(AppProviders.workoutSessionRepositoryProvider)
                .getActiveSession())!
            .session
            .id,
        active.sessionId,
      );
    },
  );
}

class _RejectNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Network is unavailable during offline acceptance.');
  }
}
