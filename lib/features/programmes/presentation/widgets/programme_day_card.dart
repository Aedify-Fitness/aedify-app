import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';

class ProgrammeDayCard extends StatelessWidget {
  const ProgrammeDayCard({super.key, required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day.isRestDay) return _RestDayCard(day: day);
    if (day.isToday) return _TodayCard(day: day, onTap: onTap);
    return _WorkoutDayCard(day: day, onTap: onTap);
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard({required this.day});

  final DayViewData day;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: cs.outlineVariant,
          strokeWidth: AppSizing.hairlineStrokeWidth,
          dashWidth: 6,
          gapWidth: 6,
          borderRadius: AppRadius.xl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: cs.surface,
          child: Column(
            children: [
              SvgPicture.asset(
                SolidSvgAssets.meditation,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(cs.outline, BlendMode.srcIn),
              ),
              AppWhiteSpace.hXs,
              Text(
                day.dayLabel.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppWhiteSpace.hXxs,
              Text(
                day.title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontSize: AppFontSizes.xxl,
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.day, this.onTap});

  final DayViewData day;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colorScheme.secondary,
          width: AppSizing.strokeWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withAlpha(25),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayHeader(day: day, isCompleted: day.isCompleted),
              AppWhiteSpace.hSm,
              if (day.exercisePreview.isNotEmpty) ...[
                ...day.exercisePreview
                    .take(3)
                    .map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\u2022 ',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
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
                AppWhiteSpace.hSm,
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const SizedBox.shrink(),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.viewDetails),
                      AppWhiteSpace.wXxs,
                      SvgPicture.asset(
                        OutlinedSvgAssets.chevronRight,
                        width: AppSizing.iconXxs,
                        height: AppSizing.iconXxs,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.surfaceContainerHigh,
                    foregroundColor: context.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -12,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withAlpha(38),
                    blurRadius: AppSpacing.xs,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                AppStrings.today,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSecondary,
                ),
              ),
            ),
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
    final isCompleted = day.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isCompleted ? 0.80 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isCompleted
                ? context.colorScheme.surfaceContainerLow
                : context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withAlpha(51),
              width: AppSizing.hairlineStrokeWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayHeader(day: day, isCompleted: isCompleted),
              AppWhiteSpace.hSm,
              Row(
                children: [
                  _MetaChip(text: '${day.exerciseCount} Exercises'),
                  if (day.durationMinutes > 0) ...[
                    AppWhiteSpace.wSm,
                    _MetaChip(text: '${day.durationMinutes}m'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.isCompleted});

  final DayViewData day;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;

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
              AppWhiteSpace.hXxs,
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
          const SizedBox(width: AppSizing.iconMd, height: AppSizing.iconMd)
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
