import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/weight_prescription_type.dart';
import 'package:aedify/shared/domain/loading_model.dart';

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
  final SetType setType;
  final SetIntent? setIntent;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final int? prescribedRepsExact;
  final int? durationSeconds;
  final double? distanceMeters;
  final WeightPrescriptionType? weightPrescriptionType;
  final double? prescribedWeightKg;
  final double? prescribedWeightPct1rm;
  final double? prescribedWeightPctWorking;
  final double? bodyweightMultiplier;
  final double? prescribedRpeMin;
  final double? prescribedRpeMax;
  final int? prescribedRir;
  final int? restSeconds;
  final LoadingModel? loadingModel;
  final double? percent1rmMin;
  final double? percent1rmMax;
  final double? rpeMin;
  final double? rpeMax;
  final String? loadSelectionNote;
  final bool isCalibrationEstimate;
  final int? derivedFromWorkingSetIndex;
  final String? warmupWeightRuleJson;
  static const _unchanged = Object();

  /// Copies editable targets, allowing explicit nulls to clear optional values.
  SetPrescriptionDraft copyWith({
    String? id,
    int? setIndex,
    SetType? setType,
    Object? setIntent = _unchanged,
    Object? prescribedRepsMin = _unchanged,
    Object? prescribedRepsMax = _unchanged,
    Object? prescribedRepsExact = _unchanged,
    Object? durationSeconds = _unchanged,
    Object? distanceMeters = _unchanged,
    Object? weightPrescriptionType = _unchanged,
    Object? prescribedWeightKg = _unchanged,
    Object? prescribedWeightPct1rm = _unchanged,
    Object? prescribedWeightPctWorking = _unchanged,
    Object? bodyweightMultiplier = _unchanged,
    Object? prescribedRpeMin = _unchanged,
    Object? prescribedRpeMax = _unchanged,
    Object? prescribedRir = _unchanged,
    Object? restSeconds = _unchanged,
    Object? loadingModel = _unchanged,
    Object? percent1rmMin = _unchanged,
    Object? percent1rmMax = _unchanged,
    Object? rpeMin = _unchanged,
    Object? rpeMax = _unchanged,
    Object? loadSelectionNote = _unchanged,
    Object? derivedFromWorkingSetIndex = _unchanged,
    Object? warmupWeightRuleJson = _unchanged,
    bool? isCalibrationEstimate,
  }) => SetPrescriptionDraft(
    id: id ?? this.id,
    setIndex: setIndex ?? this.setIndex,
    setType: setType ?? this.setType,
    setIntent: identical(setIntent, _unchanged)
        ? this.setIntent
        : setIntent as SetIntent?,
    prescribedRepsMin: identical(prescribedRepsMin, _unchanged)
        ? this.prescribedRepsMin
        : prescribedRepsMin as int?,
    prescribedRepsMax: identical(prescribedRepsMax, _unchanged)
        ? this.prescribedRepsMax
        : prescribedRepsMax as int?,
    prescribedRepsExact: identical(prescribedRepsExact, _unchanged)
        ? this.prescribedRepsExact
        : prescribedRepsExact as int?,
    durationSeconds: identical(durationSeconds, _unchanged)
        ? this.durationSeconds
        : durationSeconds as int?,
    distanceMeters: identical(distanceMeters, _unchanged)
        ? this.distanceMeters
        : distanceMeters as double?,
    weightPrescriptionType: identical(weightPrescriptionType, _unchanged)
        ? this.weightPrescriptionType
        : weightPrescriptionType as WeightPrescriptionType?,
    prescribedWeightKg: identical(prescribedWeightKg, _unchanged)
        ? this.prescribedWeightKg
        : prescribedWeightKg as double?,
    prescribedWeightPct1rm: identical(prescribedWeightPct1rm, _unchanged)
        ? this.prescribedWeightPct1rm
        : prescribedWeightPct1rm as double?,
    prescribedWeightPctWorking:
        identical(prescribedWeightPctWorking, _unchanged)
        ? this.prescribedWeightPctWorking
        : prescribedWeightPctWorking as double?,
    bodyweightMultiplier: identical(bodyweightMultiplier, _unchanged)
        ? this.bodyweightMultiplier
        : bodyweightMultiplier as double?,
    prescribedRpeMin: identical(prescribedRpeMin, _unchanged)
        ? this.prescribedRpeMin
        : prescribedRpeMin as double?,
    prescribedRpeMax: identical(prescribedRpeMax, _unchanged)
        ? this.prescribedRpeMax
        : prescribedRpeMax as double?,
    prescribedRir: identical(prescribedRir, _unchanged)
        ? this.prescribedRir
        : prescribedRir as int?,
    restSeconds: identical(restSeconds, _unchanged)
        ? this.restSeconds
        : restSeconds as int?,
    loadingModel: identical(loadingModel, _unchanged)
        ? this.loadingModel
        : loadingModel as LoadingModel?,
    percent1rmMin: identical(percent1rmMin, _unchanged)
        ? this.percent1rmMin
        : percent1rmMin as double?,
    percent1rmMax: identical(percent1rmMax, _unchanged)
        ? this.percent1rmMax
        : percent1rmMax as double?,
    rpeMin: identical(rpeMin, _unchanged) ? this.rpeMin : rpeMin as double?,
    rpeMax: identical(rpeMax, _unchanged) ? this.rpeMax : rpeMax as double?,
    loadSelectionNote: identical(loadSelectionNote, _unchanged)
        ? this.loadSelectionNote
        : loadSelectionNote as String?,
    derivedFromWorkingSetIndex:
        identical(derivedFromWorkingSetIndex, _unchanged)
        ? this.derivedFromWorkingSetIndex
        : derivedFromWorkingSetIndex as int?,
    warmupWeightRuleJson: identical(warmupWeightRuleJson, _unchanged)
        ? this.warmupWeightRuleJson
        : warmupWeightRuleJson as String?,
    isCalibrationEstimate: isCalibrationEstimate ?? this.isCalibrationEstimate,
  );
}
