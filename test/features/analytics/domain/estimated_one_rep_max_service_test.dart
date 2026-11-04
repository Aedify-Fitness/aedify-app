import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max_service.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = EstimatedOneRepMaxService();
  final at = DateTime.utc(2026, 10, 20);

  AnalyticsSetLog log({
    String id = 'set',
    int exerciseId = 1,
    DateTime? time,
    double? weight = 100,
    int? reps = 5,
    double? rpe,
    int? rir,
    String? equipment,
    ExerciseLoggingType? mode = ExerciseLoggingType.repsWeight,
    ExerciseModality? modality = ExerciseModality.strength,
  }) => AnalyticsSetLog(
    id: id,
    sessionId: 'session',
    sessionExerciseId: 'member',
    exerciseId: exerciseId,
    source: SessionSource.standalone,
    performedAt: time ?? at,
    completedAt: at.add(const Duration(hours: 1)),
    updatedAt: at,
    setIndex: 0,
    modality: modality,
    loggingType: mode,
    equipment: equipment,
    actualWeightKg: weight,
    actualReps: reps,
    actualRpe: rpe,
    actualRir: rir,
    prescribedWeightKg: 200,
    prescribedRepsExact: 10,
  );

  for (final fixture in [
    (reps: 1, expected: 103.33333333333334),
    (reps: 5, expected: 116.66666666666667),
    (reps: 10, expected: 133.33333333333331),
    (reps: 11, expected: 136.66666666666666),
    (reps: 20, expected: 166.66666666666666),
  ]) {
    test('Epley formula for 100 kg and ${fixture.reps} reps', () {
      final estimate = service.estimate(log(reps: fixture.reps))!;
      expect(estimate.estimatedWeightKg, closeTo(fixture.expected, 1e-10));
      expect(
        estimate.confidence,
        fixture.reps <= 10
            ? EstimatedOneRepMaxConfidence.standard
            : EstimatedOneRepMaxConfidence.low,
      );
    });
  }
  test(
    'all positive rep counts through 10 are standard-confidence candidates',
    () {
      for (var reps = 1; reps <= 10; reps++) {
        final estimate = service.estimate(log(reps: reps))!;
        expect(estimate.isAnchorCandidate, isTrue);
        expect(estimate.confidence, EstimatedOneRepMaxConfidence.standard);
      }
    },
  );
  test(
    'high-rep estimates remain available but cannot become strength anchors',
    () {
      final summary = service.summarize([log(reps: 11)]);
      expect(summary.hasInsufficientData, isFalse);
      expect(
        summary.estimates.single.confidence,
        EstimatedOneRepMaxConfidence.low,
      );
      expect(summary.anchorCandidates, isEmpty);
    },
  );
  test('no eligible evidence gives an explicit insufficient-data result', () {
    for (final logs in <List<AnalyticsSetLog>>[
      [],
      [log(weight: null)],
      [log(mode: ExerciseLoggingType.duration)],
    ]) {
      final summary = service.summarize(logs);
      expect(summary.hasInsufficientData, isTrue);
      expect(summary.estimates, isEmpty);
      expect(summary.anchorCandidates, isEmpty);
    }
  });
  for (final weight in <double?>[
    null,
    0,
    -1,
    double.nan,
    double.infinity,
    double.negativeInfinity,
  ]) {
    test('invalid external load $weight has no estimate', () {
      expect(service.estimate(log(weight: weight)), isNull);
    });
  }
  for (final reps in <int?>[null, 0, -1]) {
    test('invalid reps $reps have no estimate', () {
      expect(service.estimate(log(reps: reps)), isNull);
    });
  }
  test('overflowing estimates are rejected', () {
    expect(service.estimate(log(weight: double.maxFinite, reps: 10)), isNull);
  });
  test('cardio, timed, reps-only and unknown metadata are unsupported', () {
    for (final modality in [
      null,
      ExerciseModality.cardio,
      ExerciseModality.flexibility,
      ExerciseModality.recovery,
    ]) {
      expect(service.estimate(log(modality: modality)), isNull);
    }
    for (final mode in [
      null,
      ExerciseLoggingType.repsOnly,
      ExerciseLoggingType.duration,
    ]) {
      expect(service.estimate(log(mode: mode)), isNull);
    }
  });
  test(
    'bodyweight-only equipment is excluded even with residual weighted actuals',
    () {
      for (final equipment in ['bodyweight', ' BODYWEIGHT ']) {
        expect(service.estimate(log(equipment: equipment)), isNull);
      }
      expect(service.estimate(log(equipment: 'barbell')), isNotNull);
    },
  );
  test('RPE/RIR do not adjust analytics Epley or special-case one rep', () {
    final estimates = [
      service.estimate(log(reps: 1, rpe: 10, rir: 0))!,
      service.estimate(log(reps: 1, rpe: 6, rir: 4))!,
      service.estimate(log(reps: 1))!,
    ];
    for (final estimate in estimates) {
      expect(estimate.estimatedWeightKg, closeTo(103.33333333333334, 1e-10));
    }
  });
  test('prescriptions never fill missing actual load or reps', () {
    expect(service.estimate(log(weight: null)), isNull);
    expect(service.estimate(log(reps: null)), isNull);
    final estimate = service.estimate(log())!;
    expect(estimate.weightKg, 100);
    expect(estimate.reps, 5);
  });
  test('canonical fractional kg and source identity remain unrounded', () {
    final estimate = service.estimate(log(exerciseId: -1, weight: 45.359237))!;
    expect(estimate.estimatedWeightKg, closeTo(52.91910983333334, 1e-10));
    expect(estimate.weightKg, 45.359237);
    expect(estimate.exerciseId, -1);
    expect(estimate.setLogId, 'set');
    expect(estimate.sessionId, 'session');
    expect(estimate.performedAt, at);
  });
  test(
    'summary orders a copy and keeps estimates/anchor candidates immutable',
    () {
      final a = log(id: 'a');
      final b = log(id: 'b', reps: 11);
      final older = log(id: 'z', time: at.subtract(const Duration(days: 1)));
      final input = [b, a, older];
      final summary = service.summarize(input);
      expect(summary.estimates.map((estimate) => estimate.setLogId), [
        'z',
        'a',
        'b',
      ]);
      expect(summary.anchorCandidates.map((estimate) => estimate.setLogId), [
        'z',
        'a',
      ]);
      expect(input, [b, a, older]);
      expect(() => summary.estimates.clear(), throwsUnsupportedError);
      expect(() => summary.anchorCandidates.clear(), throwsUnsupportedError);
    },
  );
}
