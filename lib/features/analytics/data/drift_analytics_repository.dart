import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/data/analytics_repository.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:drift/drift.dart';

/// Computes evidence on read; the join also excludes orphaned source logs.
class DriftAnalyticsRepository implements AnalyticsRepository {
  DriftAnalyticsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<AnalyticsSetLog>> loadCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  }) async {
    if (!query.isValid) throw AnalyticsQueryFailure.invalidRange;
    try {
      return _mapRows(await _query(query).get());
    } catch (_) {
      throw AnalyticsQueryFailure.unavailable;
    }
  }

  @override
  Stream<List<AnalyticsSetLog>> watchCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  }) async* {
    if (!query.isValid) throw AnalyticsQueryFailure.invalidRange;
    try {
      // `yield*` forwards source errors directly to listeners. Consume events
      // here so SQL failures cannot bypass the privacy boundary below.
      await for (final rows in _query(query).watch()) {
        yield _mapRows(rows);
      }
    } catch (_) {
      throw AnalyticsQueryFailure.unavailable;
    }
  }

  JoinedSelectStatement<HasResultSet, Object?> _query(AnalyticsLogQuery query) {
    final logs = _db.setLogs;
    final members = _db.workoutSessionExercises;
    final sessions = _db.workoutSessions;
    final exercises = _db.exercises;
    final workouts = _db.programWorkouts;
    final weeks = _db.programWeeks;
    final statement =
        _db.select(logs).join([
            innerJoin(
              members,
              members.id.equalsExp(logs.workoutSessionExerciseId),
            ),
            innerJoin(
              sessions,
              sessions.id.equalsExp(members.workoutSessionId),
            ),
            // Archived/missing catalogue entries must not erase completed history.
            leftOuterJoin(exercises, exercises.id.equalsExp(logs.exerciseId)),
            leftOuterJoin(
              workouts,
              workouts.id.equalsExp(sessions.programWorkoutId) &
                  workouts.programId.equalsExp(sessions.programId),
            ),
            leftOuterJoin(
              weeks,
              weeks.id.equalsExp(workouts.programWeekId) &
                  weeks.programId.equalsExp(workouts.programId),
            ),
          ])
          ..where(
            sessions.status.equals('completed') &
                logs.completed.equals(true) &
                logs.skipped.equals(false) &
                logs.setType.equals('working'),
          )
          ..orderBy([
            OrderingTerm.asc(logs.performedAt),
            OrderingTerm.asc(sessions.id),
            OrderingTerm.asc(members.sortOrder),
            OrderingTerm.asc(members.id),
            OrderingTerm.asc(logs.setIndex),
            OrderingTerm.asc(logs.id),
          ]);
    if (query.exerciseId case final id?) {
      statement.where(logs.exerciseId.equals(id));
    }
    if (query.from case final from?) {
      statement.where(logs.performedAt.isBiggerOrEqualValue(from));
    }
    if (query.until case final until?) {
      statement.where(logs.performedAt.isSmallerThanValue(until));
    }
    return statement;
  }

  List<AnalyticsSetLog> _mapRows(List<TypedResult> rows) => List.unmodifiable(
    rows.map((row) {
      final log = row.readTable(_db.setLogs);
      final member = row.readTable(_db.workoutSessionExercises);
      final session = row.readTable(_db.workoutSessions);
      final exercise = row.readTableOrNull(_db.exercises);
      final week = row.readTableOrNull(_db.programWeeks);
      // A swapped member's current logging mode describes a different exercise.
      final loggingValue = member.exerciseId == log.exerciseId
          ? member.loggingType ?? exercise?.loggingType
          : exercise?.loggingType;
      return AnalyticsSetLog(
        id: log.id,
        sessionId: session.id,
        sessionExerciseId: member.id,
        exerciseId: log.exerciseId,
        exerciseName: member.exerciseId == log.exerciseId
            ? member.exerciseNameSnapshot
            : exercise?.name,
        sessionName: session.name,
        source:
            SessionSource.fromDb(session.source) ?? SessionSource.standalone,
        performedAt: log.performedAt,
        completedAt: session.completedAt ?? session.updatedAt,
        setIndex: log.setIndex,
        updatedAt: log.updatedAt,
        modality: _modality(exercise?.modality),
        loggingType: _loggingType(loggingValue),
        equipment: exercise?.equipment,
        actualReps: log.actualReps,
        actualWeightKg: log.actualWeightKg,
        actualDurationSeconds: log.actualDurationSeconds,
        actualDistanceMeters: log.actualDistanceMeters,
        actualRpe: log.actualRpe,
        actualRir: log.actualRir,
        prescribedRepsMin: log.prescribedRepsMin,
        prescribedRepsMax: log.prescribedRepsMax,
        prescribedRepsExact: log.prescribedRepsExact,
        prescribedWeightKg: log.prescribedWeightKg,
        isDeload: _isDeload(session, week),
        isPlateauEligible:
            exercise != null &&
            exercise.deletedAt == null &&
            !exercise.isSubstitutedOut,
      );
    }),
  );

  static bool? _isDeload(WorkoutSession session, ProgramWeek? week) {
    if (session.source == SessionSource.standalone.dbValue ||
        session.source == SessionSource.savedWorkout.dbValue) {
      return false;
    }
    if (session.source != SessionSource.program.dbValue || week == null) {
      return null;
    }
    if (week.weekType == null) {
      return false;
    }
    if (!WeekType.values.any((type) => type.dbValue == week.weekType)) {
      return null;
    }
    return week.weekType == WeekType.deload.dbValue;
  }

  static ExerciseModality? _modality(String? value) {
    for (final modality in ExerciseModality.values) {
      if (modality.dbValue == value) return modality;
    }
    return null;
  }

  static ExerciseLoggingType? _loggingType(String? value) {
    for (final type in ExerciseLoggingType.values) {
      if (type.dbValue == value) return type;
    }
    return null;
  }
}
