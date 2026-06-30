import 'package:aedify/core/validation/validated_set_draft.dart';

class ValidatedExerciseDraft {
  const ValidatedExerciseDraft({
    required this.id,
    required this.modality,
    required this.sets,
    this.supersetGroupId,
    this.supersetOrder,
    this.exerciseReferenceId,
  });

  final String id;
  final String modality;
  final List<ValidatedSetDraft> sets;
  final String? supersetGroupId;
  final int? supersetOrder;
  final int? exerciseReferenceId;
}
