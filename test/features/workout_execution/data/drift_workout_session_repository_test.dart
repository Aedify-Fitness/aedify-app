import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/core/db/transactions/transaction_execution_failure.dart';
import 'package:aedify/core/db/transactions/drift_transaction_executor.dart';
import 'package:aedify/features/workout_execution/data/drift_workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

void main() {
  late AppDatabase db;
  late WorkoutSessionDao sessionDao;
  late DriftWorkoutSessionRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sessionDao = WorkoutSessionDao(db);
    repository = DriftWorkoutSessionRepository(
      workoutSessionDao: sessionDao,
      workoutSessionExerciseDao: WorkoutSessionExerciseDao(db),
      setLogDao: SetLogDao(db),
      transactionExecutor: DriftTransactionExecutor(database: db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('saveSessionProgress', () {
    test(
      'does not resurrect a completed session back to in progress',
      () async {
        final startedAt = DateTime(2026, 7, 4, 8);
        final completedAt = DateTime(2026, 7, 4, 9);
        final draft = _buildDraft(startedAt: startedAt);

        await repository.startSession(draft);
        await repository.completeSession(
          id: draft.id,
          completedAt: completedAt,
          durationSeconds: 3600,
        );

        final updatedDraft = WorkoutSessionDraft(
          id: draft.id,
          source: draft.source,
          name: 'Changed Name After Completion',
          startedAt: draft.startedAt,
          status: WorkoutSessionStatus.inProgress,
          exercises: draft.exercises,
          savedWorkoutId: draft.savedWorkoutId,
          notes: 'should not persist',
        );

        await expectLater(
          repository.saveSessionProgress(updatedDraft),
          throwsA(isA<TransactionExecutionFailure>()),
        );

        final session = await sessionDao.getById(draft.id);
        expect(session, isNotNull);
        expect(session!.status, WorkoutSessionStatus.completed.dbValue);
        expect(session.name, draft.name);
        expect(session.notes, isNull);
        expect(session.completedAt, completedAt);
        expect(await repository.getActiveSession(), isNull);
      },
    );
  });

  group('active session repair', () {
    test(
      'returns null after repairing obsolete duplicate program session',
      () async {
        final startedAt = DateTime(2026, 7, 4, 8);
        final activeSessionId = 'session-active';
        final completedSessionId = 'session-completed';

        await sessionDao.upsertSession(
          _sessionCompanion(
            id: activeSessionId,
            startedAt: startedAt,
            updatedAt: startedAt,
            programId: 'program-1',
            programWorkoutId: 'program-workout-1',
            status: WorkoutSessionStatus.inProgress.dbValue,
          ),
        );

        await sessionDao.upsertSession(
          _sessionCompanion(
            id: completedSessionId,
            startedAt: startedAt,
            updatedAt: startedAt.add(const Duration(minutes: 30)),
            programId: 'program-1',
            programWorkoutId: 'program-workout-1',
            status: WorkoutSessionStatus.completed.dbValue,
            completedAt: startedAt.add(const Duration(minutes: 30)),
            durationSeconds: 1800,
          ),
        );

        final active = await repository.getActiveSession();

        expect(active, isNull);
        final repaired = await sessionDao.getById(activeSessionId);
        expect(repaired, isNotNull);
        expect(repaired!.status, WorkoutSessionStatus.abandoned.dbValue);
      },
    );

    test(
      'completing a session abandons sibling in-progress duplicates',
      () async {
        final startedAt = DateTime(2026, 7, 4, 8);
        final primaryId = 'session-primary';
        final siblingId = 'session-sibling';

        await sessionDao.upsertSession(
          _sessionCompanion(
            id: primaryId,
            startedAt: startedAt,
            updatedAt: startedAt,
            programId: 'program-1',
            programWorkoutId: 'program-workout-1',
            status: WorkoutSessionStatus.inProgress.dbValue,
          ),
        );
        await sessionDao.upsertSession(
          _sessionCompanion(
            id: siblingId,
            startedAt: startedAt.add(const Duration(seconds: 1)),
            updatedAt: startedAt.add(const Duration(seconds: 1)),
            programId: 'program-1',
            programWorkoutId: 'program-workout-1',
            status: WorkoutSessionStatus.inProgress.dbValue,
          ),
        );

        await repository.completeSession(
          id: primaryId,
          completedAt: startedAt.add(const Duration(minutes: 30)),
          durationSeconds: 1800,
        );

        final primary = await sessionDao.getById(primaryId);
        final sibling = await sessionDao.getById(siblingId);

        expect(primary, isNotNull);
        expect(primary!.status, WorkoutSessionStatus.completed.dbValue);
        expect(sibling, isNotNull);
        expect(sibling!.status, WorkoutSessionStatus.abandoned.dbValue);
        expect(await repository.getActiveSession(), isNull);
      },
    );
  });
}

WorkoutSessionDraft _buildDraft({required DateTime startedAt}) {
  return WorkoutSessionDraft(
    id: 'session-1',
    source: SessionSource.savedWorkout,
    name: 'Leg Day',
    startedAt: startedAt,
    status: WorkoutSessionStatus.inProgress,
    savedWorkoutId: 'saved-1',
    exercises: [
      WorkoutSessionExerciseDraft(
        id: 'exercise-1',
        exerciseId: 101,
        exerciseNameSnapshot: 'Back Squat',
        sortOrder: 0,
        setLogs: [
          SetLogDraft(
            id: 'set-1',
            exerciseId: 101,
            setIndex: 0,
            setType: SetType.working,
            performedAt: startedAt,
            completed: true,
            skipped: false,
            actualReps: 5,
            actualWeightKg: 100,
          ),
        ],
        notes: 'Keep chest up',
      ),
    ],
  );
}

WorkoutSessionsCompanion _sessionCompanion({
  required String id,
  required DateTime startedAt,
  required DateTime updatedAt,
  required String status,
  String? programId,
  String? programWorkoutId,
  String? savedWorkoutId,
  DateTime? completedAt,
  int? durationSeconds,
}) {
  return WorkoutSessionsCompanion.insert(
    id: id,
    source: SessionSource.program.dbValue,
    programId: Value(programId),
    programWorkoutId: Value(programWorkoutId),
    savedWorkoutId: Value(savedWorkoutId),
    name: 'Leg Day',
    startedAt: startedAt,
    completedAt: Value(completedAt),
    durationSeconds: Value(durationSeconds),
    status: status,
    createdAt: startedAt,
    updatedAt: updatedAt,
  );
}
