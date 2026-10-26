enum SetIntent {
  warmup,
  topSet,
  backoff,
  volume,
  technique,
  pump,
  hypertrophy,
  test,
  taperPractice,
  working;

  String get dbValue {
    return switch (this) {
      SetIntent.topSet => 'top_set',
      SetIntent.taperPractice => 'taper_practice',
      _ => name,
    };
  }

  static SetIntent? fromDb(String? value) {
    if (value == null) return null;
    return SetIntent.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => SetIntent.working,
    );
  }
}
