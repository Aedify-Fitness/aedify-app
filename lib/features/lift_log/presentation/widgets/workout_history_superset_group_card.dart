import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border(
          left: BorderSide(
            color: context.colorScheme.secondary,
            width: AppSpacing.xs,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppBadge(
                  label: AppStrings.supersetHistoryLabel,
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  borderRadius: AppRadius.full,
                  fontWeight: FontWeight.w700,
                ),
                Text(
                  '${group.memberCount} ${AppStrings.exercisesLabel}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hXs,
            Text(
              AppStrings.supersetRunnerHint,
              style: AppTextStyles.bodySm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            AppWhiteSpace.hMd,
            for (var index = 0; index < exercises.length; index++) ...[
              WorkoutHistoryExerciseCard(
                item: exercises[index],
                isInSuperset: true,
                positionLabel: AppStrings.exerciseNumberLabel(index + 1),
              ),
              if (index < exercises.length - 1) AppWhiteSpace.hSm,
            ],
          ],
        ),
      ),
    );
  }
}
