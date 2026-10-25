import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _SetFixtures {
  static WorkoutRunnerSetItem get target => WorkoutRunnerSetItem(
    id: 'set',
    exerciseId: 1,
    setIndex: 0,
    setType: SetType.working,
    performedAt: DateTime(2026),
    completed: false,
    skipped: false,
    prescribedRepsExact: 8,
    prescribedWeightKg: 40,
    prescribedRpeMin: 8,
    prescribedRir: 2,
  );
}

void main() {
  test(
    'duration requires time and keeps distance optional even with distance targets',
    () {
      final set = WorkoutRunnerSetItem(
        id: 'distance-only',
        exerciseId: 1,
        setIndex: 0,
        setType: SetType.working,
        performedAt: DateTime(2026),
        completed: false,
        skipped: false,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          set,
          loggingType: ExerciseLoggingType.duration,
        ),
        isFalse,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          set.copyWith(actualDistanceMeters: 1000),
          loggingType: ExerciseLoggingType.duration,
        ),
        isFalse,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          set.copyWith(actualDurationSeconds: 90),
          loggingType: ExerciseLoggingType.duration,
        ),
        isTrue,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          set.copyWith(
            prescribedDurationSeconds: 90,
            actualDistanceMeters: 1000,
          ),
          loggingType: ExerciseLoggingType.duration,
        ),
        isFalse,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          set.copyWith(
            prescribedDistanceMeters: 1000,
            actualDurationSeconds: 90,
          ),
          loggingType: ExerciseLoggingType.duration,
        ),
        isTrue,
      );
    },
  );

  test(
    'substitution keeps completed strength results valid after a timed replacement',
    () {
      final original = _SetFixtures.target.copyWith(
        actualReps: 8,
        actualWeightKg: 40,
        completed: true,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          original,
          loggingType: ExerciseLoggingType.duration,
          currentExerciseId: 2,
        ),
        isTrue,
      );
      expect(
        WorkoutRunnerSetPolicy.canComplete(
          original.copyWith(exerciseId: 2),
          loggingType: ExerciseLoggingType.duration,
          currentExerciseId: 2,
        ),
        isFalse,
      );
    },
  );

  test('prescriptions cannot count as actual logged results', () {
    expect(WorkoutRunnerSetPolicy.canComplete(_SetFixtures.target), isFalse);
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        _SetFixtures.target.copyWith(actualWeightKg: 35, actualReps: 7),
      ),
      isTrue,
    );
  });

  test('bodyweight reps require no actual weight, despite a weight target', () {
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        _SetFixtures.target.copyWith(actualReps: 12),
        loggingType: ExerciseLoggingType.repsOnly,
      ),
      isTrue,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        _SetFixtures.target,
        loggingType: ExerciseLoggingType.repsOnly,
      ),
      isFalse,
    );
  });

  test('time and distance activities require appropriate positive actuals', () {
    final timed = _SetFixtures.target.copyWith(prescribedDurationSeconds: 60);
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        timed,
        loggingType: ExerciseLoggingType.duration,
      ),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        timed.copyWith(actualDurationSeconds: 55),
        loggingType: ExerciseLoggingType.duration,
      ),
      isTrue,
    );
    final distance = _SetFixtures.target.copyWith(
      prescribedDistanceMeters: 1000,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        distance.copyWith(actualDistanceMeters: 950),
        loggingType: ExerciseLoggingType.duration,
      ),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        distance.copyWith(actualDistanceMeters: 0),
        loggingType: ExerciseLoggingType.duration,
      ),
      isFalse,
    );
  });

  test('optional effort is validated when provided and zero RIR is valid', () {
    final actual = _SetFixtures.target.copyWith(
      actualReps: 8,
      actualWeightKg: 0,
    );
    expect(WorkoutRunnerSetPolicy.canComplete(actual), isTrue);
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        actual.copyWith(actualRpe: 1, actualRir: 0),
      ),
      isTrue,
    );
    for (final value in [0.0, 10.5, double.nan, double.infinity]) {
      expect(
        WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualRpe: value)),
        isFalse,
      );
    }
    expect(
      WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualRir: -1)),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualRir: 6)),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualRir: 5)),
      isTrue,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualWeightKg: -1)),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(actual.copyWith(actualReps: 0)),
      isFalse,
    );
    expect(
      WorkoutRunnerSetPolicy.canComplete(
        actual.copyWith(actualDurationSeconds: 0),
      ),
      isFalse,
    );
  });
}
