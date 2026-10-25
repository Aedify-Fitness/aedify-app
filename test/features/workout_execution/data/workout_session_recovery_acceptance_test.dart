import 'dart:io';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/core/db/transactions/drift_transaction_executor.dart';
import 'package:aedify/core/db/transactions/transaction_failure_injection.dart';
import 'package:aedify/core/db/transactions/transaction_execution_failure.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/features/workout_execution/data/drift_workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/test_support/transactions/throwing_transaction_failure_injection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

abstract final class _RecoveryFixtures {
  static DriftWorkoutSessionRepository repository(
    AppDatabase db, {
    TransactionFailureInjection? failureInjection,
  }) => DriftWorkoutSessionRepository(
    workoutSessionDao: WorkoutSessionDao(db),
    workoutSessionExerciseDao: WorkoutSessionExerciseDao(db),
    setLogDao: SetLogDao(db),
    transactionExecutor: DriftTransactionExecutor(
      database: db,
      failureInjection: failureInjection,
    ),
  );

  static WorkoutSessionDraft draft() => WorkoutSessionDraft(
    id: 'session',
    name: 'Offline session',
    source: SessionSource.standalone,
    startedAt: DateTime(2026, 10, 24),
    status: WorkoutSessionStatus.inProgress,
    notes: 'Session note',
    exercises: [
      WorkoutSessionExerciseDraft(
        id: 'exercise',
        exerciseId: 7,
        exerciseNameSnapshot: 'Outdoor run',
        sortOrder: 0,
        loggingType: ExerciseLoggingType.duration,
        setLogs: [
          SetLogDraft(
            id: 'set',
            exerciseId: 7,
            setIndex: 0,
            performedAt: DateTime(2026, 10, 24),
            setType: SetType.warmup,
            prescribedDurationSeconds: 90,
            prescribedDistanceMeters: 300,
            prescribedRir: 2,
            prescribedRpeMin: 6,
            prescribedRpeMax: 8,
            actualDurationSeconds: 95,
            actualDistanceMeters: 310,
            actualRpe: 7.5,
            actualRir: 3,
            notes: 'Set note',
            completed: true,
          ),
        ],
      ),
    ],
  );
}

void main() {
  test(
    'real SQLite reopen retains actuals, prescriptions, notes and modality',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workout_recovery_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(p.join(directory.path, 'workout.sqlite'));
      final original = AppDatabase(NativeDatabase(file));
      final repo = _RecoveryFixtures.repository(original);
      await repo.startSession(_RecoveryFixtures.draft());
      final first = (await repo.getActiveSession())!;
      const mapper = WorkoutRunnerMapper();
      final edited = mapper.toViewData(first).copyWith(notes: 'Updated note');
      await repo.saveSessionProgress(mapper.toDraft(edited));
      await original.close();

      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final recovered = (await _RecoveryFixtures.repository(
        reopened,
      ).getActiveSession())!;
      final view = mapper.toViewData(recovered);
      expect(view.notes, 'Updated note');
      expect(view.exercises.single.loggingType, ExerciseLoggingType.duration);
      final set = view.exercises.single.sets.single;
      expect(set.setType, SetType.warmup);
      expect(set.prescribedDurationSeconds, 90);
      expect(set.prescribedDistanceMeters, 300);
      expect(set.prescribedRir, 2);
      expect(set.actualDurationSeconds, 95);
      expect(set.actualDistanceMeters, 310);
      expect(set.actualRpe, 7.5);
      expect(set.actualRir, 3);
      expect(set.notes, 'Set note');
      expect(set.completed, isTrue);
    },
  );

  test(
    'completion failure after real writes rolls back and supports one retry',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workout_rollback_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(p.join(directory.path, 'workout.sqlite'));
      final original = AppDatabase(NativeDatabase(file));
      final normal = _RecoveryFixtures.repository(original);
      await normal.startSession(_RecoveryFixtures.draft());
      final failing = _RecoveryFixtures.repository(
        original,
        failureInjection: ThrowingTransactionFailureInjection(
          failOnOperationName: 'session.complete',
          failBefore: false,
        ),
      );
      await expectLater(
        failing.completeSession(
          id: 'session',
          completedAt: DateTime(2026, 10, 24, 1),
          durationSeconds: 3600,
        ),
        throwsA(isA<TransactionExecutionFailure>()),
      );
      await original.close();

      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final repo = _RecoveryFixtures.repository(reopened);
      final recovered = (await repo.getActiveSession())!;
      expect(recovered.session.status, WorkoutSessionStatus.inProgress.dbValue);
      expect(recovered.session.completedAt, isNull);
      expect(recovered.setLogs.single.actualRpe, 7.5);
      expect(await WorkoutSessionDao(reopened).getCompletedSessions(), isEmpty);
      await repo.completeSession(
        id: 'session',
        completedAt: DateTime(2026, 10, 24, 1),
        durationSeconds: 3600,
      );
      expect(await repo.getActiveSession(), isNull);
      expect((await reopened.select(reopened.workoutSessions).get()).length, 1);
      expect((await repo.getSession('session'))!.session.status, 'completed');
      expect((await reopened.select(reopened.setLogs).get()).length, 1);
    },
  );
}
