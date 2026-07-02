class ProgrammeWorkoutDetailViewData {
  const ProgrammeWorkoutDetailViewData({
    required this.workoutName,
    required this.dayLabel,
    required this.durationMinutes,
    required this.exercises,
  });

  final String workoutName;
  final String dayLabel;
  final int durationMinutes;
  final List<ExerciseDetailItem> exercises;
}

class ExerciseDetailItem {
  const ExerciseDetailItem({required this.name, required this.sets});

  final String name;
  final List<SetPrescriptionItem> sets;
}

class SetPrescriptionItem {
  const SetPrescriptionItem({
    required this.setIndex,
    required this.setType,
    this.repsDisplay,
    this.weightDisplay,
    this.rpeDisplay,
    this.restSeconds,
    this.notes,
  });

  final int setIndex;
  final String setType;
  final String? repsDisplay;
  final String? weightDisplay;
  final String? rpeDisplay;
  final int? restSeconds;
  final String? notes;
}
