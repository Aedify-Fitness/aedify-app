enum DayType {
  upper,
  lower,
  push,
  pull,
  legs,
  fullBody,
  custom;

  String get dbValue {
    return switch (this) {
      DayType.fullBody => 'full_body',
      _ => name,
    };
  }

  static DayType? fromDb(String? value) {
    if (value == null) return null;
    return DayType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => DayType.upper,
    );
  }
}
