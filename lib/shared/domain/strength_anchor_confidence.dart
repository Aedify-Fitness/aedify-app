enum StrengthAnchorConfidence {
  low,
  medium,
  high;

  String get dbValue => name;

  static StrengthAnchorConfidence fromDb(String value) {
    return StrengthAnchorConfidence.values.firstWhere(
      (e) => e.dbValue == value,
    );
  }
}
