import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_set_row.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
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
    this.onEditSet,
    this.onTap,
  });
  final WorkoutHistoryExerciseItem item;
  final bool isInSuperset;
  final String? positionLabel;
  final ValueChanged<WorkoutHistorySetItem>? onEditSet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final logged = item.sets.where((set) => set.hasCompletedLog).length;
    return Padding(
      padding: EdgeInsets.only(
        bottom: isInSuperset ? AppSpacing.zero : AppSpacing.md,
      ),
      child: Material(
        color: context.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: AppWorkoutHistoryTokens.borderOpacity,
            ),
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('history_exercise_${item.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (positionLabel != null) ...[
                  Text(
                    positionLabel!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.secondary,
                    ),
                  ),
                  AppWhiteSpace.hSm,
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.exerciseName,
                            style: AppTextStyles.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          AppWhiteSpace.hXs,
                          Text(
                            WorkoutHistoryStrings.setCount(
                              logged,
                              item.sets.length,
                            ),
                            style: AppTextStyles.bodySm.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null) ...[
                      AppWhiteSpace.wSm,
                      const HistoryIcon(asset: OutlinedSvgAssets.chevronRight),
                    ],
                  ],
                ),
                if (item.notes?.trim().isNotEmpty ?? false) ...[
                  AppWhiteSpace.hMd,
                  Text(
                    item.notes!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (item.sets.isNotEmpty) ...[
                  AppWhiteSpace.hLg,
                  for (final entry in item.sets.indexed) ...[
                    if (entry.$1 > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.controlGap,
                        ),
                        child: Divider(
                          height: AppSizing.divider,
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: AppWorkoutHistoryTokens.borderOpacity,
                          ),
                        ),
                      ),
                    WorkoutHistorySetRow(
                      item: entry.$2,
                      onEdit: entry.$2.hasCompletedLog && onEditSet != null
                          ? () => onEditSet!(entry.$2)
                          : null,
                    ),
                  ],
                ] else ...[
                  AppWhiteSpace.hMd,
                  const Text(AppStrings.noSetsYet, style: AppTextStyles.bodySm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
