enum ProgramStatus {
  draft,
  inactive,
  active,
  completed,
  archived;

  String get dbValue => name;

  static ProgramStatus fromDb(String value) {
    return ProgramStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ProgramStatus.draft,
    );
  }
}
