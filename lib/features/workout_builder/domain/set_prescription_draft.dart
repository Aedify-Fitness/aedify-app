import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/weight_prescription_type.dart';

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
    this.prescribedRpeMin,
    this.prescribedRpeMax,
    this.prescribedRir,
    this.restSeconds,
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
  final double? prescribedRpeMin;
  final double? prescribedRpeMax;
  final int? prescribedRir;
  final int? restSeconds;

  SetPrescriptionDraft clearTarget() {
    return SetPrescriptionDraft(
      id: id,
      setIndex: setIndex,
      setType: setType,
      setIntent: setIntent,
      prescribedRepsMin: prescribedRepsMin,
      prescribedRepsMax: prescribedRepsMax,
      prescribedRepsExact: prescribedRepsExact,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      weightPrescriptionType: weightPrescriptionType,
      prescribedWeightKg: prescribedWeightKg,
      prescribedRpeMin: null,
      prescribedRpeMax: null,
      prescribedRir: null,
      restSeconds: restSeconds,
    );
  }

  SetPrescriptionDraft clearReps() {
    return SetPrescriptionDraft(
      id: id,
      setIndex: setIndex,
      setType: setType,
      setIntent: setIntent,
      prescribedRepsMin: null,
      prescribedRepsMax: null,
      prescribedRepsExact: null,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      weightPrescriptionType: weightPrescriptionType,
      prescribedWeightKg: prescribedWeightKg,
      prescribedRpeMin: prescribedRpeMin,
      prescribedRpeMax: prescribedRpeMax,
      prescribedRir: prescribedRir,
      restSeconds: restSeconds,
    );
  }

  SetPrescriptionDraft clearWeight() {
    return SetPrescriptionDraft(
      id: id,
      setIndex: setIndex,
      setType: setType,
      setIntent: setIntent,
      prescribedRepsMin: prescribedRepsMin,
      prescribedRepsMax: prescribedRepsMax,
      prescribedRepsExact: prescribedRepsExact,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      weightPrescriptionType: weightPrescriptionType,
      prescribedWeightKg: null,
      prescribedRpeMin: prescribedRpeMin,
      prescribedRpeMax: prescribedRpeMax,
      prescribedRir: prescribedRir,
      restSeconds: restSeconds,
    );
  }

  SetPrescriptionDraft clearRest() {
    return SetPrescriptionDraft(
      id: id,
      setIndex: setIndex,
      setType: setType,
      setIntent: setIntent,
      prescribedRepsMin: prescribedRepsMin,
      prescribedRepsMax: prescribedRepsMax,
      prescribedRepsExact: prescribedRepsExact,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      weightPrescriptionType: weightPrescriptionType,
      prescribedWeightKg: prescribedWeightKg,
      prescribedRpeMin: prescribedRpeMin,
      prescribedRpeMax: prescribedRpeMax,
      prescribedRir: prescribedRir,
      restSeconds: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetPrescriptionDraft &&
          id == other.id &&
          setIndex == other.setIndex &&
          setType == other.setType &&
          setIntent == other.setIntent &&
          prescribedRepsMin == other.prescribedRepsMin &&
          prescribedRepsMax == other.prescribedRepsMax &&
          prescribedRepsExact == other.prescribedRepsExact &&
          durationSeconds == other.durationSeconds &&
          distanceMeters == other.distanceMeters &&
          weightPrescriptionType == other.weightPrescriptionType &&
          prescribedWeightKg == other.prescribedWeightKg &&
          prescribedRpeMin == other.prescribedRpeMin &&
          prescribedRpeMax == other.prescribedRpeMax &&
          prescribedRir == other.prescribedRir &&
          restSeconds == other.restSeconds;

  @override
  int get hashCode => Object.hash(
    id,
    setIndex,
    setType,
    setIntent,
    prescribedRepsMin,
    prescribedRepsMax,
    prescribedRepsExact,
    durationSeconds,
    distanceMeters,
    weightPrescriptionType,
    prescribedWeightKg,
    prescribedRpeMin,
    prescribedRpeMax,
    prescribedRir,
    restSeconds,
  );

  SetPrescriptionDraft copyWith({
    String? id,
    int? setIndex,
    SetType? setType,
    SetIntent? setIntent,
    int? prescribedRepsMin,
    int? prescribedRepsMax,
    int? prescribedRepsExact,
    int? durationSeconds,
    double? distanceMeters,
    WeightPrescriptionType? weightPrescriptionType,
    double? prescribedWeightKg,
    double? prescribedRpeMin,
    double? prescribedRpeMax,
    int? prescribedRir,
    int? restSeconds,
  }) {
    return SetPrescriptionDraft(
      id: id ?? this.id,
      setIndex: setIndex ?? this.setIndex,
      setType: setType ?? this.setType,
      setIntent: setIntent ?? this.setIntent,
      prescribedRepsMin: prescribedRepsMin ?? this.prescribedRepsMin,
      prescribedRepsMax: prescribedRepsMax ?? this.prescribedRepsMax,
      prescribedRepsExact: prescribedRepsExact ?? this.prescribedRepsExact,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      weightPrescriptionType:
          weightPrescriptionType ?? this.weightPrescriptionType,
      prescribedWeightKg: prescribedWeightKg ?? this.prescribedWeightKg,
      prescribedRpeMin: prescribedRpeMin ?? this.prescribedRpeMin,
      prescribedRpeMax: prescribedRpeMax ?? this.prescribedRpeMax,
      prescribedRir: prescribedRir ?? this.prescribedRir,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
