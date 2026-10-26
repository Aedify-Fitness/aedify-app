enum LoadingModel {
  fixedPercent1rm,
  percent1rmBracket,
  rpeTarget,
  rpeRange,
  topSetBackoff,
  doubleProgression,
  linear,
  calibration,
  bodyweight,
  timeBased;

  String get dbValue {
    return switch (this) {
      LoadingModel.fixedPercent1rm => 'fixed_percent_1rm',
      LoadingModel.percent1rmBracket => 'percent_1rm_bracket',
      LoadingModel.rpeTarget => 'rpe_target',
      LoadingModel.rpeRange => 'rpe_range',
      LoadingModel.topSetBackoff => 'top_set_backoff',
      LoadingModel.doubleProgression => 'double_progression',
      _ => name,
    };
  }

  static LoadingModel? fromDb(String? value) {
    if (value == null) return null;
    return LoadingModel.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LoadingModel.fixedPercent1rm,
    );
  }
}
