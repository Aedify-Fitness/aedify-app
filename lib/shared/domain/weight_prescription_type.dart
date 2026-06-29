enum WeightPrescriptionType {
  absolute,
  percent1rm,
  bodyweightBased,
  bodyweightOnly,
  notApplicable;

  String get dbValue {
    return switch (this) {
      WeightPrescriptionType.percent1rm => 'percent_1rm',
      WeightPrescriptionType.bodyweightBased => 'bodyweight_based',
      WeightPrescriptionType.bodyweightOnly => 'bodyweight_only',
      WeightPrescriptionType.notApplicable => 'not_applicable',
      _ => name,
    };
  }

  static WeightPrescriptionType? fromDb(String? value) {
    if (value == null) return null;
    return WeightPrescriptionType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WeightPrescriptionType.absolute,
    );
  }
}
