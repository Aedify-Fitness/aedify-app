class CandidateExerciseQuery {
  const CandidateExerciseQuery({
    required this.allowedEquipment,
    required this.allowedDifficulties,
    required this.allowedModalities,
    required this.excludedExerciseIds,
    required this.excludedMuscleGroups,
    required this.goalTags,
    this.preferredMuscleGroups = const [],
    this.includeCustomExercises = true,
    this.limit = 25,
  });

  final Set<String> allowedEquipment;
  final Set<String> allowedDifficulties;
  final Set<String> allowedModalities;
  final Set<int> excludedExerciseIds;
  final Set<String> excludedMuscleGroups;
  final Set<String> goalTags;
  final List<String> preferredMuscleGroups;
  final bool includeCustomExercises;
  final int limit;
}
