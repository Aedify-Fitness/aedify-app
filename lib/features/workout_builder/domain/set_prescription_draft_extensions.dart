import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';

extension SetPrescriptionDraftX on SetPrescriptionDraft {
  bool get isWarmup => setType == SetType.warmup;

  bool get isWorking => setType == SetType.working;

  SetPrescriptionDraft withSetType(SetType setType) {
    return copyWith(setType: setType);
  }
}
