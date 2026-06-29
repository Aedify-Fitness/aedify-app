enum ExerciseVideoGender {
  male,
  female,
  unknown;

  String get dbValue => name;

  static ExerciseVideoGender fromDb(String value) {
    return ExerciseVideoGender.values.firstWhere((e) => e.dbValue == value);
  }
}
