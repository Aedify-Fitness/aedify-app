enum ProviderValidationStatus {
  valid,
  invalid,
  unknown,
  rateLimited;

  String get dbValue {
    return switch (this) {
      ProviderValidationStatus.rateLimited => 'rate_limited',
      _ => name,
    };
  }

  static ProviderValidationStatus fromDb(String value) {
    return ProviderValidationStatus.values.firstWhere(
      (e) => e.dbValue == value,
    );
  }
}
