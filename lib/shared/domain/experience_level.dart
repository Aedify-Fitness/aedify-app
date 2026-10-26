enum ExperienceLevel {
  novice,
  beginner,
  intermediate,
  advanced;

  String get dbValue => name;

  static ExperienceLevel fromDb(String value) {
    return ExperienceLevel.values.firstWhere((e) => e.dbValue == value);
  }
}
