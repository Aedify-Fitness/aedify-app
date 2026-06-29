import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'workout_builder_exercise_draft.dart';

class WorkoutBuilderDraft {
  const WorkoutBuilderDraft({
    required this.id,
    required this.name,
    required this.source,
    required this.creationMethod,
    required this.status,
    required this.goalTags,
    required this.equipment,
    required this.exercises,
    this.description,
    this.estimatedDurationMinutes,
  });

  final String id;
  final String name;
  final WorkoutSource source;
  final CreationMethod creationMethod;
  final SavedWorkoutStatus status;
  final List<String> goalTags;
  final List<String> equipment;
  final List<WorkoutBuilderExerciseDraft> exercises;
  final String? description;
  final int? estimatedDurationMinutes;

  WorkoutBuilderDraft copyWith({
    String? id,
    String? name,
    WorkoutSource? source,
    CreationMethod? creationMethod,
    SavedWorkoutStatus? status,
    List<String>? goalTags,
    List<String>? equipment,
    List<WorkoutBuilderExerciseDraft>? exercises,
    String? description,
    int? estimatedDurationMinutes,
  }) {
    return WorkoutBuilderDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      creationMethod: creationMethod ?? this.creationMethod,
      status: status ?? this.status,
      goalTags: goalTags ?? this.goalTags,
      equipment: equipment ?? this.equipment,
      exercises: exercises ?? this.exercises,
      description: description ?? this.description,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}
