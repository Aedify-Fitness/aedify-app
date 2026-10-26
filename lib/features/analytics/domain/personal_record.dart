/// The supported strength records and their comparison units.
enum PersonalRecordType {
  /// Maximum logged external load in kg for a set with positive reps.
  maxWeight,

  /// Maximum reps at the same canonical kg load, including zero load.
  maxRepsAtWeight,

  /// Maximum reps for a reps-only strength exercise, without a load model.
  maxReps,

  /// Maximum single-set volume in kg × reps.
  volume,
}

/// A local record achievement tied to its source set and completed session.
///
/// [value] and [previousValue] use the unit defined by [type]. For
/// [PersonalRecordType.maxRepsAtWeight], [comparisonWeightKg] identifies the
/// load being compared. The first eligible performance establishes a baseline.
/// This evidence stays local and carries no free-form notes or database rows.
class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.type,
    required this.value,
    required this.setLogId,
    required this.sessionId,
    required this.achievedAt,
    this.previousValue,
    this.comparisonWeightKg,
  });

  final int exerciseId;
  final PersonalRecordType type;
  final num value;
  final num? previousValue;
  final double? comparisonWeightKg;
  final String setLogId;
  final String sessionId;
  final DateTime achievedAt;

  /// Whether this is the first eligible performance for this record comparison.
  bool get isBaseline => previousValue == null;
}

/// Immutable current records and the chronological achievements that built them.
class PersonalRecordSummary {
  PersonalRecordSummary({
    required Iterable<PersonalRecord> current,
    required Iterable<PersonalRecord> history,
  }) : current = List.unmodifiable(current),
       history = List.unmodifiable(history);

  final List<PersonalRecord> current;
  final List<PersonalRecord> history;
}
