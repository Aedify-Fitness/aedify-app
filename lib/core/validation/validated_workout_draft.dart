import 'package:aedify/core/validation/validated_exercise_draft.dart';

class ValidatedWorkoutDraft {
  const ValidatedWorkoutDraft({required this.name, required this.exercises});

  final String name;
  final List<ValidatedExerciseDraft> exercises;
}
