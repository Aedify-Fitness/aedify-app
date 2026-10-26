import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/shared/domain/session_source.dart';

class WorkoutHistoryDetailViewData {
  const WorkoutHistoryDetailViewData({
    required this.sessionId,
    required this.name,
    required this.source,
    required this.startedAt,
    required this.exercises,
    this.completedAt,
    this.durationSeconds,
    this.notes,
    this.energyLevel,
    this.perceivedDifficulty,
    this.programId,
    this.programWorkoutId,
    this.savedWorkoutId,
  });

  final String sessionId;
  final String name;
  final SessionSource source;
  final DateTime startedAt;
  final List<WorkoutHistoryExerciseItem> exercises;
  final DateTime? completedAt;
  final int? durationSeconds;
  final String? notes;
  final int? energyLevel;
  final int? perceivedDifficulty;
  final String? programId;
  final String? programWorkoutId;
  final String? savedWorkoutId;
}
