import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';

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
    this.prescribedWeightKg,
    this.actualReps,
    this.actualWeightKg,
    this.actualRpe,
    this.actualRir,
    this.notes,
  });

  final String id;
  final int setIndex;
  final SetType setType;
  final bool completed;
  final bool skipped;
  final SetIntent? setIntent;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final double? prescribedWeightKg;
  final int? actualReps;
  final double? actualWeightKg;
  final double? actualRpe;
  final int? actualRir;
  final String? notes;
}
