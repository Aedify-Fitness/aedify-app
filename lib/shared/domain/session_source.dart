enum SessionSource {
  program,
  savedWorkout,
  standalone;

  String get dbValue {
    return switch (this) {
      SessionSource.savedWorkout => 'saved_workout',
      _ => name,
    };
  }

  static SessionSource? fromDb(String? value) {
    if (value == null) return null;
    return SessionSource.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => SessionSource.standalone,
    );
  }
}
