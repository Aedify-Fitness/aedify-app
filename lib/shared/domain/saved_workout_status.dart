enum SavedWorkoutStatus {
  active,
  archived,
  deleted;

  String get dbValue => name;

  static SavedWorkoutStatus fromDb(String value) {
    return SavedWorkoutStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => SavedWorkoutStatus.active,
    );
  }
}
