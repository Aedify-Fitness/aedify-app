import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/shared/domain/rpe_load_estimator.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/workout_execution/weight_suggestion_fixtures.dart';

void main() {
  test(
    'adjusted heuristic calculates effort-aware strength and rounds down',
    () {
      expect(RpeLoadEstimator.strengthEstimate(100, 5, 9), closeTo(120, .0001));
      expect(RpeLoadEstimator.load(120, 5, 8), 95);
      expect(RpeLoadEstimator.load(120, 5, 9), 100);
      expect(RpeLoadEstimator.strengthEstimate(100, 1, 10), 100);
      expect(RpeLoadEstimator.load(100, 1, 10), 100);
      expect(
        RpeLoadEstimator.strengthEstimate(100, 5, 8.5),
        closeTo(121.666666, .0001),
      );
    },
  );
  test('invalid and unsupported inputs never yield a load', () {
    for (final value in [double.nan, double.infinity, -1.0, 0.0]) {
      expect(RpeLoadEstimator.strengthEstimate(value, 5, 8), isNull);
      expect(RpeLoadEstimator.load(value, 5, 8), isNull);
    }
    for (final rpe in [double.nan, double.infinity, 5.0, 11.0]) {
      expect(RpeLoadEstimator.strengthEstimate(100, 5, rpe), isNull);
    }
    for (final reps in [0, 11]) {
      expect(RpeLoadEstimator.load(100, reps, 8), isNull);
    }
  });
  test(
    'uses the median of recent valid sets, not the all-time heaviest set',
    () {
      final result = WeightSuggestionFixtures.suggestion(
        references: [
          WeightSuggestionFixtures.reference(id: 'outlier', weight: 1000),
          WeightSuggestionFixtures.reference(id: 'normal', weight: 100),
          WeightSuggestionFixtures.reference(id: 'lower', weight: 90),
          WeightSuggestionFixtures.reference(
            id: 'stale',
            weight: 2000,
            date: WeightSuggestionFixtures.now.subtract(
              const Duration(days: 91),
            ),
          ),
          WeightSuggestionFixtures.reference(
            id: 'missing-rpe',
            weight: 3000,
            rpe: null,
          ),
        ],
      )!;
      expect(result.weightKg, 95);
      expect(result.reference.id, 'normal');
      expect(result.referenceCount, 3);
    },
  );
  test(
    'latest completed working set in this session adapts the next proposal',
    () {
      final member = WeightSuggestionFixtures.exercise(
        sets: [
          WeightSuggestionFixtures.set(
            id: 'warmup',
            completed: true,
            type: SetType.warmup,
            weight: 200,
            reps: 5,
            rpe: 8,
          ),
          WeightSuggestionFixtures.set(
            id: 'logged',
            completed: true,
            weight: 90,
            reps: 5,
            rpe: 10,
          ),
          WeightSuggestionFixtures.set(index: 2),
        ],
      );
      final result = WeightSuggestionFixtures.suggestion(member: member)!;
      expect(result.reference.id, 'logged');
      expect(result.weightKg, 85);
      expect(result.reference.source, LoadReferenceSource.currentWorkout);
    },
  );
  test(
    'pending, skipped, warmup and missing-effort current sets do not anchor estimates',
    () {
      for (final log in [
        WeightSuggestionFixtures.set(
          id: 'pending',
          weight: 200,
          reps: 5,
          rpe: 10,
        ),
        WeightSuggestionFixtures.set(
          id: 'skipped',
          completed: true,
          skipped: true,
          weight: 200,
          reps: 5,
          rpe: 10,
        ),
        WeightSuggestionFixtures.set(
          id: 'warmup',
          completed: true,
          type: SetType.warmup,
          weight: 200,
          reps: 5,
          rpe: 10,
        ),
        WeightSuggestionFixtures.set(
          id: 'unknown',
          completed: true,
          weight: 200,
          reps: 5,
        ),
      ]) {
        final result = WeightSuggestionFixtures.suggestion(
          member: WeightSuggestionFixtures.exercise(
            sets: [log, WeightSuggestionFixtures.set(index: 1)],
          ),
        )!;
        expect(result.reference.source, LoadReferenceSource.history);
      }
    },
  );
  test(
    'recent known max is a fallback, while absent or stale evidence produces no guess',
    () {
      final anchor = WeightSuggestionFixtures.reference(
        weight: 120,
        source: LoadReferenceSource.knownMax,
      );
      expect(
        WeightSuggestionFixtures.suggestion(references: [anchor])!.weightKg,
        95,
      );
      expect(WeightSuggestionFixtures.suggestion(references: []), isNull);
      expect(
        WeightSuggestionFixtures.suggestion(
          references: [
            WeightSuggestionFixtures.reference(
              date: WeightSuggestionFixtures.now.add(const Duration(days: 1)),
            ),
          ],
        ),
        isNull,
      );
    },
  );
  test('warmup targets and non-weight logging types have no suggestions', () {
    expect(
      WeightSuggestionFixtures.suggestion(
        member: WeightSuggestionFixtures.exercise(
          sets: [WeightSuggestionFixtures.set(type: SetType.warmup)],
        ),
      ),
      isNull,
    );
    for (final type in [
      ExerciseLoggingType.duration,
      ExerciseLoggingType.repsOnly,
    ]) {
      expect(
        WeightSuggestionFixtures.suggestion(
          member: WeightSuggestionFixtures.exercise(type: type),
        ),
        isNull,
      );
    }
    expect(WeightSuggestionFixtures.suggestion(supported: false), isNull);
  });
  test('only supported conventional resistance loads are eligible', () {
    for (final name in [
      'Assisted pull-up',
      'Weighted chin up',
      'Weighted push-up',
      'Dips',
      'Bodyweight squat',
    ]) {
      expect(
        WeightSuggestionPolicy.supportsExercise(
          name: name,
          modality: 'strength',
        ),
        isFalse,
      );
    }
    expect(
      WeightSuggestionPolicy.supportsExercise(
        name: 'Bench press',
        modality: 'strength',
        equipment: 'barbell',
      ),
      isTrue,
    );
    expect(
      WeightSuggestionPolicy.supportsExercise(
        name: 'Push up',
        modality: 'strength',
        equipment: 'bodyweight',
      ),
      isFalse,
    );
    expect(
      WeightSuggestionPolicy.supportsExercise(name: 'Run', modality: 'cardio'),
      isFalse,
    );
  });
  test(
    'RIR-only and ranged prescriptions resolve to an explicit conservative target',
    () {
      final set = WeightSuggestionFixtures.set(
        targets: false,
      ).copyWith(prescribedRepsMin: 5, prescribedRepsMax: 8, prescribedRir: 2);
      final target = WeightSuggestionTarget.fromSet(set)!;
      expect(target.reps, 5);
      expect(target.rpe, 8);
      final ranged = WeightSuggestionTarget.fromSet(
        set.copyWith(prescribedRpeMin: 7, prescribedRpeMax: 9),
      )!;
      expect(ranged.rpe, 7);
      expect(
        WeightSuggestionTarget.fromSet(
          WeightSuggestionFixtures.set(targets: false),
        ),
        isNull,
      );
    },
  );
}
