import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';

class WorkoutRunnerSetItem {
  const WorkoutRunnerSetItem({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    required this.setType,
    required this.performedAt,
    required this.completed,
    required this.skipped,
    this.setIntent,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedWeightKg,
    this.prescribedRpeMin,
    this.prescribedRpeMax,
    this.actualReps,
    this.actualWeightKg,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualRpe,
    this.actualRir,
    this.restSeconds,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final int setIndex;
  final SetType setType;
  final DateTime performedAt;
  final bool completed;
  final bool skipped;
  final SetIntent? setIntent;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final double? prescribedWeightKg;
  final double? prescribedRpeMin;
  final double? prescribedRpeMax;
  final int? actualReps;
  final double? actualWeightKg;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;
  final double? actualRpe;
  final int? actualRir;
  final int? restSeconds;
  final String? notes;

  WorkoutRunnerSetItem copyWith({
    String? id,
    int? exerciseId,
    int? setIndex,
    SetType? setType,
    DateTime? performedAt,
    bool? completed,
    bool? skipped,
    SetIntent? setIntent,
    int? prescribedRepsMin,
    int? prescribedRepsMax,
    double? prescribedWeightKg,
    double? prescribedRpeMin,
    double? prescribedRpeMax,
    int? actualReps,
    double? actualWeightKg,
    int? actualDurationSeconds,
    double? actualDistanceMeters,
    double? actualRpe,
    int? actualRir,
    int? restSeconds,
    String? notes,
  }) {
    return WorkoutRunnerSetItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      setType: setType ?? this.setType,
      performedAt: performedAt ?? this.performedAt,
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      setIntent: setIntent ?? this.setIntent,
      prescribedRepsMin: prescribedRepsMin ?? this.prescribedRepsMin,
      prescribedRepsMax: prescribedRepsMax ?? this.prescribedRepsMax,
      prescribedWeightKg: prescribedWeightKg ?? this.prescribedWeightKg,
      prescribedRpeMin: prescribedRpeMin ?? this.prescribedRpeMin,
      prescribedRpeMax: prescribedRpeMax ?? this.prescribedRpeMax,
      actualReps: actualReps ?? this.actualReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      actualDistanceMeters: actualDistanceMeters ?? this.actualDistanceMeters,
      actualRpe: actualRpe ?? this.actualRpe,
      actualRir: actualRir ?? this.actualRir,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
    );
  }
}
