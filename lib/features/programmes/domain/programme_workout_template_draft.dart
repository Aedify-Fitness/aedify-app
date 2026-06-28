import 'programme_exercise_draft.dart';

class ProgrammeWorkoutTemplateDraft {
  const ProgrammeWorkoutTemplateDraft({
    required this.id,
    required this.templateKey,
    required this.name,
    required this.sortOrder,
    required this.exercises,
    this.description,
    this.dayType,
    this.estimatedDurationMinutes,
  });

  final String id;
  final String templateKey;
  final String name;
  final int sortOrder;
  final List<ProgrammeExerciseDraft> exercises;
  final String? description;
  final String? dayType;
  final int? estimatedDurationMinutes;
}
