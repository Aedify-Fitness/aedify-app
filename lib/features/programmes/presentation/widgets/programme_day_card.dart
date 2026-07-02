import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeDayCard extends StatelessWidget {
  const ProgrammeDayCard({super.key, required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day.isRestDay) return _RestDayCard(day: day);
    return _WorkoutDayCard(day: day, onTap: onTap);
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.moon,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.outline,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            day.dayLabel,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            day.title,
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  const _WorkoutDayCard({required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;
    final isCompleted = day.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isToday
              ? context.colorScheme.surfaceContainerLowest
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isToday
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant.withAlpha(77),
            width: isToday ? AppSizing.strokeWidth : 1.0,
          ),
        ),
        child: Opacity(
          opacity: isCompleted ? 0.80 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayHeader(day: day, isToday: isToday, isCompleted: isCompleted),
              const SizedBox(height: AppSpacing.md),
              if (day.exercisePreview.isNotEmpty) ...[
                ...day.exercisePreview.map(
                  (name) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u2022',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              _DayFooter(day: day),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.isCompleted,
  });

  final DayViewData day;
  final bool isToday;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day.dayLabel.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? context.colorScheme.secondary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                day.title,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (isCompleted)
          SvgPicture.asset(
            SolidSvgAssets.checkCircle,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(
              context.colorScheme.secondary,
              BlendMode.srcIn,
            ),
          )
        else if (isToday)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _TodayBadge(),
              const SizedBox(width: AppSpacing.sm),
              SvgPicture.asset(
                OutlinedSvgAssets.chevronRight,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          )
        else
          SvgPicture.asset(
            OutlinedSvgAssets.chevronRight,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              context.colorScheme.outline,
              BlendMode.srcIn,
            ),
          ),
      ],
    );
  }
}

class _DayFooter extends StatelessWidget {
  const _DayFooter({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaChip(text: '${day.exerciseCount} Exercises'),
        const SizedBox(width: AppSpacing.sm),
        if (day.durationMinutes > 0) _MetaChip(text: '${day.durationMinutes}m'),
      ],
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        AppStrings.today,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
