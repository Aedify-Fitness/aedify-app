import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_set_row.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutHistoryExerciseCard extends StatelessWidget {
  const WorkoutHistoryExerciseCard({
    super.key,
    required this.item,
    this.isInSuperset = false,
    this.positionLabel,
  });

  final WorkoutHistoryExerciseItem item;
  final bool isInSuperset;
  final String? positionLabel;

  @override
  Widget build(BuildContext context) {
    final completedSets = item.sets.where((set) => set.completed).length;

    return Container(
      margin: isInSuperset
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isInSuperset
            ? context.colorScheme.surfaceContainerLowest
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (positionLabel != null) ...[
              Text(
                positionLabel!,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppWhiteSpace.hXs,
            ],
            Text(
              item.exerciseName,
              style: AppTextStyles.bodyLg.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (item.sets.isNotEmpty) ...[
              AppWhiteSpace.hSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppBadge(
                    label: _statusLabel(),
                    backgroundColor: _statusBackground(context),
                    foregroundColor: _statusForeground(context),
                    borderRadius: AppRadius.full,
                  ),
                  Text(
                    '$completedSets/${item.sets.length} '
                    '${AppStrings.setsLabel}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              AppWhiteSpace.hMd,
              Text(
                AppStrings.notes,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hXs,
              Text(
                item.notes!,
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
            if (item.sets.isNotEmpty) ...[
              AppWhiteSpace.hLg,
              const AppSectionHeader(title: AppStrings.historySetList),
              AppWhiteSpace.hSm,
              ...item.sets.map(
                (set) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: WorkoutHistorySetRow(item: set),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    if (item.sets.any((set) => !set.completed && !set.skipped)) {
      return AppStrings.inProgressLabel;
    }
    if (item.sets.every((set) => set.skipped)) return AppStrings.skipped;
    return AppStrings.completed;
  }

  Color _statusBackground(BuildContext context) {
    if (item.sets.any((set) => !set.completed && !set.skipped)) {
      return context.colorScheme.tertiaryContainer;
    }
    if (item.sets.every((set) => set.skipped)) {
      return context.colorScheme.surfaceContainerHighest;
    }
    return context.colorScheme.secondaryContainer;
  }

  Color _statusForeground(BuildContext context) {
    if (item.sets.any((set) => !set.completed && !set.skipped)) {
      return context.colorScheme.onTertiaryContainer;
    }
    if (item.sets.every((set) => set.skipped)) {
      return context.colorScheme.onSurfaceVariant;
    }
    return context.colorScheme.onSecondaryContainer;
  }
}
