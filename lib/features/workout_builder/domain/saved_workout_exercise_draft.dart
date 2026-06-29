import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/exercise_role.dart';

class SavedWorkoutExerciseDraft {
  const SavedWorkoutExerciseDraft({
    required this.id,
    required this.exerciseId,
    required this.sortOrder,
    required this.sets,
    this.exerciseRef,
    this.exerciseRole,
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
  final ExerciseRole? exerciseRole;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? notes;
  final String? cuesJson;
}
