enum WorkoutSource {
  aiGenerated,
  aiChat,
  custom,
  manual;

  String get dbValue {
    return switch (this) {
      WorkoutSource.aiGenerated => 'ai_generated',
      WorkoutSource.aiChat => 'ai_chat',
      _ => name,
    };
  }

  static WorkoutSource? fromDb(String? value) {
    if (value == null) return null;
    return WorkoutSource.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WorkoutSource.manual,
    );
  }
}
