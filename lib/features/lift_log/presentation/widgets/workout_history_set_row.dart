import 'package:flutter/material.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_type_chip.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutHistorySetRow extends StatelessWidget {
  const WorkoutHistorySetRow({super.key, required this.item});

  final WorkoutHistorySetItem item;

  @override
  Widget build(BuildContext context) {
    final isWarmup = item.setType == SetType.warmup;
    final color = item.skipped
        ? context.colorScheme.onSurfaceVariant
        : item.completed
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.lg,
            child: Text(
              '${item.setIndex + 1}',
              style: context.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          if (isWarmup)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: SetTypeChip(setType: item.setType),
            ),
          if (item.skipped)
            Expanded(
              child: Text(
                AppStrings.skipped,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                children: [
                  if (item.actualReps != null)
                    Text(
                      '${item.actualReps} ${AppStrings.repsLabel.toLowerCase()}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  if (item.actualWeightKg != null)
                    Text(
                      '${item.actualWeightKg!.toStringAsFixed(1)} kg',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  if (item.actualRpe != null)
                    Text(
                      'RPE ${item.actualRpe!.toStringAsFixed(1)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  if (item.actualRir != null)
                    Text(
                      'RIR ${item.actualRir}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
