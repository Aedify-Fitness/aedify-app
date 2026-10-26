enum ExerciseModality {
  strength,
  flexibility,
  cardio,
  recovery;

  String get dbValue => name;

  static ExerciseModality fromDb(String value) {
    return ExerciseModality.values.firstWhere((e) => e.dbValue == value);
  }
}
