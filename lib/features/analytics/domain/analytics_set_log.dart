import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';

/// Local analytics evidence from a completed, non-skipped working set.
///
/// Values retain canonical kg, metres and seconds. Missing values remain null;
/// metric-specific eligibility belongs to the consuming analytics service.
/// This DTO excludes notes, body measurements and stored derived PR/e1RM flags.
class AnalyticsSetLog {
  const AnalyticsSetLog({
    required this.id,
    required this.sessionId,
    required this.sessionExerciseId,
    required this.exerciseId,
    required this.source,
    required this.performedAt,
    required this.completedAt,
    required this.setIndex,
    required this.updatedAt,
    this.modality,
    this.loggingType,
    this.equipment,
    this.actualReps,
    this.actualWeightKg,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualRpe,
    this.actualRir,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedRepsExact,
    this.prescribedWeightKg,
  });

  final String id;
  final String sessionId;
  final String sessionExerciseId;
  final int exerciseId;
  final SessionSource source;
  final DateTime performedAt;
  final DateTime completedAt;
  final int setIndex;
  final DateTime updatedAt;

  /// Missing or unknown catalogue metadata must not imply strength eligibility.
  final ExerciseModality? modality;
  final ExerciseLoggingType? loggingType;
  final String? equipment;
  final int? actualReps;
  final double? actualWeightKg;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;
  final double? actualRpe;
  final int? actualRir;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final int? prescribedRepsExact;
  final double? prescribedWeightKg;
}
