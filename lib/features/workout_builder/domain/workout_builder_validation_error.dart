enum WorkoutBuilderValidationScope { workout, exercise, set }

class WorkoutBuilderValidationError {
  const WorkoutBuilderValidationError({
    required this.scope,
    required this.code,
    required this.message,
    this.exerciseId,
    this.setId,
  });

  final WorkoutBuilderValidationScope scope;
  final String code;
  final String message;
  final String? exerciseId;
  final String? setId;
}
