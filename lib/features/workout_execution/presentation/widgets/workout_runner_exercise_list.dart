import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_exercise_card.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class WorkoutRunnerExerciseList extends StatelessWidget {
  const WorkoutRunnerExerciseList({
    super.key,
    required this.exercises,
    required this.onUpdateSet,
    required this.onToggleSetCompleted,
    required this.onToggleSetSkipped,
  });

  final List<WorkoutRunnerExerciseItem> exercises;
  final void Function(String exerciseId, String setId, WorkoutRunnerSetItem set)
  onUpdateSet;
  final void Function(String exerciseId, String setId, bool completed)
  onToggleSetCompleted;
  final void Function(String exerciseId, String setId, bool skipped)
  onToggleSetSkipped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: WorkoutRunnerExerciseCard(
            exercise: exercise,
            onUpdateSet: (setId, set) => onUpdateSet(exercise.id, setId, set),
            onToggleSetCompleted: (setId, completed) =>
                onToggleSetCompleted(exercise.id, setId, completed),
            onToggleSetSkipped: (setId, skipped) =>
                onToggleSetSkipped(exercise.id, setId, skipped),
          ),
        );
      },
    );
  }
}
