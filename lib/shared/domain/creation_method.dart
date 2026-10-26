enum CreationMethod {
  manual,
  aiGenerated,
  aiChatSave,
  aiFileImport;

  String get dbValue {
    return switch (this) {
      CreationMethod.aiGenerated => 'ai_generated',
      CreationMethod.aiChatSave => 'ai_chat_save',
      CreationMethod.aiFileImport => 'ai_file_import',
      _ => name,
    };
  }

  static CreationMethod? fromDb(String? value) {
    if (value == null) return null;
    return CreationMethod.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CreationMethod.manual,
    );
  }
}
