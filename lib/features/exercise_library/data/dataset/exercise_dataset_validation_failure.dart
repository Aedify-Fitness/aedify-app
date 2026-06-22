enum ExerciseDatasetValidationFailureCode {
  invalidTopLevelShape,
  missingRequiredField,
  unsupportedSchemaVersion,
  unsupportedMinimumAppSchemaVersion,
  exerciseCountMismatch,
  duplicateExerciseId,
  invalidDifficulty,
  invalidModality,
  invalidMuscleGroup,
  invalidPrimaryMuscles,
  invalidSteps,
  invalidVideos,
  invalidVideoUrl,
  invalidStrengthEquipment,
}

class ExerciseDatasetValidationFailure implements Exception {
  const ExerciseDatasetValidationFailure({
    required this.code,
    required this.message,
    this.field,
    this.exerciseId,
  });

  final ExerciseDatasetValidationFailureCode code;
  final String message;
  final String? field;
  final int? exerciseId;

  @override
  String toString() {
    final buffer = StringBuffer(
      'ExerciseDatasetValidationFailure(${code.name})',
    );
    buffer.write(': $message');
    if (field != null) buffer.write(' (field: $field)');
    if (exerciseId != null) buffer.write(' (exerciseId: $exerciseId)');
    return buffer.toString();
  }
}
