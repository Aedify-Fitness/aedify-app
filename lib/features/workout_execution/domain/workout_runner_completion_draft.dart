class WorkoutRunnerCompletionDraft {
  const WorkoutRunnerCompletionDraft({
    required this.sessionId,
    required this.completedAt,
    required this.durationSeconds,
    this.notes,
    this.energyLevel,
    this.perceivedDifficulty,
  });

  final String sessionId;
  final DateTime completedAt;
  final int durationSeconds;
  final String? notes;
  final int? energyLevel;
  final int? perceivedDifficulty;
}
