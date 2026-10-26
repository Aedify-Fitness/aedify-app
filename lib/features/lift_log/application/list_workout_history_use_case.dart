import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';

class ListWorkoutHistoryUseCase {
  const ListWorkoutHistoryUseCase({
    required WorkoutHistoryRepository workoutHistoryRepository,
  }) : _workoutHistoryRepository = workoutHistoryRepository;

  final WorkoutHistoryRepository _workoutHistoryRepository;

  Future<List<WorkoutHistoryListItem>> execute() async {
    return _workoutHistoryRepository.listCompletedSessions();
  }
}
