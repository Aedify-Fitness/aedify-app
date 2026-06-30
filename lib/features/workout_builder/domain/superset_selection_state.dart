class SupersetSelectionState {
  const SupersetSelectionState({required this.selectedExerciseIds});

  final Set<String> selectedExerciseIds;

  bool get canCreateSuperset => selectedExerciseIds.length >= 2;
}
