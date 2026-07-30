import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/deload_diagonal_painter.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_day_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgrammeWeekSection extends StatelessWidget {
  const ProgrammeWeekSection({
    super.key,
    required this.week,
    required this.isExpanded,
    required this.isCurrentWeek,
    required this.onToggle,
    this.onDayTap,
  });

  final WeekViewData week;
  final bool isExpanded;
  final bool isCurrentWeek;
  final VoidCallback onToggle;
  final void Function(DayViewData day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final workoutDays = week.days.where((day) => !day.isRestDay).toList();
    final completedWorkoutCount = workoutDays
        .where((day) => day.isCompleted)
        .length;

    return Container(
      key: ValueKey('programme_week_${week.weekNumber}'),
      decoration: BoxDecoration(
        color: week.isDeload
            ? context.colorScheme.surfaceContainerLow
            : context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isCurrentWeek
              ? context.colorScheme.secondary
              : context.colorScheme.outlineVariant,
          width: isCurrentWeek
              ? AppSizing.strokeWidth
              : AppSizing.hairlineStrokeWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (week.isDeload)
            Positioned.fill(
              key: ValueKey('programme_week_deload_${week.weekNumber}'),
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DeloadDiagonalPainter(
                    color: context.colorScheme.outlineVariant.withAlpha(76),
                  ),
                ),
              ),
            ),
          if (isCurrentWeek)
            Positioned(
              key: ValueKey('programme_week_current_${week.weekNumber}'),
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: AppSizing.activeIndicatorHeight,
                color: context.colorScheme.secondary,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeekHeader(
                week: week,
                isExpanded: isExpanded,
                isCurrentWeek: isCurrentWeek,
                completedWorkoutCount: completedWorkoutCount,
                workoutCount: workoutDays.length,
                onToggle: onToggle,
              ),
              if (isExpanded)
                _WeekExpandedContent(week: week, onDayTap: onDayTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.week,
    required this.isExpanded,
    required this.isCurrentWeek,
    required this.completedWorkoutCount,
    required this.workoutCount,
    required this.onToggle,
  });

  final WeekViewData week;
  final bool isExpanded;
  final bool isCurrentWeek;
  final int completedWorkoutCount;
  final int workoutCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: isExpanded,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('programme_week_toggle_${week.weekNumber}'),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WeekStatusIcon(week: week, isCurrentWeek: isCurrentWeek),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.weekLabelPrefix} ${week.weekNumber}',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (week.name != null && week.name!.isNotEmpty) ...[
                        AppWhiteSpace.hXxs,
                        Text(
                          week.name!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      AppWhiteSpace.hSm,
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (isCurrentWeek)
                            _WeekBadge(
                              label: AppStrings.today,
                              backgroundColor:
                                  context.colorScheme.secondaryContainer,
                              foregroundColor:
                                  context.colorScheme.onSecondaryContainer,
                            ),
                          if (week.isWeekCompleted)
                            _WeekBadge(
                              label: AppStrings.completed,
                              backgroundColor:
                                  context.colorScheme.secondaryContainer,
                              foregroundColor:
                                  context.colorScheme.onSecondaryContainer,
                            ),
                          if (week.isWeekSkipped)
                            _WeekBadge(
                              label: AppStrings.skipped,
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHighest,
                              foregroundColor:
                                  context.colorScheme.onSurfaceVariant,
                            ),
                          if (week.isDeload)
                            _WeekBadge(
                              label: AppStrings.weekDeload,
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHighest,
                              foregroundColor: context.colorScheme.onSurface,
                            ),
                          if (workoutCount > 0)
                            _WeekBadge(
                              label:
                                  '$completedWorkoutCount/$workoutCount ${AppStrings.completed}',
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHigh,
                              foregroundColor:
                                  context.colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppWhiteSpace.wSm,
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: SvgPicture.asset(
                    isExpanded
                        ? OutlinedSvgAssets.chevronUp
                        : OutlinedSvgAssets.chevronDown,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurfaceVariant,
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

class _WeekBadge extends StatelessWidget {
  const _WeekBadge({
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

class _WeekStatusIcon extends StatelessWidget {
  const _WeekStatusIcon({required this.week, required this.isCurrentWeek});

  final WeekViewData week;
  final bool isCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final asset = week.isWeekCompleted
        ? SolidSvgAssets.checkCircle
        : week.isWeekSkipped
        ? OutlinedSvgAssets.noSymbol
        : week.isDeload
        ? OutlinedSvgAssets.leaf
        : OutlinedSvgAssets.calendarDays;
    final foregroundColor = isCurrentWeek
        ? context.colorScheme.secondary
        : context.colorScheme.onSurfaceVariant;

    return Container(
      width: AppSizing.iconXxl,
      height: AppSizing.iconXxl,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCurrentWeek
            ? context.colorScheme.secondaryContainer
            : context.colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        asset,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
      ),
    );
  }
}

class _WeekExpandedContent extends StatelessWidget {
  const _WeekExpandedContent({required this.week, this.onDayTap});

  final WeekViewData week;
  final void Function(DayViewData day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    if (week.days.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Text(
          AppStrings.noWorkoutsInWeek,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        children: [
          for (var index = 0; index < week.days.length; index++) ...[
            ProgrammeDayCard(
              day: week.days[index],
              onTap: week.days[index].isRestDay
                  ? null
                  : () => onDayTap?.call(week.days[index]),
            ),
            if (index < week.days.length - 1) AppWhiteSpace.hSm,
          ],
        ],
      ),
    );
  }
}
