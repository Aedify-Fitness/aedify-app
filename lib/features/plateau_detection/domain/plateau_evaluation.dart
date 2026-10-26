/// Deterministic detector outcomes, separate from retryable storage failures.
enum PlateauOutcome {
  plateau,
  progressing,
  insufficientHistory,
  deload,
  unknownContext,
  inactive,
  unsupported,
  dismissed,
}

/// Derived evidence codes, without coaching advice or free-form user text.
enum PlateauReason { nonIncreasingE1rm, missedTargets, highEffort }

/// A single exposure summarized from working sets for one exercise.
class PlateauSessionMetric {
  const PlateauSessionMetric({
    required this.performedAt,
    required this.topEstimatedKg,
    required this.workingSets,
    required this.missedTargets,
    required this.highEffortSets,
    required this.isDeload,
  });
  final DateTime performedAt;
  final double? topEstimatedKg;
  final int workingSets;
  final int missedTargets;
  final int highEffortSets;
  final bool? isDeload;
}

/// Minimal local plateau context for later UI and operation-scoped AI filtering.
///
/// No notes, injuries, body metrics, raw sets or database rows are included.
/// Missed targets/effort describe evidence; they do not diagnose fatigue/injury.
class PlateauEvaluation {
  PlateauEvaluation({
    required this.exerciseId,
    required this.outcome,
    required this.qualifyingSessions,
    required Iterable<PlateauSessionMetric> recentSessions,
    Iterable<PlateauReason> reasons = const [],
    this.slopeKgPerSession,
  }) : recentSessions = List.unmodifiable(recentSessions),
       reasons = List.unmodifiable(reasons);

  final int exerciseId;
  final PlateauOutcome outcome;
  final int qualifyingSessions;
  final List<PlateauSessionMetric> recentSessions;
  final List<PlateauReason> reasons;
  final double? slopeKgPerSession;
}

/// Safe codes only: source SQL errors may contain private parameters.
enum PlateauFailure implements Exception { unavailable, missing }
