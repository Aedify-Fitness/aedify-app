import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log_order.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

/// Computes PRD FR-6.4 Epley estimates from completed working-set evidence.
///
/// This uses weight × (1 + reps / 30) without RPE/RIR adjustments, rounding or a
/// special case for one rep. Source eligibility (completed sessions, working
/// sets, not skipped) belongs to the analytics repository. Positive finite load,
/// positive reps, strength modality and weighted-reps mode are required here.
/// Bodyweight-only equipment lacks the total-load model needed for this formula.
class EstimatedOneRepMaxService {
  const EstimatedOneRepMaxService();

  static const maximumReliableReps = 10;
  static const _epleyDivisor = 30;

  /// Estimates one eligible set, or returns `null` for unsupported/invalid data.
  EstimatedOneRepMax? estimate(AnalyticsSetLog log) {
    final weight = log.actualWeightKg;
    final reps = log.actualReps;
    if (log.modality != ExerciseModality.strength ||
        log.loggingType != ExerciseLoggingType.repsWeight ||
        log.equipment?.trim().toLowerCase() == 'bodyweight' ||
        weight == null ||
        !weight.isFinite ||
        weight <= 0 ||
        reps == null ||
        reps <= 0) {
      return null;
    }
    final value = weight * (1 + reps / _epleyDivisor);
    if (!value.isFinite || value <= 0) return null;
    return EstimatedOneRepMax(
      exerciseId: log.exerciseId,
      setLogId: log.id,
      sessionId: log.sessionId,
      performedAt: log.performedAt,
      weightKg: weight,
      reps: reps,
      estimatedWeightKg: value,
      confidence: reps <= maximumReliableReps
          ? EstimatedOneRepMaxConfidence.standard
          : EstimatedOneRepMaxConfidence.low,
    );
  }

  /// Builds chronological immutable estimates without changing [logs] or storage.
  EstimatedOneRepMaxSummary summarize(Iterable<AnalyticsSetLog> logs) {
    final ordered = logs.toList()..sort(AnalyticsSetLogOrder.compare);
    return EstimatedOneRepMaxSummary(
      ordered.map(estimate).whereType<EstimatedOneRepMax>(),
    );
  }
}
