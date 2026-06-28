import 'saved_workout_exercise_draft.dart';

class SavedWorkoutDraft {
  const SavedWorkoutDraft({
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
  final String source;
  final String creationMethod;
  final String status;
  final List<String> goalTags;
  final List<String> equipment;
  final List<SavedWorkoutExerciseDraft> exercises;
  final String? description;
  final int? estimatedDurationMinutes;
}
