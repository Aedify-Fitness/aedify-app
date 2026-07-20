class ExerciseReference {
  const ExerciseReference({
    required this.exerciseId,
    required this.name,
    required this.modality,
    this.loggingType,
    this.equipment,
    this.isCustom = false,
  });

  final int exerciseId;
  final String name;
  final String modality;
  final String? loggingType;
  final String? equipment;
  final bool isCustom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseReference &&
          exerciseId == other.exerciseId &&
          name == other.name &&
          modality == other.modality &&
          loggingType == other.loggingType &&
          equipment == other.equipment &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      Object.hash(exerciseId, name, modality, loggingType, equipment, isCustom);
}
