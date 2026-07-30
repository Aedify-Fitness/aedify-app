import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgrammeDayCard extends StatelessWidget {
  const ProgrammeDayCard({super.key, required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day.isRestDay) return _RestDayCell(day: day);
    return _WorkoutDayCell(day: day, onTap: onTap);
  }
}

class _RestDayCell extends StatelessWidget {
  const _RestDayCell({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: ValueKey('programme_day_rest_${day.scheduledDayIndex}'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: context.colorScheme.outlineVariant,
          strokeWidth: AppSizing.hairlineStrokeWidth,
          dashWidth: AppSpacing.sm,
          gapWidth: AppSpacing.sm,
          borderRadius: AppRadius.lg,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          color: context.colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              _DayIcon(
                asset: SolidSvgAssets.meditation,
                backgroundColor: context.colorScheme.surfaceContainerHigh,
                foregroundColor: context.colorScheme.onSurfaceVariant,
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          day.dayLabel,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _DayBadge(
                          label: AppStrings.rest,
                          backgroundColor:
                              context.colorScheme.surfaceContainerHigh,
                          foregroundColor: context.colorScheme.onSurfaceVariant,
                        ),
                        if (day.isToday)
                          _DayBadge(
                            key: ValueKey(
                              'programme_day_today_badge_${day.scheduledDayIndex}',
                            ),
                            label: AppStrings.today,
                            backgroundColor:
                                context.colorScheme.secondaryContainer,
                            foregroundColor:
                                context.colorScheme.onSecondaryContainer,
                          ),
                      ],
                    ),
                    AppWhiteSpace.hXs,
                    Text(
                      day.title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDayCell extends StatelessWidget {
  const _WorkoutDayCell({required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSkipped = day.status == ProgramWorkoutStatus.skipped;
    final isStarted = day.status == ProgramWorkoutStatus.started;
    final backgroundColor = day.isToday
        ? context.colorScheme.surfaceContainerLowest
        : context.colorScheme.surfaceContainerLow;

    return Semantics(
      button: onTap != null,
      child: Material(
        key: ValueKey('programme_day_workout_${day.scheduledDayIndex}'),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: day.isToday
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
            width: day.isToday
                ? AppSizing.strokeWidth
                : AppSizing.hairlineStrokeWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayIcon(
                  asset: day.isCompleted
                      ? SolidSvgAssets.checkCircle
                      : isSkipped
                      ? OutlinedSvgAssets.noSymbol
                      : SolidSvgAssets.dumbbell,
                  backgroundColor: day.isToday
                      ? context.colorScheme.secondaryContainer
                      : context.colorScheme.surfaceContainerHigh,
                  foregroundColor: day.isToday
                      ? context.colorScheme.secondary
                      : context.colorScheme.onSurfaceVariant,
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            day.dayLabel,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: day.isToday
                                  ? context.colorScheme.secondary
                                  : context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (day.isToday)
                            _DayBadge(
                              key: ValueKey(
                                'programme_day_today_badge_${day.scheduledDayIndex}',
                              ),
                              label: AppStrings.today,
                              backgroundColor:
                                  context.colorScheme.secondaryContainer,
                              foregroundColor:
                                  context.colorScheme.onSecondaryContainer,
                            ),
                          if (day.isCompleted)
                            _DayBadge(
                              key: ValueKey(
                                'programme_day_completed_badge_${day.scheduledDayIndex}',
                              ),
                              label: AppStrings.completed,
                              backgroundColor:
                                  context.colorScheme.secondaryContainer,
                              foregroundColor:
                                  context.colorScheme.onSecondaryContainer,
                            )
                          else if (isSkipped)
                            _DayBadge(
                              key: ValueKey(
                                'programme_day_skipped_badge_${day.scheduledDayIndex}',
                              ),
                              label: AppStrings.skipped,
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHighest,
                              foregroundColor:
                                  context.colorScheme.onSurfaceVariant,
                            )
                          else if (isStarted)
                            _DayBadge(
                              label: AppStrings.inProgressLabel,
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHighest,
                              foregroundColor: context.colorScheme.onSurface,
                            ),
                        ],
                      ),
                      AppWhiteSpace.hXs,
                      Text(
                        day.title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppWhiteSpace.hSm,
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _DayMeta(
                            asset: OutlinedSvgAssets.listBullet,
                            label:
                                '${day.exerciseCount} ${AppStrings.movements}',
                          ),
                          if (day.durationMinutes > 0)
                            _DayMeta(
                              asset: OutlinedSvgAssets.clock,
                              label:
                                  '${day.durationMinutes}${AppStrings.durationMinutesAbbreviation}',
                            ),
                        ],
                      ),
                      if (day.isToday && day.exercisePreview.isNotEmpty) ...[
                        AppWhiteSpace.hMd,
                        for (final name in day.exercisePreview.take(2))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: _ExercisePreview(name: name),
                          ),
                      ],
                    ],
                  ),
                ),
                AppWhiteSpace.wSm,
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: SvgPicture.asset(
                    day.isCompleted
                        ? SolidSvgAssets.checkCircle
                        : OutlinedSvgAssets.chevronRight,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      day.isCompleted
                          ? context.colorScheme.secondary
                          : context.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: AppRadius.full,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}

class _DayIcon extends StatelessWidget {
  const _DayIcon({
    required this.asset,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String asset;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconXxl,
      height: AppSizing.iconXxl,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: SvgPicture.asset(
        asset,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
      ),
    );
  }
}

class _DayMeta extends StatelessWidget {
  const _DayMeta({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: AppSizing.iconXs,
          height: AppSizing.iconXs,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wXs,
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ExercisePreview extends StatelessWidget {
  const _ExercisePreview({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Container(
            width: AppSpacing.xs,
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: context.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        AppWhiteSpace.wSm,
        Expanded(
          child: Text(
            name,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
