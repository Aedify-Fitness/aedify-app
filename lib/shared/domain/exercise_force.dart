enum ExerciseForce {
  push,
  pull,
  hold;

  String get dbValue => name;

  static ExerciseForce fromDb(String value) {
    return ExerciseForce.values.firstWhere((e) => e.dbValue == value);
  }
}
