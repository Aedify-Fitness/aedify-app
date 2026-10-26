enum TrainingDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get displayLabel {
    return switch (this) {
      TrainingDay.monday => 'Mon',
      TrainingDay.tuesday => 'Tue',
      TrainingDay.wednesday => 'Wed',
      TrainingDay.thursday => 'Thu',
      TrainingDay.friday => 'Fri',
      TrainingDay.saturday => 'Sat',
      TrainingDay.sunday => 'Sun',
    };
  }

  String get fullDisplayLabel {
    return switch (this) {
      TrainingDay.monday => 'Monday',
      TrainingDay.tuesday => 'Tuesday',
      TrainingDay.wednesday => 'Wednesday',
      TrainingDay.thursday => 'Thursday',
      TrainingDay.friday => 'Friday',
      TrainingDay.saturday => 'Saturday',
      TrainingDay.sunday => 'Sunday',
    };
  }

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
