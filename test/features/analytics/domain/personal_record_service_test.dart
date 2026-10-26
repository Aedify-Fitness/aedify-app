import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/domain/personal_record_service.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = PersonalRecordService();
  final start = DateTime.utc(2026, 10, 20);

  AnalyticsSetLog log(
    String id, {
    int exerciseId = 1,
    int day = 0,
    String? sessionId,
    String? memberId,
    int setIndex = 0,
    double? weight = 100,
    int? reps = 5,
    ExerciseLoggingType? type = ExerciseLoggingType.repsWeight,
    ExerciseModality? modality = ExerciseModality.strength,
    SessionSource source = SessionSource.standalone,
    int? duration,
    double? distance,
  }) => AnalyticsSetLog(
    id: id,
    sessionId: sessionId ?? 'session-$id',
    sessionExerciseId: memberId ?? 'member-$id',
    exerciseId: exerciseId,
    source: source,
    performedAt: start.add(Duration(days: day)),
    completedAt: start.add(Duration(days: day, hours: 1)),
    updatedAt: start.add(Duration(days: day)),
    setIndex: setIndex,
    modality: modality,
    loggingType: type,
    actualWeightKg: weight,
    actualReps: reps,
    actualDurationSeconds: duration,
    actualDistanceMeters: distance,
    prescribedRepsExact: 10,
    prescribedWeightKg: 200,
  );

  PersonalRecord current(
    PersonalRecordSummary summary,
    PersonalRecordType type, {
    double? atWeight,
  }) => summary.current.singleWhere(
    (record) => record.type == type && record.comparisonWeightKg == atWeight,
  );

  test('reliable e1RM increases can set records even at a lighter load', () {
    final summary = service.detect([
      log('old'),
      log('new', day: 1, weight: 95, reps: 8),
    ]);
    final record = current(summary, PersonalRecordType.estimatedOneRepMax);
    expect(record.setLogId, 'new');
    expect(record.value, closeTo(120.33333333333333, 1e-10));
    expect(record.previousValue, closeTo(116.66666666666667, 1e-10));
    expect(current(summary, PersonalRecordType.maxWeight).setLogId, 'old');
  });
  test('low-confidence high-rep estimates cannot establish e1RM records', () {
    final summary = service.detect([
      log('reliable'),
      log('high-reps', day: 1, reps: 30),
    ]);
    expect(
      current(summary, PersonalRecordType.estimatedOneRepMax).setLogId,
      'reliable',
    );
    expect(
      service
          .detect([log('high-only', reps: 11)])
          .current
          .any(
            (record) => record.type == PersonalRecordType.estimatedOneRepMax,
          ),
      isFalse,
    );
  });
  test(
    'e1RM ties and corrections rebuild the same deterministic record timeline',
    () {
      final tied = service.detect([log('a'), log('b', day: 1)]);
      expect(
        tied.history.where(
          (record) => record.type == PersonalRecordType.estimatedOneRepMax,
        ),
        hasLength(1),
      );
      final initial = service.detect([log('a'), log('b', day: 1, weight: 110)]);
      expect(
        current(initial, PersonalRecordType.estimatedOneRepMax).setLogId,
        'b',
      );
      final corrected = service.detect([
        log('a', weight: 120),
        log('b', day: 1, weight: 110),
      ]);
      expect(
        current(corrected, PersonalRecordType.estimatedOneRepMax).setLogId,
        'a',
      );
      final deleted = service.detect([log('b', day: 1, weight: 110)]);
      expect(
        current(deleted, PersonalRecordType.estimatedOneRepMax).isBaseline,
        isTrue,
      );
    },
  );
  test('empty evidence gives immutable empty current and history lists', () {
    final summary = service.detect([]);
    expect(summary.current, isEmpty);
    expect(summary.history, isEmpty);
    expect(() => summary.current.clear(), throwsUnsupportedError);
    expect(() => summary.history.clear(), throwsUnsupportedError);
  });

  test('first weighted performance establishes baselines from actuals', () {
    final summary = service.detect([log('first')]);
    expect(summary.current, hasLength(4));
    expect(summary.history.every((record) => record.isBaseline), isTrue);
    expect(current(summary, PersonalRecordType.maxWeight).value, 100);
    expect(
      current(summary, PersonalRecordType.maxRepsAtWeight, atWeight: 100).value,
      5,
    );
    expect(current(summary, PersonalRecordType.volume).value, 500);
    for (final record in summary.current) {
      expect(record.setLogId, 'first');
      expect(record.sessionId, 'session-first');
      expect(record.exerciseId, 1);
      expect(record.achievedAt, start);
      expect(record.previousValue, isNull);
    }
  });

  test(
    'heavier load produces a weight improvement with the previous record',
    () {
      final summary = service.detect([
        log('old'),
        log('new', day: 1, weight: 105),
      ]);
      final record = current(summary, PersonalRecordType.maxWeight);
      expect(record.value, 105);
      expect(record.previousValue, 100);
      expect(record.isBaseline, isFalse);
      expect(record.setLogId, 'new');
    },
  );

  test(
    'more reps at the same load improves rep and per-set volume records',
    () {
      final summary = service.detect([log('old'), log('new', day: 1, reps: 6)]);
      expect(current(summary, PersonalRecordType.maxWeight).setLogId, 'old');
      final rep = current(
        summary,
        PersonalRecordType.maxRepsAtWeight,
        atWeight: 100,
      );
      expect(rep.value, 6);
      expect(rep.previousValue, 5);
      expect(current(summary, PersonalRecordType.volume).value, 600);
      expect(current(summary, PersonalRecordType.volume).previousValue, 500);
    },
  );

  test(
    'lighter load with more reps can improve volume without a weight PR',
    () {
      final summary = service.detect([
        log('old'),
        log('new', day: 1, weight: 90, reps: 8),
      ]);
      expect(current(summary, PersonalRecordType.maxWeight).value, 100);
      expect(current(summary, PersonalRecordType.volume).value, 720);
      expect(
        current(
          summary,
          PersonalRecordType.maxRepsAtWeight,
          atWeight: 90,
        ).isBaseline,
        isTrue,
      );
    },
  );

  test('rep comparisons are isolated by exact canonical load', () {
    final summary = service.detect([
      log('low', weight: 90, reps: 12),
      log('high', day: 1, weight: 100, reps: 6),
      log('low-next', day: 2, weight: 90, reps: 13),
    ]);
    expect(
      current(summary, PersonalRecordType.maxRepsAtWeight, atWeight: 90).value,
      13,
    );
    expect(
      current(summary, PersonalRecordType.maxRepsAtWeight, atWeight: 100).value,
      6,
    );
    expect(
      current(
        summary,
        PersonalRecordType.maxRepsAtWeight,
        atWeight: 90,
      ).previousValue,
      12,
    );
  });

  test(
    'ties retain the first achievement without duplicate history events',
    () {
      final summary = service.detect([log('a'), log('b', day: 1)]);
      expect(summary.history, hasLength(4));
      expect(summary.current.every((record) => record.setLogId == 'a'), isTrue);
    },
  );

  test('volume is per set rather than a sum across a session', () {
    final summary = service.detect([
      log('old', reps: 10),
      log('one', day: 1, sessionId: 'same', reps: 6),
      log('two', day: 1, sessionId: 'same', reps: 6, setIndex: 1),
    ]);
    expect(current(summary, PersonalRecordType.volume).value, 1000);
    expect(current(summary, PersonalRecordType.volume).setLogId, 'old');
  });

  test('custom and canonical exercises never share record comparisons', () {
    final summary = service.detect([
      log('canonical'),
      log('custom', exerciseId: -1, weight: 50),
    ]);
    expect(summary.current, hasLength(8));
    expect(
      summary.current
          .where((record) => record.exerciseId == -1)
          .every((record) => record.isBaseline),
      isTrue,
    );
  });

  test('programme, saved workout and standalone evidence compete together', () {
    final summary = service.detect([
      log('programme', source: SessionSource.program),
      log('saved', day: 1, source: SessionSource.savedWorkout, weight: 110),
      log('standalone', day: 2, weight: 120),
    ]);
    expect(current(summary, PersonalRecordType.maxWeight).value, 120);
    expect(current(summary, PersonalRecordType.maxWeight).previousValue, 110);
  });

  test(
    'reps-only strength uses a separate rep record without inferred load',
    () {
      final summary = service.detect([
        log('a', type: ExerciseLoggingType.repsOnly, weight: null, reps: 10),
        log(
          'b',
          day: 1,
          type: ExerciseLoggingType.repsOnly,
          weight: 900,
          reps: 12,
        ),
      ]);
      expect(summary.current, hasLength(1));
      final record = current(summary, PersonalRecordType.maxReps);
      expect(record.value, 12);
      expect(record.previousValue, 10);
      expect(record.comparisonWeightKg, isNull);
    },
  );

  test(
    'zero external load produces reps-at-zero records without weight/volume',
    () {
      final summary = service.detect([
        log('zero', weight: 0),
        log('negative-zero', day: 1, weight: -0.0, reps: 6),
      ]);
      expect(summary.current, hasLength(1));
      expect(
        current(summary, PersonalRecordType.maxRepsAtWeight, atWeight: 0).value,
        6,
      );
      expect(
        current(
          summary,
          PersonalRecordType.maxRepsAtWeight,
          atWeight: 0,
        ).previousValue,
        5,
      );
    },
  );

  for (final weight in <double?>[
    null,
    -1,
    double.nan,
    double.infinity,
    double.negativeInfinity,
  ]) {
    test('invalid weighted load $weight cannot create records', () {
      expect(service.detect([log('invalid', weight: weight)]).history, isEmpty);
    });
  }

  for (final reps in <int?>[null, 0, -1]) {
    test('invalid reps $reps cannot create weighted or reps-only records', () {
      expect(
        service.detect([
          log('weighted', reps: reps),
          log('reps', reps: reps, type: ExerciseLoggingType.repsOnly),
        ]).history,
        isEmpty,
      );
    });
  }

  test(
    'overflowing volume is omitted without poisoning finite weight/rep metrics',
    () {
      final summary = service.detect([
        log('large', weight: double.maxFinite, reps: 2),
      ]);
      expect(summary.current, hasLength(2));
      expect(
        summary.current.any(
          (record) => record.type == PersonalRecordType.volume,
        ),
        isFalse,
      );
      expect(
        current(summary, PersonalRecordType.maxWeight).value.isFinite,
        isTrue,
      );
    },
  );

  test(
    'duration, cardio, missing and unknown metadata do not imply strength PRs',
    () {
      for (final modality in [
        null,
        ExerciseModality.cardio,
        ExerciseModality.flexibility,
        ExerciseModality.recovery,
      ]) {
        expect(
          service.detect([log('unsupported', modality: modality)]).history,
          isEmpty,
        );
      }
      for (final type in [null, ExerciseLoggingType.duration]) {
        expect(
          service.detect([
            log('unsupported', type: type, duration: 120, distance: 400),
          ]).history,
          isEmpty,
        );
      }
    },
  );

  test(
    'rebuilding after an old correction removes later false achievements',
    () {
      final initial = service.detect([
        log('old'),
        log('new', day: 1, weight: 110),
      ]);
      expect(current(initial, PersonalRecordType.maxWeight).setLogId, 'new');
      final corrected = service.detect([
        log('old', weight: 120),
        log('new', day: 1, weight: 110),
      ]);
      expect(current(corrected, PersonalRecordType.maxWeight).setLogId, 'old');
      expect(
        corrected.history.where(
          (record) => record.type == PersonalRecordType.maxWeight,
        ),
        hasLength(1),
      );
      expect(current(initial, PersonalRecordType.maxWeight).value, 110);
    },
  );

  test('deleting the best source restores the prior record', () {
    final old = log('old');
    final best = log('best', day: 1, weight: 120);
    expect(
      current(service.detect([old, best]), PersonalRecordType.maxWeight).value,
      120,
    );
    final deleted = service.detect([old]);
    expect(current(deleted, PersonalRecordType.maxWeight).value, 100);
    expect(current(deleted, PersonalRecordType.maxWeight).isBaseline, isTrue);
  });

  test(
    'canonical fractional kg values are compared without display rounding',
    () {
      final summary = service.detect([
        log('a', weight: 45.359237),
        log('b', day: 1, weight: 45.359238),
      ]);
      expect(current(summary, PersonalRecordType.maxWeight).value, 45.359238);
      expect(
        current(summary, PersonalRecordType.maxWeight).previousValue,
        45.359237,
      );
      expect(
        summary.current.where(
          (record) => record.type == PersonalRecordType.maxRepsAtWeight,
        ),
        hasLength(2),
      );
    },
  );

  test('unsorted equal-time input is deterministic and remains unmodified', () {
    final a = log('a');
    final b = log('b');
    final input = [b, a];
    final reversed = service.detect(input);
    final ordered = service.detect([a, b]);
    expect(
      reversed.history.map((record) => record.setLogId),
      ordered.history.map((record) => record.setLogId),
    );
    expect(reversed.history.every((record) => record.setLogId == 'a'), isTrue);
    expect(input, [b, a]);
    expect(() => reversed.current.clear(), throwsUnsupportedError);
  });

  test(
    'chronology wins over insertion, session IDs and correction timestamps',
    () {
      final summary = service.detect([
        log('a-later', day: 1, weight: 110),
        log('z-earlier'),
      ]);
      final history = summary.history
          .where((record) => record.type == PersonalRecordType.maxWeight)
          .toList();
      expect(history.map((record) => record.setLogId), [
        'z-earlier',
        'a-later',
      ]);
      expect(history.last.previousValue, 100);
    },
  );
}
