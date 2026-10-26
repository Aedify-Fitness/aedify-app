enum WorkoutSessionStatus {
  inProgress,
  completed,
  abandoned,
  deleted;

  String get dbValue {
    return switch (this) {
      WorkoutSessionStatus.inProgress => 'in_progress',
      _ => name,
    };
  }

  static WorkoutSessionStatus fromDb(String value) {
    return WorkoutSessionStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WorkoutSessionStatus.inProgress,
    );
  }
}
