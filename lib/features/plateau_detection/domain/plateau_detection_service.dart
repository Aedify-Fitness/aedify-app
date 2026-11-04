import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log_order.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max_service.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/set_effort.dart';

/// Evaluates FR-7.1 locally: four recent sessions and a rolling three-session trend.
///
/// Uses each session's top standard-confidence Epley value, within the inclusive
/// 28-day window ending at [evaluate]'s explicit clock. A deload or unknown
/// context in the latest three exposures suppresses detection. High-rep-only
/// exposures remain in chronology rather than being skipped to imply a stall.
class PlateauDetectionService {
  const PlateauDetectionService();
  static const historyWindow = Duration(days: 28);
  static const dismissalWindow = Duration(days: 14);
  static const minimumSessions = 4;
  static const trendSessions = 3;
  static const _estimator = EstimatedOneRepMaxService();
  static const _highEffortRpe = 9;

  /// Returns immutable per-exercise outcomes using completed working-set [logs].
  ///
  /// A missed exact/minimum rep target or positive prescribed load is evidence,
  /// not a prerequisite for a plateau: the locked trigger is slope ≤ 0.
  List<PlateauEvaluation> evaluate(
    Iterable<AnalyticsSetLog> logs, {
    required DateTime now,
    Map<int, DateTime> dismissedAt = const {},
  }) {
    final from = now.subtract(historyWindow);
    final grouped = <int, List<AnalyticsSetLog>>{};
    for (final log in logs) {
      if (log.performedAt.isBefore(from) || log.performedAt.isAfter(now)) {
        continue;
      }
      grouped.putIfAbsent(log.exerciseId, () => []).add(log);
    }
    final ids = grouped.keys.toList()..sort();
    return List.unmodifiable(
      ids.map((id) => _evaluateExercise(grouped[id]!, now, dismissedAt[id])),
    );
  }

  PlateauEvaluation _evaluateExercise(
    List<AnalyticsSetLog> logs,
    DateTime now,
    DateTime? dismissedAt,
  ) {
    final ordered = logs.toList()..sort(AnalyticsSetLogOrder.compare);
    final bySession = <String, List<AnalyticsSetLog>>{};
    for (final log in ordered) {
      bySession.putIfAbsent(log.sessionId, () => []).add(log);
    }
    final sessions = bySession.values.map(_summarizeSession).toList()
      ..sort((left, right) => left.performedAt.compareTo(right.performedAt));
    final recent = sessions
        .skip(
          sessions.length > trendSessions ? sessions.length - trendSessions : 0,
        )
        .toList();
    final qualifying = sessions
        .where((session) => session.topEstimatedKg != null)
        .length;
    PlateauEvaluation result(
      PlateauOutcome outcome, {
      double? slope,
      List<PlateauReason> reasons = const [],
    }) => PlateauEvaluation(
      exerciseId: ordered.first.exerciseId,
      outcome: outcome,
      qualifyingSessions: qualifying,
      recentSessions: recent,
      slopeKgPerSession: slope,
      reasons: reasons,
    );
    if (ordered.any((log) => !log.isPlateauEligible)) {
      return result(PlateauOutcome.inactive);
    }
    if (ordered.any(
      (log) =>
          log.modality != ExerciseModality.strength ||
          log.loggingType != ExerciseLoggingType.repsWeight,
    )) {
      return result(PlateauOutcome.unsupported);
    }
    if (recent.any((session) => session.isDeload == true)) {
      return result(PlateauOutcome.deload);
    }
    if (recent.any((session) => session.isDeload == null)) {
      return result(PlateauOutcome.unknownContext);
    }
    if (qualifying < minimumSessions ||
        recent.any((session) => session.topEstimatedKg == null)) {
      return result(PlateauOutcome.insufficientHistory);
    }
    // Least-squares slope over three equally spaced session indices (0, 1, 2).
    final slope =
        (recent.last.topEstimatedKg! - recent.first.topEstimatedKg!) /
        (trendSessions - 1);
    if (slope > 0) return result(PlateauOutcome.progressing, slope: slope);
    final reasons = [
      PlateauReason.nonIncreasingE1rm,
      if (recent.any((session) => session.missedTargets > 0))
        PlateauReason.missedTargets,
      if (recent.any((session) => session.highEffortSets > 0))
        PlateauReason.highEffort,
    ];
    final suppressed =
        dismissedAt != null && now.isBefore(dismissedAt.add(dismissalWindow));
    return result(
      suppressed ? PlateauOutcome.dismissed : PlateauOutcome.plateau,
      slope: slope,
      reasons: reasons,
    );
  }

  static PlateauSessionMetric _summarizeSession(List<AnalyticsSetLog> logs) {
    double? top;
    var misses = 0;
    var highEffort = 0;
    for (final log in logs) {
      final estimate = _estimator.estimate(log);
      if (estimate != null &&
          estimate.isAnchorCandidate &&
          (top == null || estimate.estimatedWeightKg > top)) {
        top = estimate.estimatedWeightKg;
      }
      final reps = log.prescribedRepsExact ?? log.prescribedRepsMin;
      final weight = log.prescribedWeightKg;
      final actualReps = log.actualReps;
      final actualWeight = log.actualWeightKg;
      final missedReps =
          reps != null &&
          reps > 0 &&
          actualReps != null &&
          actualReps > 0 &&
          actualReps < reps;
      final missedLoad =
          weight != null &&
          weight.isFinite &&
          weight > 0 &&
          actualWeight != null &&
          actualWeight.isFinite &&
          actualWeight >= 0 &&
          actualWeight < weight;
      if (missedReps || missedLoad) {
        misses++;
      }
      final effort = log.actualRpe ?? SetEffort.rpeFromRir(log.actualRir);
      if (effort != null &&
          effort.isFinite &&
          effort >= _highEffortRpe &&
          effort <= 10) {
        highEffort++;
      }
    }
    return PlateauSessionMetric(
      performedAt: logs.last.performedAt,
      topEstimatedKg: top,
      workingSets: logs.length,
      missedTargets: misses,
      highEffortSets: highEffort,
      isDeload: logs.any((log) => log.isDeload == true)
          ? true
          : logs.any((log) => log.isDeload == null)
          ? null
          : false,
    );
  }
}
