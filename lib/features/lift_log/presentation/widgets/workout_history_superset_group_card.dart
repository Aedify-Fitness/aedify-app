import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutHistorySupersetGroupCard extends StatelessWidget {
  const WorkoutHistorySupersetGroupCard({
    super.key,
    required this.group,
    required this.exercises,
  });

  final SupersetGroupSummary group;
  final List<WorkoutHistoryExerciseItem> exercises;

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
                    AppStrings.supersetHistoryLabel,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hSm,
            ...exercises.map(
              (exercise) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.exerciseName, style: AppTextStyles.bodyMd),
                  AppWhiteSpace.hXs,
                  ...exercise.sets.map(
                    (set) => WorkoutHistorySetRow(item: set),
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
