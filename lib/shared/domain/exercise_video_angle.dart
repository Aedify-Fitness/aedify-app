enum ExerciseVideoAngle {
  front,
  side,
  other;

  String get dbValue => name;

  static ExerciseVideoAngle fromDb(String value) {
    return ExerciseVideoAngle.values.firstWhere((e) => e.dbValue == value);
  }
}
