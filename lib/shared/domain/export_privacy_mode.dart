enum ExportPrivacyMode {
  template,
  exactPrescription;

  String get dbValue {
    return switch (this) {
      ExportPrivacyMode.exactPrescription => 'exact_prescription',
      _ => name,
    };
  }

  static ExportPrivacyMode? fromDb(String? value) {
    if (value == null) return null;
    return ExportPrivacyMode.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ExportPrivacyMode.template,
    );
  }
}
