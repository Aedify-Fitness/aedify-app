import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
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
    this.onEditSet,
  });
  final SupersetGroupSummary group;
  final List<WorkoutHistoryExerciseItem> exercises;
  final ValueChanged<WorkoutHistorySetItem>? onEditSet;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('history_superset_${group.groupId}'),
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.controlGap,
          ),
          child: Row(
            children: [
              HistoryIcon(
                asset: OutlinedSvgAssets.link,
                color: context.colorScheme.secondary,
              ),
              AppWhiteSpace.wSm,
              Expanded(
                child: Text(
                  AppStrings.supersetHistoryLabel,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              AppWhiteSpace.wSm,
              Flexible(
                child: Text(
                  WorkoutHistoryStrings.exerciseCount(group.memberCount),
                  textAlign: TextAlign.end,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final entry in exercises.indexed) ...[
          if (entry.$1 > 0) AppWhiteSpace.hSm,
          WorkoutHistoryExerciseCard(
            item: entry.$2,
            isInSuperset: true,
            positionLabel: AppStrings.exerciseNumberLabel(entry.$1 + 1),
            onEditSet: onEditSet,
          ),
        ],
      ],
    ),
  );
}
