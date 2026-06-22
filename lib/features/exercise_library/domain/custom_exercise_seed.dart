class CustomExerciseSeed {
  const CustomExerciseSeed({
    required this.name,
    required this.muscleGroups,
    required this.modality,
    this.equipment,
    this.difficulty,
    this.steps = const <String>[],
  });

  final String name;
  final List<String> muscleGroups;
  final String modality;
  final String? equipment;
  final String? difficulty;
  final List<String> steps;
}
