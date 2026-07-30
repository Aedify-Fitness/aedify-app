import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryListTile extends StatelessWidget {
  const WorkoutHistoryListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final WorkoutHistoryListItem item;
  final VoidCallback onTap;

  String _sourceLabel() {
    return switch (item.source) {
      SessionSource.program => AppStrings.sourceProgramme,
      SessionSource.savedWorkout => AppStrings.sourceSavedWorkout,
      SessionSource.standalone => AppStrings.sourceStandalone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final sourceLabel = _sourceLabel();
    final duration = _formatDuration(item.durationSeconds);

    return Semantics(
      button: true,
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: colorScheme.surfaceContainer,
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md + AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: AppBadge(
                        label: sourceLabel,
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        borderRadius: AppRadius.full,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        textStyle: AppTextStyles.labelSm,
                      ),
                    ),
                    const Spacer(),
                    AppWhiteSpace.wSm,
                    Container(
                      width: AppSizing.iconXxl,
                      height: AppSizing.iconXxl,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        OutlinedSvgAssets.chevronRight,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                AppWhiteSpace.hMd,
                Text(
                  item.name,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppWhiteSpace.hMd,
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _HistoryMetadata(
                      iconAsset: OutlinedSvgAssets.calendarDays,
                      label: DateFormat.yMMMd().format(item.completedAt),
                    ),
                    if (duration.isNotEmpty)
                      _HistoryMetadata(
                        iconAsset: OutlinedSvgAssets.clock,
                        label: duration,
                      ),
                    _HistoryMetadata(
                      iconAsset: OutlinedSvgAssets.listBullet,
                      label:
                          '${item.exerciseCount} ${AppStrings.historyExerciseList}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '';
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours${AppStrings.durationHoursAbbreviation} '
          '$remainingMinutes${AppStrings.durationMinutesAbbreviation}';
    }
    return '$minutes${AppStrings.durationMinutesAbbreviation}';
  }
}

class _HistoryMetadata extends StatelessWidget {
  const _HistoryMetadata({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizing.iconS,
          height: AppSizing.iconS,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        AppWhiteSpace.wXs,
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
