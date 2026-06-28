import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';

abstract class SavedWorkoutRepository {
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id);

  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({String? status});

  Future<String> saveSavedWorkout(SavedWorkoutDraft draft);

  Future<void> archiveSavedWorkout(String id);

  Future<void> deleteSavedWorkout(String id);
}
