enum CustomExerciseValidationScope { name, muscleGroups, modality, steps }

class CustomExerciseValidationError {
  const CustomExerciseValidationError({
    required this.scope,
    required this.code,
    required this.message,
    this.stepIndex,
  });

  final CustomExerciseValidationScope scope;
  final String code;
  final String message;
  final int? stepIndex;
}
