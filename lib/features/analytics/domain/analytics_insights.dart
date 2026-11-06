import 'package:aedify/features/analytics/domain/analytics_view_data.dart';

enum BodyMetric {
  bodyweightKg,
  bodyFatPercent,
  neckCm,
  waistCm,
  chestCm,
  hipsCm,
  leftArmCm,
  rightArmCm,
  leftThighCm,
  rightThighCm;

  bool get isWeight => this == bodyweightKg;
  bool get isPercent => this == bodyFatPercent;
  String get canonicalUnit => isWeight
      ? 'kg'
      : isPercent
      ? '%'
      : 'cm';
}

/// Numeric local history; notes, media and profile identifiers are excluded.
class BodyMeasurementEntry {
  BodyMeasurementEntry({
    required this.id,
    required this.measuredAt,
    required Map<BodyMetric, double> values,
  }) : values = Map.unmodifiable(values);
  final String id;
  final DateTime measuredAt;
  final Map<BodyMetric, double> values;
}

class ProgrammeAdherence {
  const ProgrammeAdherence({
    required this.name,
    required this.due,
    required this.completed,
    required this.unscheduled,
  });
  final String name;
  final int due;
  final int completed;
  final int unscheduled;
  double? get percent => due == 0 ? null : completed * 100 / due;
}

class AnalyticsInsights {
  AnalyticsInsights({
    required Iterable<BodyMeasurementEntry> measurements,
    required Iterable<ProgrammeAdherence> adherence,
  }) : measurements = List.unmodifiable(measurements),
       adherence = List.unmodifiable(adherence);
  final List<BodyMeasurementEntry> measurements;
  final List<ProgrammeAdherence> adherence;
  List<AnalyticsChartPoint> series(BodyMetric metric) => [
    for (final entry in measurements)
      if (entry.values[metric] case final double value)
        AnalyticsChartPoint(entry.measuredAt, value),
  ];
}
