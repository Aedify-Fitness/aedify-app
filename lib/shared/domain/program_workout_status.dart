enum ProgramWorkoutStatus {
  planned,
  started,
  completed,
  skipped,
  replaced;

  String get dbValue => name;

  static ProgramWorkoutStatus fromDb(String value) {
    return ProgramWorkoutStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ProgramWorkoutStatus.planned,
    );
  }
}
