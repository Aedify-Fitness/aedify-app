import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';

abstract class WorkoutHistoryRepository {
  Future<List<WorkoutHistoryListItem>> listCompletedSessions();

  Future<WorkoutHistoryDetailViewData?> getSessionDetail(String sessionId);

  Future<List<ExerciseHistorySession>> listExerciseHistory(int exerciseId);

  Future<void> correctSession({
    required String sessionId,
    required List<WorkoutHistorySetCorrection> corrections,
  });
}
