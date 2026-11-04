import 'package:aedify/features/analytics/domain/estimated_one_rep_max.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';

enum AnalyticsRange { fourWeeks, twelveWeeks, allTime }

/// Canonical metric chart points, converted only in presentation.
class AnalyticsChartPoint {
  const AnalyticsChartPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

class AnalyticsExerciseSummary {
  const AnalyticsExerciseSummary({
    required this.id,
    required this.name,
    required this.sessions,
    required this.sets,
    required this.latest,
  });
  final int id;
  final String name;
  final int sessions;
  final int sets;
  final DateTime latest;
}

/// Prepared screen evidence; UI does not aggregate logs or call infrastructure.
class AnalyticsViewData {
  AnalyticsViewData({
    required this.sessions,
    required this.workingSets,
    required this.volumeKgReps,
    required this.currentWeekVolume,
    required this.previousWeekVolume,
    required this.hasAnyHistory,
    required this.records,
    required this.estimates,
    required Map<int, String> exerciseNames,
    this.weekChangePercent,
    required Iterable<AnalyticsChartPoint> weeklyVolume,
    required Iterable<AnalyticsChartPoint> strengthTrend,
    required Iterable<AnalyticsChartPoint> sessionVolume,
    required Iterable<AnalyticsExerciseSummary> exercises,
  }) : weeklyVolume = List.unmodifiable(weeklyVolume),
       strengthTrend = List.unmodifiable(strengthTrend),
       sessionVolume = List.unmodifiable(sessionVolume),
       exercises = List.unmodifiable(exercises),
       exerciseNames = Map.unmodifiable(exerciseNames),
       recentRecords = List.unmodifiable(
         records.history
             .where((record) => !record.isBaseline)
             .toList()
             .reversed,
       );
  final int sessions;
  final int workingSets;
  final double? volumeKgReps;
  final double? currentWeekVolume;
  final double? previousWeekVolume;
  final bool hasAnyHistory;
  final List<AnalyticsChartPoint> weeklyVolume;
  final List<AnalyticsChartPoint> strengthTrend;
  final List<AnalyticsChartPoint> sessionVolume;
  final List<AnalyticsExerciseSummary> exercises;
  final PersonalRecordSummary records;
  final EstimatedOneRepMaxSummary estimates;
  final Map<int, String> exerciseNames;
  final List<PersonalRecord> recentRecords;
  final double? weekChangePercent;
}
