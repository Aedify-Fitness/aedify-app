import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';

class WorkoutRunnerExerciseItem {
  const WorkoutRunnerExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
    required this.sets,
    this.supersetGroupId,
    this.sourceProgramExerciseId,
    this.sourceSavedWorkoutExerciseId,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;
  final List<WorkoutRunnerSetItem> sets;
  final String? supersetGroupId;
  final String? sourceProgramExerciseId;
  final String? sourceSavedWorkoutExerciseId;
  final String? notes;

  WorkoutRunnerExerciseItem copyWith({
    String? id,
    int? exerciseId,
    String? exerciseName,
    int? sortOrder,
    List<WorkoutRunnerSetItem>? sets,
    String? supersetGroupId,
    String? sourceProgramExerciseId,
    String? sourceSavedWorkoutExerciseId,
    String? notes,
  }) {
    return WorkoutRunnerExerciseItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sortOrder: sortOrder ?? this.sortOrder,
      sets: sets ?? this.sets,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      sourceProgramExerciseId:
          sourceProgramExerciseId ?? this.sourceProgramExerciseId,
      sourceSavedWorkoutExerciseId:
          sourceSavedWorkoutExerciseId ?? this.sourceSavedWorkoutExerciseId,
      notes: notes ?? this.notes,
    );
  }
}
