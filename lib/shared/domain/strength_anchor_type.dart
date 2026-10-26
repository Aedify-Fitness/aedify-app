enum StrengthAnchorType {
  known1rm,
  estimated1rm,
  workingWeight,
  calibrationEstimate;

  String get dbValue {
    return switch (this) {
      StrengthAnchorType.known1rm => 'known_1rm',
      StrengthAnchorType.estimated1rm => 'estimated_1rm',
      StrengthAnchorType.workingWeight => 'working_weight',
      StrengthAnchorType.calibrationEstimate => 'calibration_estimate',
    };
  }

  static StrengthAnchorType fromDb(String value) {
    return StrengthAnchorType.values.firstWhere((e) => e.dbValue == value);
  }
}
