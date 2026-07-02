import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WeekSelectorPills extends StatelessWidget {
  const WeekSelectorPills({
    super.key,
    required this.weeks,
    required this.currentWeekNumber,
    required this.scrollController,
  });

  final List<WeekViewData> weeks;
  final int? currentWeekNumber;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxl,
      child: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: weeks.length,
            itemBuilder: (context, index) {
              final week = weeks[index];
              final isCurrent = week.weekNumber == currentWeekNumber;
              final isDeload = week.isDeload;

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? context.colorScheme.secondary
                          : context.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: isCurrent
                          ? null
                          : Border.all(
                              color: context.colorScheme.outlineVariant,
                            ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: context.colorScheme.secondary.withAlpha(
                                  38,
                                ),
                                blurRadius: AppSpacing.md,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'W${week.weekNumber}',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: isCurrent
                                ? context.colorScheme.onSecondary
                                : context.colorScheme.onSurface,
                          ),
                        ),
                        if (isDeload) ...[
                          const SizedBox(width: AppSpacing.xs),
                          SvgPicture.asset(
                            OutlinedSvgAssets.fire,
                            width: AppSizing.iconXs,
                            height: AppSizing.iconXs,
                            colorFilter: ColorFilter.mode(
                              isCurrent
                                  ? context.colorScheme.onSecondary
                                  : context.colorScheme.onPrimaryContainer,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: AppSpacing.xxl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      context.colorScheme.surface,
                      context.colorScheme.surface.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
