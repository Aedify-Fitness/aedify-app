enum ExerciseMechanic {
  compound,
  isolation;

  String get dbValue => name;

  static ExerciseMechanic fromDb(String value) {
    return ExerciseMechanic.values.firstWhere((e) => e.dbValue == value);
  }
}
