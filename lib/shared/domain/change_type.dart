enum ChangeType {
  created,
  manualEdit,
  aiSwap,
  aiDeload,
  importFix,
  scheduleChange;

  String get dbValue {
    return switch (this) {
      ChangeType.manualEdit => 'manual_edit',
      ChangeType.aiSwap => 'ai_swap',
      ChangeType.aiDeload => 'ai_deload',
      ChangeType.importFix => 'import_fix',
      ChangeType.scheduleChange => 'schedule_change',
      _ => name,
    };
  }

  static ChangeType fromDb(String value) {
    return ChangeType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ChangeType.created,
    );
  }
}
