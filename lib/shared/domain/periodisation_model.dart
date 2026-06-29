enum PeriodisationModel {
  default3Plus1,
  block,
  linear,
  undulating,
  sourcePreserved;

  String get dbValue {
    return switch (this) {
      PeriodisationModel.default3Plus1 => 'default_3_plus_1',
      PeriodisationModel.sourcePreserved => 'source_preserved',
      _ => name,
    };
  }

  static PeriodisationModel? fromDb(String? value) {
    if (value == null) return null;
    return PeriodisationModel.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => PeriodisationModel.default3Plus1,
    );
  }
}
