enum StrengthAnchorSource {
  userEntered,
  logDerived,
  aiSeeded,
  imported;

  String get dbValue {
    return switch (this) {
      StrengthAnchorSource.userEntered => 'user_entered',
      StrengthAnchorSource.logDerived => 'log_derived',
      StrengthAnchorSource.aiSeeded => 'ai_seeded',
      _ => name,
    };
  }

  static StrengthAnchorSource fromDb(String value) {
    return StrengthAnchorSource.values.firstWhere((e) => e.dbValue == value);
  }
}
