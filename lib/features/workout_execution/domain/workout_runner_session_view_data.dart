import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

class WorkoutRunnerSessionViewData {
  const WorkoutRunnerSessionViewData({
    required this.sessionId,
    required this.name,
    required this.source,
    required this.status,
    required this.startedAt,
    required this.exercises,
    this.programId,
    this.programWorkoutId,
    this.savedWorkoutId,
    this.completedAt,
    this.durationSeconds,
    this.bodyweightKgAtSession,
    this.notes,
    this.energyLevel,
    this.perceivedDifficulty,
  });

  final String sessionId;
  final String name;
  final SessionSource source;
  final WorkoutSessionStatus status;
  final DateTime startedAt;
  final List<WorkoutRunnerExerciseItem> exercises;
  final String? programId;
  final String? programWorkoutId;
  final String? savedWorkoutId;
  final DateTime? completedAt;
  final int? durationSeconds;
  final double? bodyweightKgAtSession;
  final String? notes;
  final int? energyLevel;
  final int? perceivedDifficulty;

  WorkoutRunnerSessionViewData copyWith({
    String? sessionId,
    String? name,
    SessionSource? source,
    WorkoutSessionStatus? status,
    DateTime? startedAt,
    List<WorkoutRunnerExerciseItem>? exercises,
    String? programId,
    String? programWorkoutId,
    String? savedWorkoutId,
    DateTime? completedAt,
    int? durationSeconds,
    double? bodyweightKgAtSession,
    String? notes,
    int? energyLevel,
    int? perceivedDifficulty,
  }) {
    return WorkoutRunnerSessionViewData(
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      source: source ?? this.source,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      exercises: exercises ?? this.exercises,
      programId: programId ?? this.programId,
      programWorkoutId: programWorkoutId ?? this.programWorkoutId,
      savedWorkoutId: savedWorkoutId ?? this.savedWorkoutId,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      bodyweightKgAtSession:
          bodyweightKgAtSession ?? this.bodyweightKgAtSession,
      notes: notes ?? this.notes,
      energyLevel: energyLevel ?? this.energyLevel,
      perceivedDifficulty: perceivedDifficulty ?? this.perceivedDifficulty,
    );
  }
}
