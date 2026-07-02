import 'package:aedify/shared/domain/exercise_role.dart';
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
    this.restBetweenExercisesSeconds,
  });

  final String id;
  final int exerciseId;
  final int sortOrder;
  final List<SetPrescriptionDraft> sets;
  final String? exerciseRef;
  final ExerciseRole? exerciseRole;
  final String? programmeRole;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? notes;
  final String? cuesJson;
  final int? restBetweenExercisesSeconds;

  ProgrammeExerciseDraft copyWith({
    String? id,
    int? exerciseId,
    int? sortOrder,
    List<SetPrescriptionDraft>? sets,
    String? exerciseRef,
    ExerciseRole? exerciseRole,
    String? programmeRole,
    String? supersetGroupId,
    int? supersetOrder,
    String? notes,
    String? cuesJson,
    int? restBetweenExercisesSeconds,
  }) {
    return ProgrammeExerciseDraft(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      sortOrder: sortOrder ?? this.sortOrder,
      sets: sets ?? this.sets,
      exerciseRef: exerciseRef ?? this.exerciseRef,
      exerciseRole: exerciseRole ?? this.exerciseRole,
      programmeRole: programmeRole ?? this.programmeRole,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      supersetOrder: supersetOrder ?? this.supersetOrder,
      notes: notes ?? this.notes,
      cuesJson: cuesJson ?? this.cuesJson,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    );
  }
}
