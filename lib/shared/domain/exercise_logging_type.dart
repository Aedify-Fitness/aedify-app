enum ExerciseLoggingType {
  repsWeight,
  repsOnly,
  duration;

  String get dbValue => name;

  static ExerciseLoggingType fromDb(String value) {
    return ExerciseLoggingType.values.firstWhere((e) => e.dbValue == value);
  }

  static ExerciseLoggingType fromDbWithDefault(
    String? dbValue, [
    ExerciseLoggingType defaultValue = ExerciseLoggingType.repsWeight,
  ]) {
    if (dbValue == null || dbValue.isEmpty) return defaultValue;
    return ExerciseLoggingType.fromDb(dbValue);
  }
}
