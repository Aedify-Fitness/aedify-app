class SetLogDraft {
  const SetLogDraft({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    required this.performedAt,
    required this.setType,
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
    this.completed = false,
    this.skipped = false,
    this.isPr = false,
    this.estimated1rmKg,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final int setIndex;
  final DateTime performedAt;
  final String setType;
  final String? setIntent;
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
  final bool completed;
  final bool skipped;
  final bool isPr;
  final double? estimated1rmKg;
  final String? notes;
}
