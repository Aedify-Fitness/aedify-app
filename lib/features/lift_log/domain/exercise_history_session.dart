import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';

/// The matching exercise occurrences from one completed workout session.
class ExerciseHistorySession {
  const ExerciseHistorySession({
    required this.sessionId,
    required this.workoutName,
    required this.completedAt,
    required this.exercises,
  });

  final String sessionId;
  final String workoutName;
  final DateTime completedAt;
  final List<WorkoutHistoryExerciseItem> exercises;

  /// Keeps completed logs, including logged sets from partially finished exercises.
  ExerciseHistorySession? get completedLogsOnly {
    final completedExercises = <WorkoutHistoryExerciseItem>[];
    for (final exercise in exercises) {
      final sets = exercise.sets.where((set) => set.hasCompletedLog).toList();
      if (sets.isNotEmpty) {
        completedExercises.add(exercise.copyWith(sets: sets));
      }
    }
    if (completedExercises.isEmpty) return null;
    return ExerciseHistorySession(
      sessionId: sessionId,
      workoutName: workoutName,
      completedAt: completedAt,
      exercises: completedExercises,
    );
  }
}
