import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';

class ListSavedWorkoutsUseCase {
  const ListSavedWorkoutsUseCase({
    required SavedWorkoutRepository savedWorkoutRepository,
  }) : _savedWorkoutRepository = savedWorkoutRepository;

  final SavedWorkoutRepository _savedWorkoutRepository;

  Future<List<SavedWorkoutListItem>> execute() async {
    final aggregates = await _savedWorkoutRepository.listSavedWorkouts();
    return aggregates.map((a) {
      return SavedWorkoutListItem(
        id: a.savedWorkout.id,
        name: a.savedWorkout.name,
        status: SavedWorkoutStatus.fromDb(a.savedWorkout.status),
        exerciseCount: a.exercises.length,
        updatedAt: a.savedWorkout.updatedAt,
        description: a.savedWorkout.description,
        estimatedDurationMinutes: a.savedWorkout.estimatedDurationMinutes,
      );
    }).toList();
  }
}
