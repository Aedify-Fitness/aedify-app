import 'package:flutter/foundation.dart' show listEquals;
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
    this.restBetweenExercisesSeconds,
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
  final int? restBetweenExercisesSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutBuilderDraft &&
          id == other.id &&
          name == other.name &&
          source == other.source &&
          creationMethod == other.creationMethod &&
          status == other.status &&
          listEquals(goalTags, other.goalTags) &&
          listEquals(equipment, other.equipment) &&
          listEquals(exercises, other.exercises) &&
          description == other.description &&
          estimatedDurationMinutes == other.estimatedDurationMinutes &&
          restBetweenExercisesSeconds == other.restBetweenExercisesSeconds;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    source,
    creationMethod,
    status,
    Object.hashAll(goalTags),
    Object.hashAll(equipment),
    Object.hashAll(exercises),
    description,
    estimatedDurationMinutes,
    restBetweenExercisesSeconds,
  );

  WorkoutBuilderDraft clearRestBetweenExercises() {
    return WorkoutBuilderDraft(
      id: id,
      name: name,
      source: source,
      creationMethod: creationMethod,
      status: status,
      goalTags: goalTags,
      equipment: equipment,
      exercises: exercises,
      description: description,
      estimatedDurationMinutes: estimatedDurationMinutes,
      restBetweenExercisesSeconds: null,
    );
  }

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
    int? restBetweenExercisesSeconds,
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
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    );
  }
}
