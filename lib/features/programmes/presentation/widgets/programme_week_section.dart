import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/pattern_deload_painter.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_day_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

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
    if (isCurrentWeek && isExpanded) {
      return _CurrentWeekSection(
        week: week,
        onToggle: onToggle,
        onDayTap: onDayTap,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(10),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (week.isDeload)
            Positioned.fill(
              child: CustomPaint(
                painter: PatternDeloadPainter(
                  color: context.colorScheme.outlineVariant.withAlpha(30),
                ),
              ),
            ),
          Column(
            children: [
              _WeekHeader(
                week: week,
                isExpanded: isExpanded,
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

class _CurrentWeekSection extends StatelessWidget {
  const _CurrentWeekSection({
    required this.week,
    required this.onToggle,
    this.onDayTap,
  });

  final WeekViewData week;
  final VoidCallback onToggle;
  final void Function(DayViewData day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colorScheme.secondary.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withAlpha(15),
            blurRadius: AppSpacing.xl,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
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
              _WeekHeader(week: week, isExpanded: true, onToggle: onToggle),
              if (week.name != null && week.name!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    week.name!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
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
    required this.onToggle,
  });

  final WeekViewData week;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _WeekStatusIcon(week: week),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Week ${week.weekNumber}',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: week.isPastWeek
                              ? context.colorScheme.onSurface.withAlpha(153)
                              : context.colorScheme.onSurface,
                        ),
                      ),
                      if (week.isDeload) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            AppStrings.weekDeload.toUpperCase(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              isExpanded
                  ? OutlinedSvgAssets.chevronUp
                  : OutlinedSvgAssets.chevronDown,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.outline,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStatusIcon extends StatelessWidget {
  const _WeekStatusIcon({required this.week});

  final WeekViewData week;

  @override
  Widget build(BuildContext context) {
    if (week.isPastWeek) {
      return SvgPicture.asset(
        SolidSvgAssets.checkCircle,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.secondary,
          BlendMode.srcIn,
        ),
      );
    }
    if (week.isDeload) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: SvgPicture.asset(
          OutlinedSvgAssets.leaf,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onPrimaryContainer,
            BlendMode.srcIn,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SvgPicture.asset(
        OutlinedSvgAssets.calendarDays,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
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
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
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
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        children: week.days.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ProgrammeDayCard(
              day: day,
              onTap: day.isRestDay ? null : () => onDayTap?.call(day),
            ),
          );
        }).toList(),
      ),
    );
  }
}
