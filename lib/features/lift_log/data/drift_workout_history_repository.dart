import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:drift/drift.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';

class DriftWorkoutHistoryRepository implements WorkoutHistoryRepository {
  DriftWorkoutHistoryRepository({
    required WorkoutSessionDao workoutSessionDao,
    required WorkoutSessionExerciseDao workoutSessionExerciseDao,
    required SetLogDao setLogDao,
  }) : _workoutSessionDao = workoutSessionDao,
       _workoutSessionExerciseDao = workoutSessionExerciseDao,
       _setLogDao = setLogDao;

  static final _logger = AppLogger(name: 'DriftWorkoutHistoryRepository');

  final WorkoutSessionDao _workoutSessionDao;
  final WorkoutSessionExerciseDao _workoutSessionExerciseDao;
  final SetLogDao _setLogDao;

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    _logger.debug('listCompleted');
    final sessions = await _workoutSessionDao.getCompletedSessions();
    final items = <WorkoutHistoryListItem>[];
    for (final s in sessions) {
      final source = SessionSource.fromDb(s.source) ?? SessionSource.standalone;
      final exercises = await _workoutSessionExerciseDao.getBySessionIdOrdered(
        s.id,
      );
      items.add(
        WorkoutHistoryListItem(
          sessionId: s.id,
          name: s.name,
          source: source,
          completedAt: s.completedAt ?? s.updatedAt,
          durationSeconds: s.durationSeconds,
          exerciseCount: exercises.length,
          programName: source == SessionSource.program ? s.name : null,
        ),
      );
    }
    return items;
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    _logger.debug('getDetail — sessionId: $sessionId');
    final session = await _workoutSessionDao.getById(sessionId);
    if (session == null || session.status != 'completed') return null;

    final sessionExercises = await _workoutSessionExerciseDao
        .getBySessionIdOrdered(sessionId);

    final exerciseItems = <WorkoutHistoryExerciseItem>[];
    for (final se in sessionExercises) {
      final setLogs = await _setLogDao.getBySessionExerciseIdOrdered(se.id);
      final byExercise = <int, List<SetLog>>{};
      for (final log in setLogs) {
        byExercise.putIfAbsent(log.exerciseId, () => []).add(log);
      }
      if (byExercise.isEmpty) byExercise[se.exerciseId] = [];
      for (final entry in byExercise.entries) {
        final isCurrentExercise = entry.key == se.exerciseId;
        exerciseItems.add(
          WorkoutHistoryExerciseItem(
            id: isCurrentExercise ? se.id : '${se.id}:${entry.key}',
            exerciseId: entry.key,
            exerciseName: isCurrentExercise
                ? se.exerciseNameSnapshot
                : WorkoutHistoryStrings.exerciseReference(entry.key),
            sortOrder: se.sortOrder,
            sets: entry.value.map((log) => _toSetItem(log, se)).toList(),
            supersetGroupId: se.supersetGroupId,
            notes: isCurrentExercise ? se.notes : null,
          ),
        );
      }
    }

    final source =
        SessionSource.fromDb(session.source) ?? SessionSource.standalone;

    return WorkoutHistoryDetailViewData(
      sessionId: session.id,
      name: session.name,
      source: source,
      startedAt: session.startedAt,
      exercises: exerciseItems,
      completedAt: session.completedAt,
      durationSeconds: session.durationSeconds,
      notes: session.notes,
      energyLevel: session.energyLevel,
      perceivedDifficulty: session.perceivedDifficulty,
      programId: session.programId,
      programWorkoutId: session.programWorkoutId,
      savedWorkoutId: session.savedWorkoutId,
    );
  }

  @override
  Future<List<ExerciseHistorySession>> listExerciseHistory(
    int exerciseId,
  ) async {
    final db = _workoutSessionDao.attachedDatabase;
    final rows =
        await (db.select(db.setLogs).join([
                innerJoin(
                  db.workoutSessionExercises,
                  db.workoutSessionExercises.id.equalsExp(
                    db.setLogs.workoutSessionExerciseId,
                  ),
                ),
                innerJoin(
                  db.workoutSessions,
                  db.workoutSessions.id.equalsExp(
                    db.workoutSessionExercises.workoutSessionId,
                  ),
                ),
              ])
              ..where(
                db.setLogs.exerciseId.equals(exerciseId) &
                    db.workoutSessions.status.equals('completed'),
              )
              ..orderBy([
                OrderingTerm.desc(db.workoutSessions.completedAt),
                OrderingTerm.asc(db.workoutSessionExercises.sortOrder),
              ]))
            .get();
    final sessions = <String, WorkoutSession>{};
    for (final row in rows) {
      final session = row.readTable(db.workoutSessions);
      sessions.putIfAbsent(session.id, () => session);
    }
    final items = <ExerciseHistorySession>[];
    for (final session in sessions.values) {
      final detail = await getSessionDetail(session.id);
      if (detail == null) continue;
      final exercises = detail.exercises
          .where((item) => item.exerciseId == exerciseId)
          .toList();
      if (exercises.isEmpty) continue;
      final item = ExerciseHistorySession(
        sessionId: session.id,
        workoutName: session.name,
        completedAt: session.completedAt ?? session.updatedAt,
        exercises: exercises,
      ).completedLogsOnly;
      if (item != null) items.add(item);
    }
    return items;
  }

  @override
  Future<void> correctSession({
    required String sessionId,
    required List<WorkoutHistorySetCorrection> corrections,
  }) async {
    if (corrections.isEmpty ||
        corrections.any((item) => !item.isValid) ||
        corrections.map((item) => item.expected.id).toSet().length !=
            corrections.length) {
      throw WorkoutHistoryCorrectionFailure.invalid;
    }
    final db = _workoutSessionDao.attachedDatabase;
    await db.transaction(() async {
      final session = await _workoutSessionDao.getById(sessionId);
      if (session == null || session.status != 'completed') {
        throw WorkoutHistoryCorrectionFailure.missing;
      }
      final exercises = await _workoutSessionExerciseDao.getBySessionIdOrdered(
        sessionId,
      );
      final exerciseIds = exercises.map((item) => item.id).toSet();
      final now = DateTime.now();
      for (final correction in corrections) {
        final log =
            await (db.select(db.setLogs)
                  ..where((table) => table.id.equals(correction.expected.id)))
                .getSingleOrNull();
        if (log == null ||
            !exerciseIds.contains(log.workoutSessionExerciseId)) {
          throw WorkoutHistoryCorrectionFailure.missing;
        }
        if (!_matchesExpected(log, correction.expected)) {
          throw WorkoutHistoryCorrectionFailure.conflict;
        }
        final sourceExercise = exercises.firstWhere(
          (item) => item.id == log.workoutSessionExerciseId,
        );
        if (!correction.isValidFor(_toSetItem(log, sourceExercise))) {
          throw WorkoutHistoryCorrectionFailure.invalid;
        }
        await (db.update(
          db.setLogs,
        )..where((table) => table.id.equals(log.id))).write(
          SetLogsCompanion(
            actualReps: Value(correction.actualReps),
            actualWeightKg: Value(correction.actualWeightKg),
            actualDurationSeconds: Value(correction.actualDurationSeconds),
            actualDistanceMeters: Value(correction.actualDistanceMeters),
            actualRpe: Value(correction.actualRpe),
            actualRir: Value(correction.actualRir),
            notes: Value(correction.notes),
            isPr: const Value(false),
            estimated1rmKg: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
      await (db.update(db.workoutSessions)..where(
            (table) =>
                table.id.equals(sessionId) & table.status.equals('completed'),
          ))
          .write(WorkoutSessionsCompanion(updatedAt: Value(now)));
    });
  }

  static WorkoutHistorySetItem _toSetItem(
    SetLog log,
    WorkoutSessionExercise exercise,
  ) => WorkoutHistorySetItem(
    id: log.id,
    exerciseId: log.exerciseId,
    loggingType:
        exercise.exerciseId == log.exerciseId && exercise.loggingType != null
        ? ExerciseLoggingType.fromDbWithDefault(exercise.loggingType)
        : null,
    setIndex: log.setIndex,
    setType: SetType.fromDb(log.setType),
    completed: log.completed,
    skipped: log.skipped,
    setIntent: SetIntent.fromDb(log.setIntent),
    prescribedRepsMin: log.prescribedRepsMin,
    prescribedRepsMax: log.prescribedRepsMax,
    prescribedRepsExact: log.prescribedRepsExact,
    prescribedWeightKg: log.prescribedWeightKg,
    prescribedDurationSeconds: log.prescribedDurationSeconds,
    prescribedDistanceMeters: log.prescribedDistanceMeters,
    prescribedRir: log.prescribedRir,
    actualReps: log.actualReps,
    actualWeightKg: log.actualWeightKg,
    actualDurationSeconds: log.actualDurationSeconds,
    actualDistanceMeters: log.actualDistanceMeters,
    actualRpe: log.actualRpe,
    actualRir: log.actualRir,
    notes: log.notes,
    updatedAt: log.updatedAt,
  );

  static bool _matchesExpected(SetLog log, WorkoutHistorySetItem expected) =>
      (expected.exerciseId == null || log.exerciseId == expected.exerciseId) &&
      log.actualReps == expected.actualReps &&
      log.actualWeightKg == expected.actualWeightKg &&
      log.actualDurationSeconds == expected.actualDurationSeconds &&
      log.actualDistanceMeters == expected.actualDistanceMeters &&
      log.actualRpe == expected.actualRpe &&
      log.actualRir == expected.actualRir &&
      log.notes == expected.notes &&
      log.completed == expected.completed &&
      log.skipped == expected.skipped &&
      log.setType == expected.setType.dbValue &&
      (expected.updatedAt == null || log.updatedAt == expected.updatedAt);
}
