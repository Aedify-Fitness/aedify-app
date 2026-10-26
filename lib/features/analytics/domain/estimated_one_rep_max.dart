/// The confidence band required by PRD FR-6.4 for Epley estimates.
enum EstimatedOneRepMaxConfidence {
  /// An eligible performance with 1–10 reps; still an estimate, not a tested max.
  standard,

  /// A performance above 10 reps, outside the reliable Epley range.
  low,
}

/// A minimal local strength estimate with source identity and confidence.
///
/// This DTO contains no notes, body measurements or raw database rows. Future
/// AI context may use eligible summaries through its operation-specific privacy
/// boundary; this model does not authorize transport or select an AI payload.
class EstimatedOneRepMax {
  const EstimatedOneRepMax({
    required this.exerciseId,
    required this.setLogId,
    required this.sessionId,
    required this.performedAt,
    required this.weightKg,
    required this.reps,
    required this.estimatedWeightKg,
    required this.confidence,
  });

  final int exerciseId;
  final String setLogId;
  final String sessionId;
  final DateTime performedAt;
  final double weightKg;
  final int reps;
  final double estimatedWeightKg;
  final EstimatedOneRepMaxConfidence confidence;

  /// Whether the performance is within the reliable 1–10-rep range.
  ///
  /// Later anchor selection must also enforce recency and exercise/load-model
  /// compatibility. Low-confidence estimates cannot establish strength anchors.
  bool get isAnchorCandidate =>
      confidence == EstimatedOneRepMaxConfidence.standard;
}

/// Immutable per-set estimates and reliable candidates for later local policy.
class EstimatedOneRepMaxSummary {
  EstimatedOneRepMaxSummary(Iterable<EstimatedOneRepMax> estimates)
    : estimates = List.unmodifiable(estimates) {
    anchorCandidates = List.unmodifiable(
      this.estimates.where((estimate) => estimate.isAnchorCandidate),
    );
  }

  final List<EstimatedOneRepMax> estimates;
  late final List<EstimatedOneRepMax> anchorCandidates;

  /// Whether no eligible estimate exists, including low-confidence estimates.
  bool get hasInsufficientData => estimates.isEmpty;
}
