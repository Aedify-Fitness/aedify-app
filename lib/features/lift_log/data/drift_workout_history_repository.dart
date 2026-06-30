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
  final WorkoutSessionDao _workoutSessionDao;
  final WorkoutSessionExerciseDao _workoutSessionExerciseDao;
  final SetLogDao _setLogDao;

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    final sessions = await _workoutSessionDao.getCompletedSessions();
    return sessions.map((s) {
      final source = SessionSource.fromDb(s.source) ?? SessionSource.standalone;
      return WorkoutHistoryListItem(
        sessionId: s.id,
        name: s.name,
        source: source,
        completedAt: s.completedAt ?? s.updatedAt,
        durationSeconds: s.durationSeconds,
        exerciseCount: 0,
        programName: source == SessionSource.program ? s.name : null,
      );
    }).toList();
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    final session = await _workoutSessionDao.getById(sessionId);
    if (session == null) return null;

    final sessionExercises = await _workoutSessionExerciseDao
        .getBySessionIdOrdered(sessionId);

    final exerciseItems = <WorkoutHistoryExerciseItem>[];
    for (final se in sessionExercises) {
      final setLogs = await _setLogDao.getBySessionExerciseIdOrdered(se.id);
      final setItems = setLogs.map((sl) {
        return WorkoutHistorySetItem(
          id: sl.id,
          setIndex: sl.setIndex,
          setType: SetType.fromDb(sl.setType),
          completed: sl.completed,
          skipped: sl.skipped,
          setIntent: null,
          prescribedRepsMin: sl.prescribedRepsMin,
          prescribedRepsMax: sl.prescribedRepsMax,
          prescribedWeightKg: sl.prescribedWeightKg,
          actualReps: sl.actualReps,
          actualWeightKg: sl.actualWeightKg,
          actualRpe: sl.actualRpe,
          actualRir: sl.actualRir,
          notes: sl.notes,
        );
      }).toList();

      exerciseItems.add(
        WorkoutHistoryExerciseItem(
          id: se.id,
          exerciseId: se.exerciseId,
          exerciseName: se.exerciseNameSnapshot,
          sortOrder: se.sortOrder,
          sets: setItems,
          supersetGroupId: se.supersetGroupId,
          notes: se.notes,
        ),
      );
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
}
