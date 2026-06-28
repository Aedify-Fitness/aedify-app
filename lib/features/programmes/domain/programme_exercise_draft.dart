import 'set_prescription_draft.dart';

class ProgrammeExerciseDraft {
  const ProgrammeExerciseDraft({
    required this.id,
    required this.exerciseId,
    required this.sortOrder,
    required this.sets,
    this.exerciseRef,
    this.exerciseRole,
    this.programmeRole,
    this.supersetGroupId,
    this.supersetOrder,
    this.notes,
    this.cuesJson,
  });

  final String id;
  final int exerciseId;
  final int sortOrder;
  final List<SetPrescriptionDraft> sets;
  final String? exerciseRef;
  final String? exerciseRole;
  final String? programmeRole;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? notes;
  final String? cuesJson;
}
