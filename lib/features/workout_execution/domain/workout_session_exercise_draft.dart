import 'package:aedify/shared/domain/exercise_logging_type.dart';
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
    this.restBetweenExercisesSeconds,
    this.notes,
    this.loggingType,
  });

  final String id;
  final int exerciseId;
  final String exerciseNameSnapshot;
  final int sortOrder;
  final List<SetLogDraft> setLogs;
  final String? sourceProgramExerciseId;
  final String? sourceSavedWorkoutExerciseId;
  final String? supersetGroupId;
  final int? restBetweenExercisesSeconds;
  final String? notes;
  final ExerciseLoggingType? loggingType;
}
