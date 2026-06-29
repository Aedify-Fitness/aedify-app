import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';

import 'package:aedify/shared/domain/workout_session_status.dart';

class DriftWorkoutSessionRepository implements WorkoutSessionRepository {
  DriftWorkoutSessionRepository({
    required AppDatabase database,
    required WorkoutSessionDao workoutSessionDao,
    required WorkoutSessionExerciseDao workoutSessionExerciseDao,
    required SetLogDao setLogDao,
  }) : _database = database,
       _workoutSessionDao = workoutSessionDao,
       _workoutSessionExerciseDao = workoutSessionExerciseDao,
       _setLogDao = setLogDao;

  final AppDatabase _database;
  final WorkoutSessionDao _workoutSessionDao;
  final WorkoutSessionExerciseDao _workoutSessionExerciseDao;
  final SetLogDao _setLogDao;

  @override
  Future<WorkoutSessionAggregate?> getActiveSession() async {
    final session = await _workoutSessionDao.getActiveSession();
    if (session == null) return null;
    return _buildAggregate(session);
  }

  @override
  Future<WorkoutSessionAggregate?> getSession(String id) async {
    final session = await _workoutSessionDao.getById(id);
    if (session == null) return null;
    return _buildAggregate(session);
  }

  @override
  Future<String> startSession(WorkoutSessionDraft draft) async {
    return _database.inTransaction(() async {
      final inProgressCount = await _workoutSessionDao
          .countInProgressSessions();
      if (inProgressCount > 0) {
        throw StateError(
          'Cannot start session: another session is already in progress',
        );
      }

      final sessionId = draft.id;
      final now = DateTime.now();

      await _writeSessionRoot(draft: draft, sessionId: sessionId, now: now);

      await _deleteSessionHierarchy(sessionId);

      for (final exercise in draft.exercises) {
        await _insertSessionExercise(sessionId: sessionId, exercise: exercise);
      }

      return sessionId;
    });
  }

  @override
  Future<void> saveSessionProgress(WorkoutSessionDraft draft) async {
    await _database.inTransaction(() async {
      final existing = await _workoutSessionDao.getById(draft.id);
      if (existing == null) {
        throw StateError('Session not found: ${draft.id}');
      }
      if (existing.status != WorkoutSessionStatus.inProgress.dbValue) {
        throw StateError(
          'Cannot save progress: session ${draft.id} status is ${existing.status}',
        );
      }

      await _updateSessionRootFromDraft(
        draft: draft,
        existing: existing,
        now: DateTime.now(),
      );

      final sessionId = draft.id;
      await _deleteSessionHierarchy(sessionId);

      for (final exercise in draft.exercises) {
        await _insertSessionExercise(sessionId: sessionId, exercise: exercise);
      }
    });
  }

  @override
  Future<void> completeSession({
    required String id,
    required DateTime completedAt,
    required int durationSeconds,
  }) async {
    await _workoutSessionDao.markCompleted(
      id: id,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> abandonSession(String id) async {
    await _workoutSessionDao.markAbandoned(id: id, updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteInProgressSession(String id) async {
    await _database.inTransaction(() async {
      await _deleteSessionHierarchy(id);
      await _workoutSessionDao.deleteSession(id);
    });
  }

  Future<WorkoutSessionAggregate> _buildAggregate(
    WorkoutSession session,
  ) async {
    final exercises = await _workoutSessionExerciseDao.getBySessionIdOrdered(
      session.id,
    );

    final allSetLogs = <SetLog>[];
    for (final e in exercises) {
      final setLogs = await _setLogDao.getBySessionExerciseIdOrdered(e.id);
      allSetLogs.addAll(setLogs);
    }

    return WorkoutSessionAggregate(
      session: session,
      exercises: exercises,
      setLogs: allSetLogs,
    );
  }

  Future<void> _writeSessionRoot({
    required WorkoutSessionDraft draft,
    required String sessionId,
    required DateTime now,
  }) async {
    await _workoutSessionDao.upsertSession(
      _buildWorkoutSessionCompanion(
        draft: draft,
        sessionId: sessionId,
        now: now,
      ),
    );
  }

  Future<void> _deleteSessionHierarchy(String sessionId) async {
    final exercises = await _workoutSessionExerciseDao.getBySessionIdOrdered(
      sessionId,
    );
    for (final e in exercises) {
      await _setLogDao.deleteBySessionExerciseId(e.id);
    }
    await _workoutSessionExerciseDao.deleteBySessionId(sessionId);
  }

  Future<void> _insertSessionExercise({
    required String sessionId,
    required WorkoutSessionExerciseDraft exercise,
  }) async {
    await _workoutSessionExerciseDao.upsertSessionExercise(
      WorkoutSessionExercisesCompanion(
        id: Value(exercise.id),
        workoutSessionId: Value(sessionId),
        sourceProgramExerciseId: Value(exercise.sourceProgramExerciseId),
        sourceSavedWorkoutExerciseId: Value(
          exercise.sourceSavedWorkoutExerciseId,
        ),
        exerciseId: Value(exercise.exerciseId),
        exerciseNameSnapshot: Value(exercise.exerciseNameSnapshot),
        sortOrder: Value(exercise.sortOrder),
        supersetGroupId: Value(exercise.supersetGroupId),
        notes: Value(exercise.notes),
      ),
    );

    for (final setLog in exercise.setLogs) {
      await _insertSetLog(
        workoutSessionExerciseId: exercise.id,
        setLog: setLog,
      );
    }
  }

  Future<void> _insertSetLog({
    required String workoutSessionExerciseId,
    required SetLogDraft setLog,
  }) async {
    await _setLogDao.upsertSetLog(
      _buildSetLogCompanion(
        workoutSessionExerciseId: workoutSessionExerciseId,
        setLog: setLog,
      ),
    );
  }

  Future<void> _updateSessionRootFromDraft({
    required WorkoutSessionDraft draft,
    required WorkoutSession existing,
    required DateTime now,
  }) async {
    await _workoutSessionDao.upsertSession(
      WorkoutSessionsCompanion(
        id: Value(draft.id),
        source: Value(draft.source.dbValue),
        programId: Value(draft.programId),
        programWorkoutId: Value(draft.programWorkoutId),
        savedWorkoutId: Value(draft.savedWorkoutId),
        name: Value(draft.name),
        startedAt: Value(draft.startedAt),
        completedAt: Value(existing.completedAt),
        durationSeconds: Value(existing.durationSeconds),
        status: Value(WorkoutSessionStatus.inProgress.dbValue),
        bodyweightKgAtSession: Value(draft.bodyweightKgAtSession),
        notes: Value(draft.notes),
        energyLevel: Value(draft.energyLevel),
        perceivedDifficulty: Value(draft.perceivedDifficulty),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(now),
      ),
    );
  }

  // --- Companion builders ---

  WorkoutSessionsCompanion _buildWorkoutSessionCompanion({
    required WorkoutSessionDraft draft,
    required String sessionId,
    required DateTime now,
  }) {
    return WorkoutSessionsCompanion(
      id: Value(sessionId),
      source: Value(draft.source.dbValue),
      programId: Value(draft.programId),
      programWorkoutId: Value(draft.programWorkoutId),
      savedWorkoutId: Value(draft.savedWorkoutId),
      name: Value(draft.name),
      startedAt: Value(draft.startedAt),
      completedAt: Value(null),
      durationSeconds: Value(null),
      status: Value(draft.status.dbValue),
      bodyweightKgAtSession: Value(draft.bodyweightKgAtSession),
      notes: Value(draft.notes),
      energyLevel: Value(draft.energyLevel),
      perceivedDifficulty: Value(draft.perceivedDifficulty),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  SetLogsCompanion _buildSetLogCompanion({
    required String workoutSessionExerciseId,
    required SetLogDraft setLog,
  }) {
    return SetLogsCompanion(
      id: Value(setLog.id),
      workoutSessionExerciseId: Value(workoutSessionExerciseId),
      exerciseId: Value(setLog.exerciseId),
      performedAt: Value(setLog.performedAt),
      setIndex: Value(setLog.setIndex),
      setType: Value(setLog.setType.dbValue),
      setIntent: Value(setLog.setIntent?.dbValue),
      prescribedRepsMin: Value(setLog.prescribedRepsMin),
      prescribedRepsMax: Value(setLog.prescribedRepsMax),
      prescribedWeightKg: Value(setLog.prescribedWeightKg),
      prescribedRpeMin: Value(setLog.prescribedRpeMin),
      prescribedRpeMax: Value(setLog.prescribedRpeMax),
      actualReps: Value(setLog.actualReps),
      actualWeightKg: Value(setLog.actualWeightKg),
      actualDurationSeconds: Value(setLog.actualDurationSeconds),
      actualDistanceMeters: Value(setLog.actualDistanceMeters),
      actualRpe: Value(setLog.actualRpe),
      actualRir: Value(setLog.actualRir),
      completed: Value(setLog.completed),
      skipped: Value(setLog.skipped),
      isPr: Value(setLog.isPr),
      estimated1rmKg: Value(setLog.estimated1rmKg),
      notes: Value(setLog.notes),
      createdAt: Value(setLog.performedAt),
      updatedAt: Value(setLog.performedAt),
    );
  }
}
