import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'OS process loss preserves committed workout progress',
    (tester) async {
      const phase = String.fromEnvironment(
        'M4_RECOVERY_PHASE',
        defaultValue: 'recover',
      );
      final originalHttp = HttpOverrides.current;
      final blockedNetwork = _M4BlockedNetwork();
      HttpOverrides.global = blockedNetwork;
      addTearDown(() {
        HttpOverrides.global = originalHttp;
      });
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, 'aedify_m4_process.sqlite'));
      final marker = File(p.join(directory.path, 'aedify_m4_process_ready'));
      if (phase == 'seed') {
        if (await file.exists()) {
          await file.delete();
        }
        if (await marker.exists()) {
          await marker.delete();
        }
      }
      final db = AppDatabase(NativeDatabase(file));
      final container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('M4 lifecycle acceptance')),
        ),
      );
      final repository = container.read(
        AppProviders.workoutSessionRepositoryProvider,
      );
      if (phase == 'seed') {
        final exerciseId = await container
            .read(AppProviders.exerciseRepositoryProvider)
            .createCustomExercise(
              const CustomExerciseSeed(
                name: 'Recovery exercise',
                muscleGroups: {BodymapBucket.chest},
                modality: ExerciseModality.strength,
                loggingType: ExerciseLoggingType.repsWeight,
                steps: ['Test exercise.'],
              ),
            );
        await container
            .read(AppProviders.startWorkoutSessionUseCaseProvider)
            .startStandalone();
        final provider = AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        ));
        final subscription = container.listen(provider, (_, _) {});
        await container.read(provider.future);
        final controller = container.read(provider.notifier);
        await controller.resumeRecoveredSession();
        await controller.addExercises([
          ExerciseReference(
            exerciseId: exerciseId,
            name: 'Recovery exercise',
            modality: 'strength',
            loggingType: ExerciseLoggingType.repsWeight.dbValue,
          ),
        ]);
        final exercise = container
            .read(provider)
            .requireValue
            .session!
            .exercises
            .single;
        await controller.updateSet(
          exerciseId: exercise.id,
          setId: exercise.sets.single.id,
          updatedSet: exercise.sets.single.copyWith(
            actualReps: 7,
            actualWeightKg: 35,
            actualRpe: 8,
            actualRir: 2,
            notes: 'Local recovery note',
          ),
        );
        await controller.toggleSetCompleted(
          exerciseId: exercise.id,
          setId: exercise.sets.single.id,
          completed: true,
        );
        await controller.pauseWorkout();
        final persisted = await repository.getActiveSession();
        expect(persisted!.setLogs.single.actualReps, 7);
        await marker.writeAsString('committed', flush: true);
        // The host deliberately terminates the OS process after this marker.
        // No database/provider teardown runs before the kill.
        while (await marker.exists()) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        subscription.close();
      } else {
        expect(
          await marker.exists(),
          isTrue,
          reason: 'Run the seed phase and terminate its OS process first.',
        );
        final recovered = await repository.getActiveSession();
        expect(recovered, isNotNull);
        expect(
          recovered!.session.status,
          WorkoutSessionStatus.inProgress.dbValue,
        );
        expect(
          recovered.exercises.single.exerciseNameSnapshot,
          'Recovery exercise',
        );
        expect(recovered.setLogs.single.actualReps, 7);
        expect(recovered.setLogs.single.actualWeightKg, 35);
        expect(recovered.setLogs.single.actualRpe, 8);
        expect(recovered.setLogs.single.actualRir, 2);
        expect(recovered.setLogs.single.notes, 'Local recovery note');
        expect(recovered.setLogs.single.completed, isTrue);
        await repository.completeSession(
          id: recovered.session.id,
          completedAt: DateTime.now(),
          durationSeconds: 60,
        );
        expect(await repository.getActiveSession(), isNull);
        expect(
          (await container
                  .read(AppProviders.workoutHistoryRepositoryProvider)
                  .listCompletedSessions())
              .single
              .sessionId,
          recovered.session.id,
        );
        await marker.delete();
      }
      expect(blockedNetwork.attempts, 0);
      container.dispose();
      await db.close();
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}

class _M4BlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Network is blocked during M4 offline acceptance.');
  }
}
