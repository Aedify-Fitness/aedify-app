import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

import 'workout_session_exercise_draft.dart';

class WorkoutSessionDraft {
  const WorkoutSessionDraft({
    required this.id,
    required this.source,
    required this.name,
    required this.startedAt,
    required this.status,
    required this.exercises,
    this.programId,
    this.programWorkoutId,
    this.savedWorkoutId,
    this.bodyweightKgAtSession,
    this.notes,
    this.energyLevel,
    this.perceivedDifficulty,
  });

  final String id;
  final SessionSource source;
  final String name;
  final DateTime startedAt;
  final WorkoutSessionStatus status;
  final List<WorkoutSessionExerciseDraft> exercises;
  final String? programId;
  final String? programWorkoutId;
  final String? savedWorkoutId;
  final double? bodyweightKgAtSession;
  final String? notes;
  final int? energyLevel;
  final int? perceivedDifficulty;
}
