import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';

class WorkoutRunnerExerciseItem {
  const WorkoutRunnerExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
    required this.sets,
    this.supersetGroupId,
    this.supersetOrder,
    this.sourceProgramExerciseId,
    this.sourceSavedWorkoutExerciseId,
    this.notes,
    this.loggingType,
    this.restBetweenExercisesSeconds,
  });

  final String id;
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;
  final List<WorkoutRunnerSetItem> sets;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? sourceProgramExerciseId;
  final String? sourceSavedWorkoutExerciseId;
  final String? notes;
  final ExerciseLoggingType? loggingType;
  final int? restBetweenExercisesSeconds;

  bool get isCompleted =>
      sets.isNotEmpty && sets.every((set) => set.completed && !set.skipped);

  bool get canCorrectLogs => sets.any(
    (set) => WorkoutRunnerSetPolicy.hasCompletedLog(
      set,
      loggingType: set.exerciseId == exerciseId ? loggingType : null,
    ),
  );

  WorkoutRunnerExerciseItem copyWith({
    String? id,
    int? exerciseId,
    String? exerciseName,
    int? sortOrder,
    List<WorkoutRunnerSetItem>? sets,
    String? supersetGroupId,
    int? supersetOrder,
    String? sourceProgramExerciseId,
    String? sourceSavedWorkoutExerciseId,
    String? notes,
    ExerciseLoggingType? loggingType,
    int? restBetweenExercisesSeconds,
  }) {
    return WorkoutRunnerExerciseItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sortOrder: sortOrder ?? this.sortOrder,
      sets: sets ?? this.sets,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      supersetOrder: supersetOrder ?? this.supersetOrder,
      sourceProgramExerciseId:
          sourceProgramExerciseId ?? this.sourceProgramExerciseId,
      sourceSavedWorkoutExerciseId:
          sourceSavedWorkoutExerciseId ?? this.sourceSavedWorkoutExerciseId,
      notes: notes ?? this.notes,
      loggingType: loggingType ?? this.loggingType,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    );
  }
}
