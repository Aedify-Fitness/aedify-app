import 'package:aedify/shared/domain/day_type.dart';
import 'programme_exercise_draft.dart';

class ProgrammeWorkoutTemplateDraft {
  const ProgrammeWorkoutTemplateDraft({
    required this.id,
    required this.templateKey,
    required this.name,
    this.goalTags = const [],
    required this.sortOrder,
    required this.exercises,
    this.description,
    this.dayType,
    this.estimatedDurationMinutes,
  });

  final String id;
  final String templateKey;
  final String name;
  final List<String> goalTags;
  final int sortOrder;
  final List<ProgrammeExerciseDraft> exercises;
  final String? description;
  final DayType? dayType;
  final int? estimatedDurationMinutes;
}
