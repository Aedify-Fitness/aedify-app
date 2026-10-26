import 'package:aedify/core/db/app_database.dart';

class SavedWorkoutAggregate {
  const SavedWorkoutAggregate({
    required this.savedWorkout,
    required this.exercises,
    required this.sets,
  });

  final SavedWorkout savedWorkout;
  final List<SavedWorkoutExercise> exercises;
  final List<SavedWorkoutExerciseSet> sets;
}
