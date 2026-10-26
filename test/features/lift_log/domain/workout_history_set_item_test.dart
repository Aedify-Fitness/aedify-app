import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _HistorySetFixtures {
  static WorkoutHistorySetItem set({
    ExerciseLoggingType? type,
    bool completed = true,
    bool skipped = false,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
  }) => WorkoutHistorySetItem(
    id: 'set',
    setIndex: 0,
    setType: SetType.working,
    completed: completed,
    skipped: skipped,
    loggingType: type,
    prescribedRepsExact: 8,
    prescribedWeightKg: 80,
    prescribedDurationSeconds: 60,
    prescribedDistanceMeters: 100,
    actualReps: reps,
    actualWeightKg: weight,
    actualDurationSeconds: duration,
    actualDistanceMeters: distance,
    actualRpe: 8,
    actualRir: 2,
    notes: 'Not a performance log',
  );
}

void main() {
  test(
    'performance history requires completed, non-skipped actual results',
    () {
      expect(_HistorySetFixtures.set().hasCompletedLog, isFalse);
      expect(
        _HistorySetFixtures.set(reps: 8, completed: false).hasCompletedLog,
        isFalse,
      );
      expect(
        _HistorySetFixtures.set(reps: 8, skipped: true).hasCompletedLog,
        isFalse,
      );
      expect(_HistorySetFixtures.set(reps: 8).hasCompletedLog, isTrue);
      expect(
        _HistorySetFixtures.set(reps: 0, distance: double.nan).hasCompletedLog,
        isFalse,
      );
    },
  );

  test(
    'performance history honors logging types and preserves legacy distance logs',
    () {
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.repsWeight,
          reps: 8,
        ).hasCompletedLog,
        isFalse,
      );
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.repsWeight,
          reps: 8,
          weight: 0,
        ).hasCompletedLog,
        isTrue,
      );
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.repsWeight,
          reps: 8,
          weight: double.infinity,
        ).hasCompletedLog,
        isFalse,
      );
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.repsOnly,
          reps: 8,
        ).hasCompletedLog,
        isTrue,
      );
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.duration,
          distance: 100,
        ).hasCompletedLog,
        isFalse,
      );
      expect(
        _HistorySetFixtures.set(
          type: ExerciseLoggingType.duration,
          duration: 60,
        ).hasCompletedLog,
        isTrue,
      );
      expect(_HistorySetFixtures.set(distance: 100).hasCompletedLog, isTrue);
    },
  );
}
