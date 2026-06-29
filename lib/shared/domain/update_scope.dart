enum UpdateScope {
  singleOccurrence,
  futureOccurrences,
  entireProgram;

  String get dbValue {
    return switch (this) {
      UpdateScope.singleOccurrence => 'single_occurrence',
      UpdateScope.futureOccurrences => 'future_occurrences',
      UpdateScope.entireProgram => 'entire_program',
    };
  }

  static UpdateScope? fromDb(String? value) {
    if (value == null) return null;
    return UpdateScope.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => UpdateScope.singleOccurrence,
    );
  }
}
