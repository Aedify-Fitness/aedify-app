import 'package:aedify/shared/domain/exercise_role.dart';
import 'exercise_reference.dart';
import 'set_prescription_draft.dart';

class WorkoutBuilderExerciseDraft {
  const WorkoutBuilderExerciseDraft({
    required this.id,
    required this.exercise,
    required this.sortOrder,
    required this.sets,
    this.exerciseRole,
    this.supersetGroupId,
    this.supersetOrder,
    this.notes,
    this.restBetweenExercisesSeconds,
  });

  final String id;
  final ExerciseReference exercise;
  final int sortOrder;
  final List<SetPrescriptionDraft> sets;
  final ExerciseRole? exerciseRole;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? notes;
  final int? restBetweenExercisesSeconds;

  WorkoutBuilderExerciseDraft copyWith({
    String? id,
    ExerciseReference? exercise,
    int? sortOrder,
    List<SetPrescriptionDraft>? sets,
    ExerciseRole? exerciseRole,
    String? supersetGroupId,
    int? supersetOrder,
    String? notes,
    int? restBetweenExercisesSeconds,
  }) {
    return WorkoutBuilderExerciseDraft(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      sortOrder: sortOrder ?? this.sortOrder,
      sets: sets ?? this.sets,
      exerciseRole: exerciseRole ?? this.exerciseRole,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      supersetOrder: supersetOrder ?? this.supersetOrder,
      notes: notes ?? this.notes,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    );
  }
}
