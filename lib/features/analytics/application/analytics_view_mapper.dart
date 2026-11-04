import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log_order.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max_service.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/domain/personal_record_service.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

/// Prepares counts/series from local working-set evidence, without display conversion.
class AnalyticsViewMapper {
  const AnalyticsViewMapper();
  static const _records = PersonalRecordService();
  static const _estimates = EstimatedOneRepMaxService();

  static DateTime weekStart(DateTime date) {
    final local = date.toLocal();
    return DateTime(
      local.year,
      local.month,
      local.day - (local.weekday - DateTime.monday),
    );
  }

  static DateTime? rangeStart(AnalyticsRange range, DateTime now) {
    final week = weekStart(now);
    return switch (range) {
      AnalyticsRange.fourWeeks => DateTime(
        week.year,
        week.month,
        week.day - 21,
      ),
      AnalyticsRange.twelveWeeks => DateTime(
        week.year,
        week.month,
        week.day - 77,
      ),
      AnalyticsRange.allTime => null,
    };
  }

  AnalyticsViewData map(
    Iterable<AnalyticsSetLog> source, {
    required AnalyticsRange range,
    required DateTime now,
    int? exerciseId,
  }) {
    final all =
        source
            .where(
              (log) =>
                  !log.performedAt.isAfter(now) &&
                  (exerciseId == null || log.exerciseId == exerciseId),
            )
            .toList()
          ..sort(AnalyticsSetLogOrder.compare);
    final from = rangeStart(range, now);
    final visible = all
        .where(
          (log) =>
              (from == null || !log.performedAt.isBefore(from)) &&
              _hasResults(log),
        )
        .toList();
    // Record comparisons always see history preceding the visible date window.
    final records = _records.detect(all);
    final filteredRecords = PersonalRecordSummary(
      current: records.current,
      history: records.history.where(
        (record) => from == null || !record.achievedAt.isBefore(from),
      ),
    );
    final estimates = _estimates.summarize(visible);
    final groups = <int, List<AnalyticsSetLog>>{};
    final bySession = <String, List<AnalyticsSetLog>>{};
    final weeks = <DateTime, double>{};
    var hasVolume = false;
    double total = 0;
    for (final log in visible) {
      groups.putIfAbsent(log.exerciseId, () => []).add(log);
      bySession.putIfAbsent(log.sessionId, () => []).add(log);
      final value = _volume(log);
      if (value == null) continue;
      hasVolume = true;
      total = _sum(total, value);
      final week = weekStart(log.performedAt);
      weeks[week] = _sum(weeks[week] ?? 0, value);
    }
    final exercises =
        groups.entries
            .map(
              (entry) => AnalyticsExerciseSummary(
                id: entry.key,
                name:
                    entry.value.last.exerciseName ??
                    WorkoutHistoryStrings.exerciseReference(entry.key),
                sessions: entry.value
                    .map((log) => log.sessionId)
                    .toSet()
                    .length,
                sets: entry.value.length,
                latest: entry.value.last.performedAt,
              ),
            )
            .toList()
          ..sort((a, b) {
            final byDate = b.latest.compareTo(a.latest);
            return byDate != 0 ? byDate : a.id.compareTo(b.id);
          });
    final strength = <String, AnalyticsChartPoint>{};
    for (final estimate in estimates.anchorCandidates) {
      final existing = strength[estimate.sessionId];
      if (existing == null || estimate.estimatedWeightKg > existing.value) {
        strength[estimate.sessionId] = AnalyticsChartPoint(
          estimate.performedAt,
          estimate.estimatedWeightKg,
        );
      }
    }
    final strengthPoints = strength.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final sessionVolume = <AnalyticsChartPoint>[];
    for (final session in bySession.values) {
      final values = session.map(_volume).whereType<double>();
      final sum = values.fold<double>(0, _sum);
      if (values.isNotEmpty && sum.isFinite) {
        sessionVolume.add(AnalyticsChartPoint(session.last.performedAt, sum));
      }
    }
    sessionVolume.sort((a, b) => a.date.compareTo(b.date));
    final thisWeek = weekStart(now);
    final previousWeek = DateTime(
      thisWeek.year,
      thisWeek.month,
      thisWeek.day - 7,
    );
    // Compare calendar weeks independently from the selected display range.
    double? weekVolume(DateTime week) {
      final values = all
          .where((log) => weekStart(log.performedAt) == week)
          .map(_volume)
          .whereType<double>();
      final sum = values.fold<double>(0, _sum);
      return values.isEmpty || !sum.isFinite ? null : sum;
    }

    final weekly = <AnalyticsChartPoint>[];
    if (hasVolume) {
      final first = from ?? weekStart(visible.first.performedAt);
      for (
        var week = first;
        !week.isAfter(thisWeek);
        week = DateTime(week.year, week.month, week.day + 7)
      ) {
        final value = weeks[week] ?? 0;
        if (value.isFinite) weekly.add(AnalyticsChartPoint(week, value));
      }
    }
    final current = weekVolume(thisWeek);
    final previous = weekVolume(previousWeek);
    final change = previous != null && previous > 0 && current != null
        ? (current - previous) / previous * 100
        : null;
    return AnalyticsViewData(
      sessions: bySession.length,
      workingSets: visible.length,
      volumeKgReps: hasVolume && total.isFinite ? total : null,
      currentWeekVolume: current,
      previousWeekVolume: previous,
      hasAnyHistory: all.isNotEmpty,
      weekChangePercent: change != null && change.isFinite ? change : null,
      exerciseNames: {
        for (final log in all)
          log.exerciseId:
              log.exerciseName ??
              WorkoutHistoryStrings.exerciseReference(log.exerciseId),
      },
      records: filteredRecords,
      estimates: estimates,
      weeklyVolume: weekly,
      strengthTrend: strengthPoints,
      sessionVolume: sessionVolume,
      exercises: exercises,
    );
  }

  static bool _hasResults(AnalyticsSetLog log) => switch (log.loggingType) {
    ExerciseLoggingType.repsWeight =>
      log.actualReps != null &&
          log.actualReps! > 0 &&
          log.actualWeightKg != null &&
          log.actualWeightKg!.isFinite &&
          log.actualWeightKg! >= 0,
    ExerciseLoggingType.repsOnly =>
      log.actualReps != null && log.actualReps! > 0,
    ExerciseLoggingType.duration =>
      log.actualDurationSeconds != null && log.actualDurationSeconds! > 0,
    null =>
      log.actualReps != null && log.actualReps! > 0 ||
          log.actualDurationSeconds != null && log.actualDurationSeconds! > 0,
  };
  static double? _volume(AnalyticsSetLog log) {
    if (log.modality != ExerciseModality.strength ||
        log.loggingType != ExerciseLoggingType.repsWeight ||
        !_hasResults(log)) {
      return null;
    }
    final volume = log.actualWeightKg! * log.actualReps!;
    return volume.isFinite ? volume : null;
  }

  static double _sum(double left, double right) => left + right;
}
