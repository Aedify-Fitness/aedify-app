enum SetType {
  warmup,
  working;

  String get dbValue => name;

  static SetType fromDb(String value) {
    return SetType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => SetType.working,
    );
  }
}
