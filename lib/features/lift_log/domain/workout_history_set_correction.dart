import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';

/// Replaces actual values while retaining a log's identity and prescription.
class WorkoutHistorySetCorrection {
  const WorkoutHistorySetCorrection({
    required this.expected,
    this.actualReps,
    this.actualWeightKg,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualRpe,
    this.actualRir,
    this.notes,
  });

  final WorkoutHistorySetItem expected;
  final int? actualReps;
  final double? actualWeightKg;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;
  final double? actualRpe;
  final int? actualRir;
  final String? notes;

  bool get isValid => isValidFor(expected);

  /// The repository passes its persisted source to enforce required results.
  bool isValidFor(WorkoutHistorySetItem source) =>
      source.hasCompletedLog &&
      _hasRequiredResults(source) &&
      (actualReps == null || actualReps! > 0) &&
      _nonNegative(actualWeightKg) &&
      (actualDurationSeconds == null || actualDurationSeconds! > 0) &&
      (actualDistanceMeters == null ||
          actualDistanceMeters!.isFinite && actualDistanceMeters! > 0) &&
      (actualRpe == null ||
          actualRpe!.isFinite && actualRpe! >= 1 && actualRpe! <= 10) &&
      (actualRir == null || actualRir! >= 0 && actualRir! <= 5);

  static bool _nonNegative(double? value) =>
      value == null || value.isFinite && value >= 0;

  bool _hasRequiredResults(WorkoutHistorySetItem source) {
    final type = source.resolvedLoggingType;
    return switch (type) {
      ExerciseLoggingType.repsWeight =>
        actualReps != null && actualWeightKg != null,
      ExerciseLoggingType.repsOnly => actualReps != null,
      ExerciseLoggingType.duration =>
        source.loggingType == ExerciseLoggingType.duration ||
                source.prescribedDurationSeconds != null
            ? actualDurationSeconds != null
            : source.prescribedDistanceMeters != null
            ? actualDistanceMeters != null
            : actualDurationSeconds != null || actualDistanceMeters != null,
    };
  }
}

/// Safe correction failures contain no private set values or notes.
enum WorkoutHistoryCorrectionFailure implements Exception {
  invalid,
  missing,
  conflict,
}
