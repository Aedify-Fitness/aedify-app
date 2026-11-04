import 'package:aedify/features/analytics/application/analytics_view_mapper.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = AnalyticsViewMapper();
  final now = DateTime(2026, 10, 26, 12);
  AnalyticsSetLog log(
    String id, {
    DateTime? time,
    int exerciseId = 1,
    String? session,
    double? weight = 100,
    int? reps = 5,
    ExerciseLoggingType mode = ExerciseLoggingType.repsWeight,
    int? duration,
  }) => AnalyticsSetLog(
    id: id,
    sessionId: session ?? id,
    sessionExerciseId: 'member-$id',
    exerciseId: exerciseId,
    exerciseName: 'Fixture press',
    sessionName: 'Fixture workout',
    source: SessionSource.standalone,
    performedAt: time ?? now,
    completedAt: now,
    updatedAt: now,
    setIndex: 0,
    modality: mode == ExerciseLoggingType.duration
        ? ExerciseModality.cardio
        : ExerciseModality.strength,
    loggingType: mode,
    actualWeightKg: weight,
    actualReps: reps,
    actualDurationSeconds: duration,
  );
  AnalyticsViewData map(
    List<AnalyticsSetLog> logs, {
    AnalyticsRange range = AnalyticsRange.fourWeeks,
    int? id,
  }) => mapper.map(logs, range: range, now: now, exerciseId: id);

  test('empty data has no fabricated volume or trend', () {
    final data = map([]);
    expect(data.sessions, 0);
    expect(data.volumeKgReps, isNull);
    expect(data.weeklyVolume, isEmpty);
    expect(data.hasAnyHistory, isFalse);
  });
  test(
    'counts sessions separately from sets and preserves canonical volume',
    () {
      final data = map([
        log('a', session: 'same'),
        log('b', session: 'same', weight: 50, reps: 10),
      ]);
      expect(data.sessions, 1);
      expect(data.workingSets, 2);
      expect(data.volumeKgReps, 1000);
      expect(data.sessionVolume.single.value, 1000);
      expect(data.exercises.single.name, 'Fixture press');
    },
  );
  test(
    'calendar weeks include quiet weeks without inventing weighted data',
    () {
      final data = map([log('old', time: DateTime(2026, 10, 19)), log('new')]);
      expect(data.weeklyVolume.map((point) => point.value), [0, 0, 500, 500]);
      expect(data.currentWeekVolume, 500);
      expect(data.previousWeekVolume, 500);
      expect(data.weekChangePercent, 0);
    },
  );
  test(
    'reps-only and timed sets count without becoming external volume/e1RM',
    () {
      final data = map([
        log('reps', mode: ExerciseLoggingType.repsOnly, weight: null),
        log(
          'time',
          mode: ExerciseLoggingType.duration,
          weight: null,
          reps: null,
          duration: 60,
        ),
      ]);
      expect(data.sessions, 2);
      expect(data.workingSets, 2);
      expect(data.volumeKgReps, isNull);
      expect(data.strengthTrend, isEmpty);
      expect(data.weeklyVolume, isEmpty);
    },
  );
  test('display range does not reset personal records', () {
    final data = map([
      log('old', time: now.subtract(const Duration(days: 60)), weight: 120),
      log('new', weight: 100),
    ]);
    expect(data.sessions, 1);
    expect(
      data.records.current
          .singleWhere((record) => record.type == PersonalRecordType.maxWeight)
          .setLogId,
      'old',
    );
    expect(
      data.recentRecords.any(
        (record) => record.type == PersonalRecordType.maxWeight,
      ),
      isFalse,
    );
  });
  test('exercise identity and future-date filtering are retained', () {
    final data = map([
      log('a'),
      log('b', exerciseId: -1),
      log('future', time: now.add(const Duration(days: 1))),
    ], id: -1);
    expect(data.sessions, 1);
    expect(data.exercises.single.id, -1);
  });
  test(
    'strength series chooses session top estimates and excludes high reps',
    () {
      final data = map([
        log('a', session: 'same'),
        log('b', session: 'same', weight: 120),
        log('high', reps: 20),
      ]);
      expect(data.strengthTrend, hasLength(1));
      expect(data.strengthTrend.single.value, closeTo(140, 1e-8));
      expect(data.estimates.estimates, hasLength(3));
    },
  );
  test('invalid actuals and aggregate overflow never enter chart points', () {
    final data = map([
      log('invalid', reps: -1),
      log('a', weight: double.maxFinite, reps: 1),
      log('b', weight: double.maxFinite, reps: 1),
    ]);
    expect(data.workingSets, 2);
    expect(data.volumeKgReps, isNull);
    expect(data.weeklyVolume.every((point) => point.value.isFinite), isTrue);
  });
  test(
    'imperial display converts values without changing stored comparisons',
    () {
      final data = map([log('a', weight: 45.359237)]);
      expect(data.volumeKgReps, closeTo(226.796185, 1e-8));
      expect(
        AnalyticsFormat.weight(45.359237, PreferredUnit.imperial),
        '100.0 lbs',
      );
      expect(
        AnalyticsFormat.weight(
          226.796185,
          PreferredUnit.imperial,
          volume: true,
        ),
        '500 lbs × reps',
      );
      expect(data.records.current.first.value, 45.359237);
    },
  );
}
