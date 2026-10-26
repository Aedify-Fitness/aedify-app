enum ImportOrigin {
  externalFile,
  aedifyplan;

  String get dbValue {
    return switch (this) {
      ImportOrigin.externalFile => 'external_file',
      _ => name,
    };
  }

  static ImportOrigin? fromDb(String? value) {
    if (value == null) return null;
    return ImportOrigin.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ImportOrigin.externalFile,
    );
  }
}
