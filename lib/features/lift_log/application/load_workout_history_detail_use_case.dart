import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';

class LoadWorkoutHistoryDetailUseCase {
  const LoadWorkoutHistoryDetailUseCase({
    required WorkoutHistoryRepository workoutHistoryRepository,
  }) : _workoutHistoryRepository = workoutHistoryRepository;

  final WorkoutHistoryRepository _workoutHistoryRepository;

  Future<WorkoutHistoryDetailViewData?> execute(String sessionId) async {
    return _workoutHistoryRepository.getSessionDetail(sessionId);
  }
}
