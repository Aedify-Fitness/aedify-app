import 'package:flutter/material.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutHistoryExerciseCard extends StatelessWidget {
  const WorkoutHistoryExerciseCard({super.key, required this.item});

  final WorkoutHistoryExerciseItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.exerciseName,
                    style: context.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  item.notes!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (item.sets.isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  SizedBox(
                    width: AppSpacing.lg,
                    child: Text(
                      '#',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.historySetList,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              ...item.sets.map((set) => WorkoutHistorySetRow(item: set)),
            ],
          ],
        ),
      ),
    );
  }
}
