enum AiProviderName {
  openai,
  anthropic,
  google,
  otherSupported;

  String get dbValue {
    return switch (this) {
      AiProviderName.otherSupported => 'other_supported',
      _ => name,
    };
  }

  static AiProviderName fromDb(String value) {
    return AiProviderName.values.firstWhere((e) => e.dbValue == value);
  }
}
