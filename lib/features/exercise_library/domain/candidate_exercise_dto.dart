class CandidateExerciseDto {
  const CandidateExerciseDto({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.muscleGroups,
    required this.modality,
    required this.equipment,
    required this.mechanic,
    required this.force,
    required this.isCustom,
  });

  final int id;
  final String name;
  final String? difficulty;
  final List<String> muscleGroups;
  final String modality;
  final String? equipment;
  final String? mechanic;
  final String? force;
  final bool isCustom;
}
