import 'package:aedify/shared/domain/day_type.dart';
import 'programme_exercise_draft.dart';

class ProgrammeBuilderTemplateDraft {
  const ProgrammeBuilderTemplateDraft({
    required this.id,
    required this.templateKey,
    required this.name,
    this.dayType,
    this.description,
    this.estimatedDurationMinutes,
    this.restBetweenExercisesSeconds,
    this.exercises = const [],
  });

  final String id;
  final String templateKey;
  final String name;
  final DayType? dayType;
  final String? description;
  final int? estimatedDurationMinutes;
  final int? restBetweenExercisesSeconds;
  final List<ProgrammeExerciseDraft> exercises;

  ProgrammeBuilderTemplateDraft copyWith({
    String? id,
    String? templateKey,
    String? name,
    DayType? dayType,
    String? description,
    int? estimatedDurationMinutes,
    int? restBetweenExercisesSeconds,
    List<ProgrammeExerciseDraft>? exercises,
  }) {
    return ProgrammeBuilderTemplateDraft(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      name: name ?? this.name,
      dayType: dayType ?? this.dayType,
      description: description ?? this.description,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
      exercises: exercises ?? this.exercises,
    );
  }
}
