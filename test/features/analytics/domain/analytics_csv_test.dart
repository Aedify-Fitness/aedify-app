import 'dart:convert';
import 'package:aedify/features/analytics/domain/analytics_csv.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 6);
  AnalyticsSetLog log(String name) => AnalyticsSetLog(
    id: 'PRIVATE_ID',
    sessionId: 'PRIVATE_SESSION',
    sessionExerciseId: 'PRIVATE_MEMBER',
    exerciseId: 1,
    source: SessionSource.standalone,
    performedAt: now,
    completedAt: now,
    updatedAt: now,
    setIndex: 0,
    exerciseName: name,
    sessionName: 'PRIVATE_SESSION_NAME',
    actualWeightKg: 100,
    actualReps: 5,
    actualRpe: 8,
  );
  final empty = AnalyticsInsights(measurements: [], adherence: []);
  test(
    'quoted CSV escapes commas/quotes/newlines and blocks spreadsheet formulas',
    () {
      for (final name in [
        '=HYPERLINK("x")',
        '+formula',
        '-formula',
        '@SUM(1)',
        '  =formula',
        '\tformula',
      ]) {
        final csv = utf8.decode(AnalyticsCsv.encode([log(name)], empty));
        final escaped = "'$name".replaceAll('"', '""');
        expect(csv, contains('"$escaped"'));
      }
      final csv = utf8.decode(
        AnalyticsCsv.encode([log('Press, "strict"\nseated')], empty),
      );
      expect(csv, contains('"Press, ""strict""\nseated"'));
      for (final marker in [
        'PRIVATE_ID',
        'PRIVATE_SESSION',
        'PRIVATE_MEMBER',
        'PRIVATE_SESSION_NAME',
      ]) {
        expect(csv, isNot(contains(marker)));
      }
      expect(csv, contains('"100.0","5"'));
      expect(csv, endsWith('\r\n'));
    },
  );
  test(
    'measurement and adherence rows use versioned canonical columns without IDs',
    () {
      final insights = AnalyticsInsights(
        measurements: [
          BodyMeasurementEntry(
            id: 'PRIVATE_MEASUREMENT',
            measuredAt: now,
            values: {BodyMetric.waistCm: 81},
          ),
        ],
        adherence: [
          const ProgrammeAdherence(
            name: 'Plan',
            due: 4,
            completed: 3,
            unscheduled: 1,
          ),
        ],
      );
      final csv = utf8.decode(AnalyticsCsv.encode([], insights));
      expect(csv, startsWith('"schema_version","record_type"'));
      expect(csv, contains('"waistCm","81.0","cm"'));
      expect(csv, contains('"Plan","4","3","75.0"'));
      expect(csv, isNot(contains('PRIVATE_MEASUREMENT')));
    },
  );
  test('oversized exports are rejected rather than silently truncated', () {
    expect(
      () => AnalyticsCsv.encode(
        List.filled(AnalyticsCsv.maxRows, log('Press')),
        empty,
      ),
      throwsFormatException,
    );
    expect(
      () => AnalyticsCsv.encode([log('a' * AnalyticsCsv.maxBytes)], empty),
      throwsFormatException,
    );
  });
}
