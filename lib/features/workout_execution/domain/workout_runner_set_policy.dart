import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';

/// Validates actual results without treating prescribed targets as results.
abstract final class WorkoutRunnerSetPolicy {
  static ExerciseLoggingType loggingType(
    WorkoutRunnerSetItem set, {
    ExerciseLoggingType? snapshot,
  }) =>
      snapshot ??
      (set.prescribedDurationSeconds != null ||
              set.prescribedDistanceMeters != null ||
              (set.prescribedRepsExact == null &&
                  set.prescribedRepsMin == null &&
                  set.prescribedRepsMax == null &&
                  (set.actualDurationSeconds != null ||
                      set.actualDistanceMeters != null))
          ? ExerciseLoggingType.duration
          : set.prescribedWeightKg != null || set.actualWeightKg != null
          ? ExerciseLoggingType.repsWeight
          : ExerciseLoggingType.repsOnly);

  static bool hasCompletedLog(
    WorkoutRunnerSetItem set, {
    ExerciseLoggingType? loggingType,
  }) {
    if (!set.completed || set.skipped) return false;
    final reps = set.actualReps != null && set.actualReps! > 0;
    final weight =
        set.actualWeightKg != null &&
        set.actualWeightKg!.isFinite &&
        set.actualWeightKg! >= 0;
    final duration =
        set.actualDurationSeconds != null && set.actualDurationSeconds! > 0;
    final distance =
        set.actualDistanceMeters != null &&
        set.actualDistanceMeters!.isFinite &&
        set.actualDistanceMeters! > 0;
    return switch (loggingType) {
      ExerciseLoggingType.repsWeight => reps && weight,
      ExerciseLoggingType.repsOnly => reps,
      ExerciseLoggingType.duration => duration,
      null => reps || duration || distance,
    };
  }

  static bool hasValidActuals(WorkoutRunnerSetItem set) =>
      (set.actualReps == null || set.actualReps! > 0) &&
      (set.actualWeightKg == null ||
          set.actualWeightKg!.isFinite && set.actualWeightKg! >= 0) &&
      (set.actualDurationSeconds == null || set.actualDurationSeconds! > 0) &&
      (set.actualDistanceMeters == null ||
          set.actualDistanceMeters!.isFinite &&
              set.actualDistanceMeters! > 0) &&
      (set.actualRpe == null ||
          set.actualRpe!.isFinite &&
              set.actualRpe! >= 1 &&
              set.actualRpe! <= 10) &&
      (set.actualRir == null || set.actualRir! >= 0 && set.actualRir! <= 5);

  static bool canComplete(
    WorkoutRunnerSetItem set, {
    ExerciseLoggingType? loggingType,
    int? currentExerciseId,
  }) {
    if (!hasValidActuals(set)) return false;
    return switch (WorkoutRunnerSetPolicy.loggingType(
      set,
      snapshot: currentExerciseId == null || currentExerciseId == set.exerciseId
          ? loggingType
          : null,
    )) {
      ExerciseLoggingType.repsWeight =>
        set.actualReps != null && set.actualWeightKg != null,
      ExerciseLoggingType.repsOnly => set.actualReps != null,
      ExerciseLoggingType.duration => set.actualDurationSeconds != null,
    };
  }
}
