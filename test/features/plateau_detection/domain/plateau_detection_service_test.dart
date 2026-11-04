import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_detection_service.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const detector = PlateauDetectionService();
  final now = DateTime.utc(2026, 10, 26, 12);
  AnalyticsSetLog log(
    String id, {
    int daysAgo = 1,
    DateTime? time,
    String? sessionId,
    int exerciseId = 1,
    double weight = 100,
    int reps = 5,
    bool? deload = false,
    bool active = true,
    ExerciseModality? modality = ExerciseModality.strength,
    ExerciseLoggingType? mode = ExerciseLoggingType.repsWeight,
    int? target,
    int? minimum,
    int? maximum,
    double? targetWeight,
    double? rpe,
    int? rir,
  }) => AnalyticsSetLog(
    id: id,
    sessionId: sessionId ?? id,
    sessionExerciseId: 'member-$id',
    exerciseId: exerciseId,
    source: SessionSource.standalone,
    performedAt: time ?? now.subtract(Duration(days: daysAgo)),
    completedAt: now,
    setIndex: 0,
    updatedAt: now,
    modality: modality,
    loggingType: mode,
    actualReps: reps,
    actualWeightKg: weight,
    actualRpe: rpe,
    actualRir: rir,
    prescribedRepsExact: target,
    prescribedRepsMin: minimum,
    prescribedRepsMax: maximum,
    prescribedWeightKg: targetWeight,
    isDeload: deload,
    isPlateauEligible: active,
  );
  List<AnalyticsSetLog> history({
    List<double> weights = const [100, 100, 100, 100],
  }) => [
    for (var i = 0; i < weights.length; i++)
      log('$i', daysAgo: weights.length - i, weight: weights[i]),
  ];
  PlateauEvaluation evaluate(
    List<AnalyticsSetLog> logs, {
    Map<int, DateTime> dismissedAt = const {},
  }) => detector.evaluate(logs, now: now, dismissedAt: dismissedAt).single;

  test('invalid actuals are not presented as missed-target evidence', () {
    final result = evaluate([
      ...history(),
      log('invalid', sessionId: '3', reps: -1, target: 6),
    ]);
    expect(result.outcome, PlateauOutcome.plateau);
    expect(result.reasons, [PlateauReason.nonIncreasingE1rm]);
  });

  test('empty history returns an immutable empty result', () {
    final result = detector.evaluate([], now: now);
    expect(result, isEmpty);
    expect(() => result.clear(), throwsUnsupportedError);
  });
  test(
    'four flat sessions produce a local plateau without requiring misses',
    () {
      final result = evaluate(history());
      expect(result.outcome, PlateauOutcome.plateau);
      expect(result.qualifyingSessions, 4);
      expect(result.recentSessions, hasLength(3));
      expect(result.slopeKgPerSession, 0);
      expect(result.reasons, [PlateauReason.nonIncreasingE1rm]);
    },
  );
  test('declining latest-three-session e1RM produces a negative slope', () {
    final result = evaluate(history(weights: [120, 110, 100, 90]));
    expect(result.outcome, PlateauOutcome.plateau);
    expect(result.slopeKgPerSession, closeTo(-11.66666666666667, 1e-10));
  });
  test('increasing strength is progressing even below an older peak', () {
    final result = evaluate(history(weights: [200, 100, 105, 110]));
    expect(result.outcome, PlateauOutcome.progressing);
    expect(result.slopeKgPerSession!, greaterThan(0));
    expect(result.reasons, isEmpty);
  });
  test('trend uses latest three exposures rather than a lifetime trend', () {
    expect(
      evaluate(history(weights: [80, 100, 100, 100])).outcome,
      PlateauOutcome.plateau,
    );
  });
  test('fewer than four distinct qualifying sessions is insufficient', () {
    expect(
      evaluate(history(weights: [100, 100, 100])).outcome,
      PlateauOutcome.insufficientHistory,
    );
    final result = evaluate([
      for (var i = 0; i < 8; i++) log('$i', sessionId: 'one'),
    ]);
    expect(result.qualifyingSessions, 1);
    expect(result.outcome, PlateauOutcome.insufficientHistory);
  });
  test(
    'session evidence uses the highest reliable estimate across members/sets',
    () {
      final logs = history();
      logs.add(log('additional', sessionId: '3', weight: 120));
      final result = evaluate(logs);
      expect(result.outcome, PlateauOutcome.progressing);
      expect(result.recentSessions.last.workingSets, 2);
      expect(result.recentSessions.last.topEstimatedKg, closeTo(140, 1e-10));
    },
  );
  test(
    '28-day window includes both endpoints and excludes future evidence',
    () {
      final logs = [
        log('a', daysAgo: 28),
        log('b', daysAgo: 20),
        log('c', daysAgo: 7),
        log('d', daysAgo: 0),
      ];
      expect(evaluate(logs).qualifyingSessions, 4);
      expect(evaluate(logs).outcome, PlateauOutcome.plateau);
      logs[0] = log(
        'a',
        time: now.subtract(const Duration(days: 28, seconds: 1)),
      );
      logs.add(log('future', time: now.add(const Duration(seconds: 1))));
      expect(evaluate(logs).qualifyingSessions, 3);
      expect(evaluate(logs).outcome, PlateauOutcome.insufficientHistory);
    },
  );
  test('high-rep evidence cannot supply the four reliable sessions', () {
    expect(
      evaluate([
        for (var i = 0; i < 4; i++) log('$i', daysAgo: i + 1, reps: 11),
      ]).outcome,
      PlateauOutcome.insufficientHistory,
    );
  });
  test(
    'a latest high-rep-only exposure is not skipped to fabricate a stall',
    () {
      final result = evaluate([
        ...history(),
        log('latest', daysAgo: 0, reps: 11),
      ]);
      expect(result.qualifyingSessions, 4);
      expect(result.outcome, PlateauOutcome.insufficientHistory);
    },
  );
  test(
    'deload suppresses latest-three exposure detection including high reps',
    () {
      expect(
        evaluate([...history().take(3), log('deload', deload: true)]).outcome,
        PlateauOutcome.deload,
      );
      expect(
        evaluate([
          ...history(),
          log('deload', daysAgo: 0, reps: 11, deload: true),
        ]).outcome,
        PlateauOutcome.deload,
      );
    },
  );
  test(
    'an older deload outside the rolling three exposures does not suppress',
    () {
      expect(
        evaluate([log('old', daysAgo: 5, deload: true), ...history()]).outcome,
        PlateauOutcome.plateau,
      );
    },
  );
  test('missing programme week context fails closed', () {
    expect(
      evaluate([...history().take(3), log('unknown', deload: null)]).outcome,
      PlateauOutcome.unknownContext,
    );
  });
  test('archived/substituted exercises cannot create alerts', () {
    expect(
      evaluate([...history().take(3), log('inactive', active: false)]).outcome,
      PlateauOutcome.inactive,
    );
  });
  test('unsupported or unknown modality/logging mode fails closed', () {
    for (final mode in [
      null,
      ExerciseLoggingType.duration,
      ExerciseLoggingType.repsOnly,
    ]) {
      expect(
        evaluate([
          ...history().take(3),
          log('unsupported', mode: mode),
        ]).outcome,
        PlateauOutcome.unsupported,
      );
    }
    for (final modality in [
      null,
      ExerciseModality.cardio,
      ExerciseModality.recovery,
    ]) {
      expect(
        evaluate([
          ...history().take(3),
          log('unsupported', modality: modality),
        ]).outcome,
        PlateauOutcome.unsupported,
      );
    }
  });
  test(
    'reason codes summarize target misses and high effort without advice',
    () {
      final result = evaluate([
        ...history().take(3),
        log('latest', target: 6, targetWeight: 105, rpe: 9),
      ]);
      expect(result.reasons, [
        PlateauReason.nonIncreasingE1rm,
        PlateauReason.missedTargets,
        PlateauReason.highEffort,
      ]);
      expect(result.recentSessions.last.missedTargets, 1);
      expect(result.recentSessions.last.highEffortSets, 1);
    },
  );
  test('minimum target and RIR-only effort can supply evidence', () {
    final result = evaluate([
      ...history().take(3),
      log('latest', minimum: 6, maximum: 8, rir: 1),
    ]);
    expect(
      result.reasons,
      containsAll([PlateauReason.missedTargets, PlateauReason.highEffort]),
    );
  });
  test('a maximum-only target is not treated as a required minimum', () {
    final result = evaluate([
      ...history().take(3),
      log('latest', maximum: 8, rpe: 8),
    ]);
    expect(result.reasons, [PlateauReason.nonIncreasingE1rm]);
  });
  test(
    'dismissal suppresses for 14 days and permits exact-boundary reopening',
    () {
      final dismissed = now.subtract(const Duration(days: 14));
      expect(
        evaluate(
          history(),
          dismissedAt: {1: dismissed.add(const Duration(seconds: 1))},
        ).outcome,
        PlateauOutcome.dismissed,
      );
      expect(
        evaluate(history(), dismissedAt: {1: dismissed}).outcome,
        PlateauOutcome.plateau,
      );
    },
  );
  test('progress resolves evidence even during dismissal cooldown', () {
    expect(
      evaluate(
        history(weights: [100, 105, 110, 115]),
        dismissedAt: {1: now},
      ).outcome,
      PlateauOutcome.progressing,
    );
  });
  test(
    'custom/canonical identities and dismissal state remain independent',
    () {
      final result = detector.evaluate(
        [
          ...history(),
          for (var i = 0; i < 4; i++)
            log('custom-$i', daysAgo: i + 1, exerciseId: -1),
        ],
        now: now,
        dismissedAt: {1: now},
      );
      expect(result.map((item) => item.exerciseId), [-1, 1]);
      expect(result.first.outcome, PlateauOutcome.plateau);
      expect(result.last.outcome, PlateauOutcome.dismissed);
    },
  );
  test(
    'equal timestamps/input order give deterministic immutable summaries',
    () {
      final logs = [for (var i = 0; i < 4; i++) log('$i')];
      final before = List<AnalyticsSetLog>.of(logs);
      final first = evaluate(logs);
      final second = evaluate(logs.reversed.toList());
      expect(first.outcome, second.outcome);
      expect(first.slopeKgPerSession, second.slopeKgPerSession);
      expect(logs, before);
      expect(() => first.reasons.clear(), throwsUnsupportedError);
      expect(() => first.recentSessions.clear(), throwsUnsupportedError);
    },
  );
}
