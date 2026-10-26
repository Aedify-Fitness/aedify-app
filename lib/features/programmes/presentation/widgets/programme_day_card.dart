import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A scheduled workout or quiet recovery stop in the programme agenda.
class ProgrammeDayCard extends StatelessWidget {
  const ProgrammeDayCard({super.key, required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayRail(day: day),
        AppWhiteSpace.wSm,
        Expanded(
          child: day.isRestDay
              ? _RestDayCell(day: day)
              : _WorkoutDayCell(day: day, onTap: onTap),
        ),
      ],
    );
  }
}

class _DayRail extends StatelessWidget {
  const _DayRail({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final foreground = day.isToday || day.isCompleted
        ? accent
        : context.colorScheme.onSurfaceVariant;

    return ExcludeSemantics(
      child: SizedBox(
        width: AppProgrammeCalendarTokens.dayRailWidth,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Container(
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              shape: BoxShape.circle,
              border: day.isToday
                  ? Border.all(color: accent, width: AppSizing.strokeWidth)
                  : null,
            ),
            child: SvgPicture.asset(
              _DayPresentation.asset(day),
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestDayCell extends StatelessWidget {
  const _RestDayCell({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('programme_day_rest_${day.scheduledDayIndex}'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.controlGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeading(day: day),
          AppWhiteSpace.hXs,
          Text(
            day.title,
            style: _DayPresentation.bodyStyle(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
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
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: onTap != null,
      child: Material(
        key: ValueKey('programme_day_workout_${day.scheduledDayIndex}'),
        color: day.isToday
            ? context.colorScheme.surfaceContainer
            : context.theme.brightness == Brightness.dark
            ? context.colorScheme.surfaceContainerLow
            : context.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: day.isToday
              ? BorderSide(color: accent, width: AppSizing.hairlineStrokeWidth)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayHeading(day: day),
                AppWhiteSpace.hSm,
                Text(
                  day.title,
                  style: _DayPresentation.titleStyle(context).copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppWhiteSpace.hSm,
                Wrap(
                  spacing: AppSpacing.controlGap,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _DayMeta(
                      asset: OutlinedSvgAssets.listBullet,
                      label: '${day.exerciseCount} ${AppStrings.movements}',
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
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        name,
                        style: _DayPresentation.bodyStyle(
                          context,
                        ).copyWith(color: context.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final labelStyle = _DayPresentation.labelStyle(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          day.dayLabel,
          style: labelStyle.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (day.isToday)
          AppBadge(
            key: ValueKey('programme_day_today_badge_${day.scheduledDayIndex}'),
            label: AppStrings.today,
            backgroundColor: context.colorScheme.surfaceContainerHigh,
            foregroundColor: accent,
            textStyle: labelStyle,
            borderRadius: AppRadius.full,
          ),
        if (day.isRestDay)
          Text(
            AppStrings.rest,
            style: labelStyle.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          )
        else if (day.status != ProgramWorkoutStatus.planned)
          Text(
            _DayPresentation.status(day),
            key: ValueKey(
              'programme_day_${day.status.name}_badge_${day.scheduledDayIndex}',
            ),
            style: labelStyle.copyWith(
              color: day.isCompleted
                  ? accent
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
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
            style: _DayPresentation.labelStyle(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

abstract final class _DayPresentation {
  static String asset(DayViewData day) {
    if (day.isRestDay) return SolidSvgAssets.meditation;
    return switch (day.status) {
      ProgramWorkoutStatus.completed => SolidSvgAssets.checkCircle,
      ProgramWorkoutStatus.skipped => OutlinedSvgAssets.noSymbol,
      ProgramWorkoutStatus.started => OutlinedSvgAssets.playCircle,
      ProgramWorkoutStatus.planned => SolidSvgAssets.dumbbell,
      ProgramWorkoutStatus.replaced => OutlinedSvgAssets.arrowPath,
    };
  }

  static String status(DayViewData day) => switch (day.status) {
    ProgramWorkoutStatus.completed => AppStrings.completed,
    ProgramWorkoutStatus.skipped => AppStrings.skipped,
    ProgramWorkoutStatus.started => AppStrings.inProgressLabel,
    ProgramWorkoutStatus.planned => AppStrings.planned,
    ProgramWorkoutStatus.replaced => AppStrings.replaced,
  };

  static TextStyle titleStyle(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.bodyLg
      : AppTextStyles.bodyLg;

  static TextStyle bodyStyle(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.bodySm
      : AppTextStyles.bodySm;

  static TextStyle labelStyle(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.labelSm
      : AppTextStyles.labelSm;
}
