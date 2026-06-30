import 'package:aedify/core/validation/validated_exercise_draft.dart';

class ValidatedProgrammeTemplateDraft {
  const ValidatedProgrammeTemplateDraft({
    required this.templateKey,
    required this.exercises,
  });

  final String templateKey;
  final List<ValidatedExerciseDraft> exercises;
}
