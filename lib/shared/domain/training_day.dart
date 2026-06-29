enum TrainingDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get dbValue {
    return switch (this) {
      TrainingDay.monday => 'mon',
      TrainingDay.tuesday => 'tue',
      TrainingDay.wednesday => 'wed',
      TrainingDay.thursday => 'thu',
      TrainingDay.friday => 'fri',
      TrainingDay.saturday => 'sat',
      TrainingDay.sunday => 'sun',
    };
  }

  static TrainingDay fromDb(String value) {
    return TrainingDay.values.firstWhere((e) => e.dbValue == value);
  }
}
