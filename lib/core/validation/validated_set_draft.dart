import 'package:aedify/shared/domain/set_type.dart';

class ValidatedSetDraft {
  const ValidatedSetDraft({
    required this.id,
    required this.setType,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedRepsExact,
    this.prescribedWeightKg,
    this.prescribedRpeMin,
    this.prescribedRpeMax,
    this.prescribedRir,
    this.restSeconds,
    this.derivedFromWorkingSetIndex,
  });

  final String id;
  final SetType setType;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final int? prescribedRepsExact;
  final double? prescribedWeightKg;
  final double? prescribedRpeMin;
  final double? prescribedRpeMax;
  final int? prescribedRir;
  final int? restSeconds;
  final int? derivedFromWorkingSetIndex;
}
