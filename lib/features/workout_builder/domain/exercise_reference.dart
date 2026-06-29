class ExerciseReference {
  const ExerciseReference({
    required this.exerciseId,
    required this.name,
    required this.modality,
    this.equipment,
    this.isCustom = false,
  });

  final int exerciseId;
  final String name;
  final String modality;
  final String? equipment;
  final bool isCustom;
}
