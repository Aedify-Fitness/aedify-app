class ExerciseListItem {
  const ExerciseListItem({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.muscleGroups,
    required this.modality,
    required this.equipment,
    required this.isFavorite,
    required this.isSubstitutedOut,
  });

  final int id;
  final String name;
  final String? difficulty;
  final List<String> muscleGroups;
  final String modality;
  final String? equipment;
  final bool isFavorite;
  final bool isSubstitutedOut;
}
