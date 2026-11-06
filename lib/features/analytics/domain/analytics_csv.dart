import 'dart:convert';
import 'dart:typed_data';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';

/// A versioned, explicit analytics export, separate from plan-sharing formats.
abstract final class AnalyticsCsv {
  static const filename = 'aedify_analytics.csv';
  static const maxBytes = 8 * 1024 * 1024;
  static const maxRows = 50000;
  static const headers = [
    'schema_version',
    'record_type',
    'date_utc',
    'exercise',
    'weight_kg',
    'reps',
    'duration_seconds',
    'distance_meters',
    'rpe',
    'metric',
    'value',
    'unit',
    'programme',
    'due',
    'completed',
    'adherence_percent',
  ];

  static Uint8List encode(
    List<AnalyticsSetLog> logs,
    AnalyticsInsights insights,
  ) {
    final count =
        logs.length +
        insights.adherence.length +
        insights.measurements.fold<int>(0, (n, m) => n + m.values.length) +
        1;
    if (count > maxRows) throw const FormatException('analytics_export_limit');
    final rows = <List<Object?>>[headers];
    for (final log in logs) {
      rows.add([
        1,
        'working_set',
        log.performedAt.toUtc().toIso8601String(),
        log.exerciseName,
        log.actualWeightKg,
        log.actualReps,
        log.actualDurationSeconds,
        log.actualDistanceMeters,
        log.actualRpe,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      ]);
    }
    for (final measurement in insights.measurements) {
      for (final metric in BodyMetric.values) {
        final value = measurement.values[metric];
        if (value == null) continue;
        rows.add([
          1,
          'body_measurement',
          measurement.measuredAt.toUtc().toIso8601String(),
          null,
          null,
          null,
          null,
          null,
          null,
          metric.name,
          value,
          metric.canonicalUnit,
          null,
          null,
          null,
          null,
        ]);
      }
    }
    for (final programme in insights.adherence) {
      rows.add([
        1,
        'programme_adherence',
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        programme.name,
        programme.due,
        programme.completed,
        programme.percent,
      ]);
    }
    if (rows.length > maxRows) {
      throw const FormatException('analytics_export_limit');
    }
    final output = Uint8List.fromList(
      utf8.encode(
        '${rows.map((row) => row.map(_cell).join(',')).join('\r\n')}\r\n',
      ),
    );
    if (output.length > maxBytes) {
      throw const FormatException('analytics_export_limit');
    }
    return output;
  }

  static String _cell(Object? value) {
    var text = value?.toString() ?? '';
    // Protect spreadsheet users even when exercise/programme names are imported.
    final formula =
        RegExp(r'^[\s\x00-\x1f]*[=+\-@]').hasMatch(text) ||
        text.startsWith('\t') ||
        text.startsWith('\r') ||
        text.startsWith('\n');
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]'), '');
    if (formula) text = "'$text";
    return '"${text.replaceAll('"', '""')}"';
  }
}
