import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerExerciseCard extends StatelessWidget {
  const WorkoutRunnerExerciseCard({
    super.key,
    required this.exercise,
    required this.onUpdateSet,
    required this.onToggleSetCompleted,
    required this.onToggleSetSkipped,
  });

  final WorkoutRunnerExerciseItem exercise;
  final void Function(String setId, WorkoutRunnerSetItem set) onUpdateSet;
  final void Function(String setId, bool completed) onToggleSetCompleted;
  final void Function(String setId, bool skipped) onToggleSetSkipped;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.exerciseName, style: context.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            ...exercise.sets.map(
              (set) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: WorkoutRunnerSetRow(
                  set: set,
                  onChanged: (updated) => onUpdateSet(set.id, updated),
                  onToggleCompleted: (completed) =>
                      onToggleSetCompleted(set.id, completed),
                  onToggleSkipped: (skipped) =>
                      onToggleSetSkipped(set.id, skipped),
                ),
              ),
            ),
            if (exercise.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(
                  child: Text(
                    AppStrings.noSetsYet,
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
