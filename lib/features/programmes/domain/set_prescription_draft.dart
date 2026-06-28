class SetPrescriptionDraft {
  const SetPrescriptionDraft({
    required this.id,
    required this.setIndex,
    required this.setType,
    this.setIntent,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedRepsExact,
    this.durationSeconds,
    this.distanceMeters,
    this.weightPrescriptionType,
    this.prescribedWeightKg,
    this.prescribedWeightPct1rm,
    this.prescribedWeightPctWorking,
    this.bodyweightMultiplier,
    this.prescribedRpeMin,
    this.prescribedRpeMax,
    this.prescribedRir,
    this.restSeconds,
    this.loadingModel,
    this.percent1rmMin,
    this.percent1rmMax,
    this.rpeMin,
    this.rpeMax,
    this.loadSelectionNote,
    this.isCalibrationEstimate = false,
    this.derivedFromWorkingSetIndex,
    this.warmupWeightRuleJson,
  });

  final String id;
  final int setIndex;
  final String setType;
  final String? setIntent;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final int? prescribedRepsExact;
  final int? durationSeconds;
  final double? distanceMeters;
  final String? weightPrescriptionType;
  final double? prescribedWeightKg;
  final double? prescribedWeightPct1rm;
  final double? prescribedWeightPctWorking;
  final double? bodyweightMultiplier;
  final double? prescribedRpeMin;
  final double? prescribedRpeMax;
  final int? prescribedRir;
  final int? restSeconds;
  final String? loadingModel;
  final double? percent1rmMin;
  final double? percent1rmMax;
  final double? rpeMin;
  final double? rpeMax;
  final String? loadSelectionNote;
  final bool isCalibrationEstimate;
  final int? derivedFromWorkingSetIndex;
  final String? warmupWeightRuleJson;
}
