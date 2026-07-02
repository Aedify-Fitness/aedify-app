import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeCalendarHeader extends StatelessWidget {
  const ProgrammeCalendarHeader({
    super.key,
    required this.viewData,
    required this.onStartTodayWorkout,
  });

  final ProgrammeCalendarViewData viewData;
  final VoidCallback? onStartTodayWorkout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewData.blockType != null && viewData.blockType!.isNotEmpty) ...[
            _PhaseBadge(blockType: viewData.blockType!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(viewData.name, style: context.textTheme.headlineSmall),
          if (viewData.description != null &&
              viewData.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              viewData.description!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: viewData.todayWorkoutId != null
                      ? onStartTodayWorkout
                      : null,
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.playCircle,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      viewData.todayWorkoutId != null
                          ? context.colorScheme.onSecondary
                          : context.colorScheme.onSecondary.withAlpha(128),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(AppStrings.startTodaysWorkout),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.blockType});

  final String blockType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '${AppStrings.currentPhase}: $blockType',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondaryFixedVariant,
        ),
      ),
    );
  }
}
