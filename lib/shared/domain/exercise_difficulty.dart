enum ExerciseDifficulty {
  novice,
  beginner,
  intermediate,
  advanced;

  String get dbValue => name;

  static ExerciseDifficulty fromDb(String value) {
    return ExerciseDifficulty.values.firstWhere((e) => e.dbValue == value);
  }
}
