import 'set_log_draft.dart';

class WorkoutSessionExerciseDraft {
  const WorkoutSessionExerciseDraft({
    required this.id,
    required this.exerciseId,
    required this.exerciseNameSnapshot,
    required this.sortOrder,
    required this.setLogs,
    this.sourceProgramExerciseId,
    this.sourceSavedWorkoutExerciseId,
    this.supersetGroupId,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final String exerciseNameSnapshot;
  final int sortOrder;
  final List<SetLogDraft> setLogs;
  final String? sourceProgramExerciseId;
  final String? sourceSavedWorkoutExerciseId;
  final String? supersetGroupId;
  final String? notes;
}
