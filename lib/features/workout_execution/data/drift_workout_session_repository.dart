import 'package:drift/drift.dart' show Value;
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/transactions/transaction_executor.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';
import 'package:aedify/core/db/transactions/transaction_step.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_exercise_draft.dart';
import 'package:aedify/features/workout_execution/domain/set_log_draft.dart';

class DriftWorkoutSessionRepository implements WorkoutSessionRepository {
  DriftWorkoutSessionRepository({
    required WorkoutSessionDao workoutSessionDao,
    required WorkoutSessionExerciseDao workoutSessionExerciseDao,
    required SetLogDao setLogDao,
    required TransactionExecutor transactionExecutor,
  }) : _workoutSessionDao = workoutSessionDao,
       _workoutSessionExerciseDao = workoutSessionExerciseDao,
       _setLogDao = setLogDao,
       _transactionExecutor = transactionExecutor;

  static final _logger = AppLogger(name: 'DriftWorkoutSessionRepository');

  final WorkoutSessionDao _workoutSessionDao;
  final WorkoutSessionExerciseDao _workoutSessionExerciseDao;
  final SetLogDao _setLogDao;
  final TransactionExecutor _transactionExecutor;

  @override
  Future<WorkoutSessionAggregate?> getActiveSession() async {
    _logger.debug('getActive');
    await _repairInProgressSessions();
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
    _logger.info('start — sessionId: ${draft.id}');
    final sessionId = draft.id;
    final now = DateTime.now();

    await _transactionExecutor.execute(
      operationName: 'session.start',
      steps: _buildStartSessionSteps(
        draft: draft,
        sessionId: sessionId,
        now: now,
      ),
    );

    return sessionId;
  }

  @override
  Future<void> saveSessionProgress(WorkoutSessionDraft draft) async {
    _logger.debug('saveProgress — sessionId: ${draft.id}');
    final now = DateTime.now();

    await _transactionExecutor.execute(
      operationName: 'session.save_progress',
      steps: _buildSaveSessionProgressSteps(draft: draft, now: now),
    );
  }

  @override
  Future<void> completeSession({
    required String id,
    required DateTime completedAt,
    required int durationSeconds,
  }) async {
    _logger.info('complete — sessionId: $id');
    await _transactionExecutor.execute(
      operationName: 'session.complete',
      steps: _buildCompleteSessionSteps(
        sessionId: id,
        completedAt: completedAt,
        durationSeconds: durationSeconds,
      ),
    );
  }

  @override
  Future<void> abandonSession(String id) async {
    _logger.info('abandon — sessionId: $id');
    await _workoutSessionDao.markAbandoned(id: id, updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteInProgressSession(String id) async {
    await _transactionExecutor.execute(
      operationName: 'session.delete',
      steps: _buildDeleteInProgressSessionSteps(id),
    );
  }

  List<TransactionStep> _buildStartSessionSteps({
    required WorkoutSessionDraft draft,
    required String sessionId,
    required DateTime now,
  }) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'session.ensure_no_active'),
        run: () async {
          final inProgressCount = await _workoutSessionDao
              .countInProgressSessions();
          if (inProgressCount > 0) {
            throw StateError(
              'Cannot start session: another session is already in progress',
            );
          }
        },
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.write_root'),
        run: () =>
            _writeSessionRoot(draft: draft, sessionId: sessionId, now: now),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.delete_hierarchy'),
        run: () => _deleteSessionHierarchy(sessionId),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.insert_exercises'),
        run: () async {
          for (final exercise in draft.exercises) {
            await _insertSessionExercise(
              sessionId: sessionId,
              exercise: exercise,
            );
          }
        },
      ),
    ];
  }

  List<TransactionStep> _buildSaveSessionProgressSteps({
    required WorkoutSessionDraft draft,
    required DateTime now,
  }) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'session.write_root'),
        run: () => _updateSessionProgressRoot(draft: draft, now: now),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.delete_hierarchy'),
        run: () => _deleteSessionHierarchy(draft.id),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.insert_exercises'),
        run: () async {
          for (final exercise in draft.exercises) {
            await _insertSessionExercise(
              sessionId: draft.id,
              exercise: exercise,
            );
          }
        },
      ),
    ];
  }

  List<TransactionStep> _buildCompleteSessionSteps({
    required String sessionId,
    required DateTime completedAt,
    required int durationSeconds,
  }) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'session.complete'),
        run: () => _completeSessionAndAbandonSiblings(
          sessionId: sessionId,
          completedAt: completedAt,
          durationSeconds: durationSeconds,
        ),
      ),
    ];
  }

  List<TransactionStep> _buildDeleteInProgressSessionSteps(String sessionId) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'session.delete_hierarchy'),
        run: () => _deleteSessionHierarchy(sessionId),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'session.delete_root'),
        run: () => _workoutSessionDao.deleteSession(sessionId),
      ),
    ];
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
        restBetweenExercisesSeconds: Value(
          exercise.restBetweenExercisesSeconds,
        ),
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

  Future<void> _updateSessionProgressRoot({
    required WorkoutSessionDraft draft,
    required DateTime now,
  }) async {
    final didUpdate = await _workoutSessionDao.updateSessionIfInProgress(
      id: draft.id,
      entry: WorkoutSessionsCompanion(
        source: Value(draft.source.dbValue),
        programId: Value(draft.programId),
        programWorkoutId: Value(draft.programWorkoutId),
        savedWorkoutId: Value(draft.savedWorkoutId),
        name: Value(draft.name),
        startedAt: Value(draft.startedAt),
        durationSeconds: Value(draft.durationSeconds),
        bodyweightKgAtSession: Value(draft.bodyweightKgAtSession),
        notes: Value(draft.notes),
        energyLevel: Value(draft.energyLevel),
        perceivedDifficulty: Value(draft.perceivedDifficulty),
        updatedAt: Value(now),
      ),
    );
    if (!didUpdate) {
      final existing = await _workoutSessionDao.getById(draft.id);
      if (existing == null) {
        throw StateError('Session not found: ${draft.id}');
      }
      throw StateError(
        'Cannot save progress: session ${draft.id} status is ${existing.status}',
      );
    }
  }

  Future<void> _completeSessionAndAbandonSiblings({
    required String sessionId,
    required DateTime completedAt,
    required int durationSeconds,
  }) async {
    final updatedAt = DateTime.now();
    await _workoutSessionDao.markCompleted(
      id: sessionId,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      updatedAt: updatedAt,
    );

    final completedSession = await _workoutSessionDao.getById(sessionId);
    if (completedSession == null) {
      throw StateError('Session not found after completion: $sessionId');
    }

    final siblingIds = await _findConflictingInProgressSessionIds(
      reference: completedSession,
    );
    await _workoutSessionDao.markAbandonedByIds(
      ids: siblingIds,
      updatedAt: updatedAt,
    );
  }

  Future<void> _repairInProgressSessions() async {
    final activeSessions = await _workoutSessionDao.getInProgressSessions();
    if (activeSessions.isEmpty) return;

    final obsoleteIds = await _findObsoleteInProgressSessionIds(activeSessions);
    if (obsoleteIds.isNotEmpty) {
      await _workoutSessionDao.markAbandonedByIds(
        ids: obsoleteIds,
        updatedAt: DateTime.now(),
      );
    }

    final remainingSessions = await _workoutSessionDao.getInProgressSessions();
    if (remainingSessions.length <= 1) return;

    await _workoutSessionDao.markAbandonedByIds(
      ids: remainingSessions.skip(1).map((s) => s.id).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Future<List<String>> _findObsoleteInProgressSessionIds(
    List<WorkoutSession> activeSessions,
  ) async {
    final obsoleteIds = <String>[];

    final programWorkoutIds = activeSessions
        .map((s) => s.programWorkoutId)
        .whereType<String>()
        .toSet()
        .toList();
    final latestCompletedProgramSessions = await _workoutSessionDao
        .getCompletedByProgramWorkoutIds(programWorkoutIds);
    final latestCompletedByProgramWorkoutId = <String, DateTime>{};
    for (final session in latestCompletedProgramSessions) {
      final programWorkoutId = session.programWorkoutId;
      final completedAt = session.completedAt;
      if (programWorkoutId == null || completedAt == null) continue;
      latestCompletedByProgramWorkoutId.putIfAbsent(
        programWorkoutId,
        () => completedAt,
      );
    }

    final savedWorkoutIds = activeSessions
        .map((s) => s.savedWorkoutId)
        .whereType<String>()
        .toSet()
        .toList();
    final latestCompletedSavedSessions = await _workoutSessionDao
        .getCompletedBySavedWorkoutIds(savedWorkoutIds);
    final latestCompletedBySavedWorkoutId = <String, DateTime>{};
    for (final session in latestCompletedSavedSessions) {
      final savedWorkoutId = session.savedWorkoutId;
      final completedAt = session.completedAt;
      if (savedWorkoutId == null || completedAt == null) continue;
      latestCompletedBySavedWorkoutId.putIfAbsent(
        savedWorkoutId,
        () => completedAt,
      );
    }

    for (final session in activeSessions) {
      final programCompletedAt = session.programWorkoutId == null
          ? null
          : latestCompletedByProgramWorkoutId[session.programWorkoutId!];
      if (programCompletedAt != null &&
          !programCompletedAt.isBefore(session.startedAt)) {
        obsoleteIds.add(session.id);
        continue;
      }

      final savedCompletedAt = session.savedWorkoutId == null
          ? null
          : latestCompletedBySavedWorkoutId[session.savedWorkoutId!];
      if (savedCompletedAt != null &&
          !savedCompletedAt.isBefore(session.startedAt)) {
        obsoleteIds.add(session.id);
      }
    }

    return obsoleteIds;
  }

  Future<List<String>> _findConflictingInProgressSessionIds({
    required WorkoutSession reference,
  }) async {
    final activeSessions = await _workoutSessionDao.getInProgressSessions();
    return activeSessions
        .where((candidate) => candidate.id != reference.id)
        .where((candidate) => _matchesWorkoutIdentity(candidate, reference))
        .map((candidate) => candidate.id)
        .toList();
  }

  bool _matchesWorkoutIdentity(
    WorkoutSession candidate,
    WorkoutSession target,
  ) {
    if (candidate.source != target.source) return false;

    if (target.programWorkoutId != null) {
      return candidate.programWorkoutId == target.programWorkoutId;
    }

    if (target.savedWorkoutId != null) {
      return candidate.savedWorkoutId == target.savedWorkoutId;
    }

    return false;
  }

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
      durationSeconds: Value(draft.durationSeconds),
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
      prescribedRepsExact: Value(setLog.prescribedRepsExact),
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
      restSeconds: Value(setLog.restSeconds),
      notes: Value(setLog.notes),
      createdAt: Value(setLog.performedAt),
      updatedAt: Value(setLog.performedAt),
    );
  }
}
