import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';

class WorkoutHistorySetItem {
  const WorkoutHistorySetItem({
    required this.id,
    required this.setIndex,
    required this.setType,
    required this.completed,
    required this.skipped,
    this.setIntent,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedRepsExact,
    this.prescribedWeightKg,
    this.prescribedDurationSeconds,
    this.prescribedDistanceMeters,
    this.prescribedRir,
    this.actualReps,
    this.actualWeightKg,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualRpe,
    this.actualRir,
    this.notes,
    this.updatedAt,
    this.exerciseId,
    this.loggingType,
  });

  final String id;
  final int setIndex;
  final SetType setType;
  final bool completed;
  final bool skipped;
  final SetIntent? setIntent;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final int? prescribedRepsExact;
  final double? prescribedWeightKg;
  final int? prescribedDurationSeconds;
  final double? prescribedDistanceMeters;
  final int? prescribedRir;
  final int? actualReps;
  final double? actualWeightKg;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;
  final double? actualRpe;
  final int? actualRir;
  final String? notes;
  final DateTime? updatedAt;
  final int? exerciseId;
  final ExerciseLoggingType? loggingType;

  ExerciseLoggingType get resolvedLoggingType {
    if (loggingType != null) return loggingType!;
    if (prescribedDurationSeconds != null ||
        prescribedDistanceMeters != null ||
        prescribedRepsExact == null &&
            prescribedRepsMin == null &&
            prescribedRepsMax == null &&
            (actualDurationSeconds != null || actualDistanceMeters != null)) {
      return ExerciseLoggingType.duration;
    }
    return prescribedWeightKg != null || actualWeightKg != null
        ? ExerciseLoggingType.repsWeight
        : ExerciseLoggingType.repsOnly;
  }

  /// A completed performance with real results, rather than just targets.
  bool get hasCompletedLog {
    if (!completed || skipped) return false;
    final hasReps = actualReps != null && actualReps! > 0;
    final hasWeight =
        actualWeightKg != null &&
        actualWeightKg!.isFinite &&
        actualWeightKg! >= 0;
    final hasDuration =
        actualDurationSeconds != null && actualDurationSeconds! > 0;
    final hasDistance =
        actualDistanceMeters != null &&
        actualDistanceMeters!.isFinite &&
        actualDistanceMeters! > 0;
    return switch (loggingType) {
      ExerciseLoggingType.repsWeight => hasReps && hasWeight,
      ExerciseLoggingType.repsOnly => hasReps,
      ExerciseLoggingType.duration => hasDuration,
      // Older sessions did not persist a logging-type snapshot.
      null => hasReps || hasDuration || hasDistance,
    };
  }
}
