import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';

abstract class WorkoutHistoryRepository {
  Future<List<WorkoutHistoryListItem>> listCompletedSessions();

  Future<WorkoutHistoryDetailViewData?> getSessionDetail(String sessionId);
}
