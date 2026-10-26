import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/deload_diagonal_painter.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_day_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A weekly overview with an expandable, state-aware training agenda.
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
    return Column(
      key: ValueKey('programme_week_${week.weekNumber}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WeekHeader(
          week: week,
          isExpanded: isExpanded,
          isCurrentWeek: isCurrentWeek,
          onToggle: onToggle,
        ),
        if (week.days.isNotEmpty) ...[
          AppWhiteSpace.hMd,
          _WeekOverview(week: week, onDayTap: onDayTap),
        ],
        if (isExpanded) ...[
          AppWhiteSpace.hLg,
          _WeekExpandedContent(week: week, onDayTap: onDayTap),
        ],
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.week,
    required this.isExpanded,
    required this.isCurrentWeek,
    required this.onToggle,
  });

  final WeekViewData week;
  final bool isExpanded;
  final bool isCurrentWeek;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final labelStyle = isDark
        ? AppTextStylesDark.labelSm
        : AppTextStyles.labelSm;
    final workoutDays = week.days.where((day) => !day.isRestDay);
    final completedCount = workoutDays.where((day) => day.isCompleted).length;

    return Semantics(
      button: true,
      expanded: isExpanded,
      child: Material(
        color: week.isDeload
            ? context.colorScheme.surfaceContainerLow
            : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
            InkWell(
              key: ValueKey('programme_week_toggle_${week.weekNumber}'),
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: week.isDeload ? AppSpacing.md : AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                AppStrings.programmeWeekLabel(week.weekNumber),
                                style: AppTextStyles.headlineMd.copyWith(
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              if (isCurrentWeek)
                                AppBadge(
                                  key: ValueKey(
                                    'programme_week_current_${week.weekNumber}',
                                  ),
                                  label: AppStrings.programmeCurrentWeek,
                                  backgroundColor:
                                      context.colorScheme.surfaceContainerHigh,
                                  foregroundColor: _WeekPresentation.accent(
                                    context,
                                  ),
                                  textStyle: labelStyle,
                                  borderRadius: AppRadius.full,
                                ),
                            ],
                          ),
                          if (week.name?.trim().isNotEmpty ?? false) ...[
                            AppWhiteSpace.hXs,
                            Text(
                              week.name!,
                              style: _WeekPresentation.bodyStyle(context)
                                  .copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          if (workoutDays.isNotEmpty) ...[
                            AppWhiteSpace.hSm,
                            Text(
                              AppStrings.programmeWorkoutCompletion(
                                completedCount,
                                workoutDays.length,
                              ),
                              style: labelStyle.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (week.isDeload ||
                              week.isWeekCompleted ||
                              week.isWeekSkipped) ...[
                            AppWhiteSpace.hSm,
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                if (week.isDeload)
                                  _WeekStatus(
                                    asset: OutlinedSvgAssets.leaf,
                                    label: AppStrings.weekDeload,
                                  ),
                                if (week.isWeekCompleted)
                                  _WeekStatus(
                                    asset: SolidSvgAssets.checkCircle,
                                    label: AppStrings.completed,
                                  ),
                                if (week.isWeekSkipped)
                                  _WeekStatus(
                                    asset: OutlinedSvgAssets.noSymbol,
                                    label: AppStrings.skipped,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppWhiteSpace.wSm,
                    SizedBox(
                      width: AppProgrammeCalendarTokens.controlSize,
                      height: AppProgrammeCalendarTokens.controlSize,
                      child: Center(
                        child: SvgPicture.asset(
                          isExpanded
                              ? OutlinedSvgAssets.chevronUp
                              : OutlinedSvgAssets.chevronDown,
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          excludeFromSemantics: true,
                          colorFilter: ColorFilter.mode(
                            context.colorScheme.onSurfaceVariant,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStatus extends StatelessWidget {
  const _WeekStatus({required this.asset, required this.label});

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
          excludeFromSemantics: true,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wXs,
        Flexible(
          child: Text(
            label,
            style: _WeekPresentation.labelStyle(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _WeekOverview extends StatelessWidget {
  const _WeekOverview({required this.week, this.onDayTap});

  final WeekViewData week;
  final void Function(DayViewData day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final useLargeDayLabels =
        MediaQuery.textScalerOf(context).scale(AppFontSizes.xs) >
        AppFontSizes.md;

    return Container(
      key: ValueKey('programme_week_overview_${week.weekNumber}'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.controlGap,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minimumWidth = useLargeDayLabels
              ? AppSizing.fieldWidthSm
              : AppProgrammeCalendarTokens.controlSize;
          final availableDayWidth = constraints.maxWidth / week.days.length;
          final dayWidth = availableDayWidth > minimumWidth
              ? availableDayWidth
              : minimumWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final day in week.days)
                  SizedBox(
                    width: dayWidth,
                    child: _DayOverview(
                      day: day,
                      onTap: day.isRestDay || onDayTap == null
                          ? null
                          : () => onDayTap!(day),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayOverview extends StatelessWidget {
  const _DayOverview({required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _WeekPresentation.accent(context);
    final status = day.isRestDay
        ? AppStrings.rest
        : switch (day.status) {
            ProgramWorkoutStatus.completed => AppStrings.completed,
            ProgramWorkoutStatus.skipped => AppStrings.skipped,
            ProgramWorkoutStatus.started => AppStrings.inProgressLabel,
            ProgramWorkoutStatus.planned => AppStrings.planned,
            ProgramWorkoutStatus.replaced => AppStrings.replaced,
          };
    final asset = day.isRestDay
        ? SolidSvgAssets.meditation
        : switch (day.status) {
            ProgramWorkoutStatus.completed => SolidSvgAssets.checkCircle,
            ProgramWorkoutStatus.skipped => OutlinedSvgAssets.noSymbol,
            ProgramWorkoutStatus.started => OutlinedSvgAssets.playCircle,
            ProgramWorkoutStatus.planned => SolidSvgAssets.dumbbell,
            ProgramWorkoutStatus.replaced => OutlinedSvgAssets.arrowPath,
          };
    final foreground = day.isToday || day.isCompleted
        ? accent
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      key: ValueKey('programme_day_overview_${day.scheduledDayIndex}'),
      button: onTap != null ? true : null,
      onTap: onTap,
      label: [
        day.dayLabel,
        status,
        if (day.isToday) AppStrings.today,
      ].join(', '),
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            excludeFromSemantics: true,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppProgrammeCalendarTokens.controlSize,
                minHeight: AppProgrammeCalendarTokens.controlSize,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TrainingDay
                        .values[day.scheduledDayIndex %
                            TrainingDay.values.length]
                        .displayLabel,
                    style: _WeekPresentation.labelStyle(
                      context,
                    ).copyWith(color: foreground),
                  ),
                  AppWhiteSpace.hSm,
                  Container(
                    width: AppSpacing.xl,
                    height: AppSpacing.xl,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: day.isCompleted
                          ? context.colorScheme.surfaceContainerHigh
                          : null,
                      shape: BoxShape.circle,
                      border: day.isToday
                          ? Border.all(
                              color: accent,
                              width: AppSizing.strokeWidth,
                            )
                          : null,
                    ),
                    child: SvgPicture.asset(
                      asset,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      colorFilter: ColorFilter.mode(
                        foreground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      return Text(
        AppStrings.noWorkoutsInWeek,
        style: _WeekPresentation.bodyStyle(
          context,
        ).copyWith(color: context.colorScheme.onSurfaceVariant),
      );
    }

    return Stack(
      children: [
        PositionedDirectional(
          start: AppProgrammeCalendarTokens.dayRailWidth / 2,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
          width: AppSizing.hairlineStrokeWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.outlineVariant,
            ),
          ),
        ),
        Column(
          children: [
            for (var index = 0; index < week.days.length; index++) ...[
              ProgrammeDayCard(
                day: week.days[index],
                onTap: week.days[index].isRestDay || onDayTap == null
                    ? null
                    : () => onDayTap!(week.days[index]),
              ),
              if (index < week.days.length - 1) AppWhiteSpace.hSm,
            ],
          ],
        ),
      ],
    );
  }
}

abstract final class _WeekPresentation {
  static Color accent(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? context.colorScheme.primary
      : context.colorScheme.secondary;

  static TextStyle bodyStyle(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.bodySm
      : AppTextStyles.bodySm;

  static TextStyle labelStyle(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.labelSm
      : AppTextStyles.labelSm;
}
