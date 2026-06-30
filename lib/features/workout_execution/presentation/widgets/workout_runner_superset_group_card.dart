import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutRunnerSupersetGroupCard extends StatelessWidget {
  const WorkoutRunnerSupersetGroupCard({
    super.key,
    required this.group,
    required this.exercises,
    required this.onUpdateSet,
    required this.onToggleSetCompleted,
    required this.onToggleSetSkipped,
  });

  final SupersetGroupSummary group;
  final List<WorkoutRunnerExerciseItem> exercises;
  final void Function(String exerciseId, String setId, WorkoutRunnerSetItem set)
  onUpdateSet;
  final void Function(String exerciseId, String setId, bool completed)
  onToggleSetCompleted;
  final void Function(String exerciseId, String setId, bool skipped)
  onToggleSetSkipped;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                  ),
                  child: Text(
                    AppStrings.supersetGroup,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    AppStrings.supersetRunnerHint,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...exercises.map(
              (exercise) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.exerciseName, style: AppTextStyles.bodyMd),
                  const SizedBox(height: AppSpacing.xs),
                  ...exercise.sets.map(
                    (set) => WorkoutRunnerSetRow(
                      set: set,
                      onChanged: (s) => onUpdateSet(exercise.id, s.id, s),
                      onToggleCompleted: (v) =>
                          onToggleSetCompleted(exercise.id, set.id, v),
                      onToggleSkipped: (v) =>
                          onToggleSetSkipped(exercise.id, set.id, v),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
