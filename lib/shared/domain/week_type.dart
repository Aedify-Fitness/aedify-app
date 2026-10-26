enum WeekType {
  normal,
  deload,
  test,
  taper,
  hypertrophy,
  strength;

  String get dbValue => name;

  static WeekType? fromDb(String? value) {
    if (value == null) return null;
    return WeekType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WeekType.normal,
    );
  }
}
