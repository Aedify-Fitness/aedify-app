import 'dart:ui';

import 'package:aedify/features/workout_execution/presentation/widgets/workout_duration_timer.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Fixed glass header for the active workout runner.
class WorkoutRunnerHeader extends StatelessWidget {
  const WorkoutRunnerHeader({
    super.key,
    required this.workoutTitle,
    required this.exerciseTitle,
    required this.workoutStartedAt,
    required this.isPaused,
    required this.onClose,
    required this.onSubstitute,
    this.showSubstitute = true,
    this.pausedDurationSeconds,
  });

  final String workoutTitle;
  final String exerciseTitle;
  final DateTime workoutStartedAt;
  final bool isPaused;
  final VoidCallback onClose;

  /// Opens the substitute picker. Null while paused, matching the disabled
  /// training-log treatment.
  final VoidCallback? onSubstitute;
  final bool showSubstitute;
  final int? pausedDurationSeconds;

  /// Scroll clearance follows the same scaled type used by the fixed header.
  static double extentFor(BuildContext context, {bool showSubstitute = true}) {
    final scaler = MediaQuery.textScalerOf(context);
    final stacked = _stacksTimer(context);
    if (showSubstitute && !stacked) {
      return AppWorkoutRunnerTokens.headerExtentFor(context);
    }
    final label = showSubstitute
        ? AppTextStyles.labelMd
        : AppTextStyles.labelSm;
    final labelHeight = scaler.scale(label.fontSize!) * label.height!;
    final titleHeight =
        scaler.scale(AppTextStyles.bodyLg.fontSize!) *
        AppTextStyles.bodyLg.height!;
    final substituteHeight = showSubstitute
        ? AppSpacing.sm +
              scaler.scale(AppTextStyles.labelSm.fontSize!) *
                  AppTextStyles.labelSm.height! +
              (AppSpacing.xs * 2) +
              (AppSizing.divider * 2)
        : 0;
    final titlesHeight =
        labelHeight + AppSpacing.xxs + titleHeight + substituteHeight;
    final verticalPadding = showSubstitute ? AppSpacing.md : AppSpacing.lg;
    final timerHeight =
        scaler.scale(AppTextStyles.bodyMd.fontSize!) *
            AppTextStyles.bodyMd.height! +
        (AppSpacing.sm * 2) +
        (AppSizing.divider * 2);
    final extent =
        (verticalPadding * 2) +
        titlesHeight.clamp(AppSizing.iconXxl, double.infinity) +
        (stacked ? AppSpacing.sm + timerHeight : 0);
    return extent.ceilToDouble().clamp(
      showSubstitute
          ? AppWorkoutRunnerTokens.headerExtent
          : AppWorkoutRunnerTokens.supersetHeaderExtent,
      double.infinity,
    );
  }

  static bool _stacksTimer(BuildContext context) =>
      MediaQuery.sizeOf(context).width <
          AppWorkoutRunnerTokens.stackedHeaderBreakpoint &&
      MediaQuery.textScalerOf(context).scale(AppFontSizes.lg) >
          AppFontSizes.lg * AppWorkoutRunnerTokens.largeTextBreakpoint;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final stacked = _stacksTimer(context);
    final timerWidget = WorkoutDurationTimer(
      startedAt: workoutStartedAt,
      isPaused: isPaused,
      pausedDurationSeconds: pausedDurationSeconds,
    );

    return ClipRect(
      key: const ValueKey<String>('workout_runner_header'),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppWorkoutRunnerTokens.glassBlurSigma,
          sigmaY: AppWorkoutRunnerTokens.glassBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withValues(
              alpha: AppWorkoutRunnerTokens.headerSurfaceOpacity,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppWorkoutRunnerTokens.horizontalPadding,
              top: topInset + (showSubstitute ? AppSpacing.md : AppSpacing.lg),
              right: AppWorkoutRunnerTokens.horizontalPadding,
              bottom: showSubstitute ? AppSpacing.md : AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AppIconButton(
                      key: const ValueKey<String>(
                        'workout_runner_close_button',
                      ),
                      asset: OutlinedSvgAssets.materialClose,
                      onPressed: onClose,
                      semanticLabel: AppStrings.exitWorkout,
                      color: context.colorScheme.onSurface,
                    ),
                    AppWhiteSpace.wMd,
                    Expanded(
                      child: _HeaderTitles(
                        workoutTitle: workoutTitle,
                        exerciseTitle: exerciseTitle,
                        showSubstitute: showSubstitute,
                        onSubstitute: onSubstitute,
                      ),
                    ),
                    if (!stacked) ...[AppWhiteSpace.wSm, timerWidget],
                  ],
                ),
                if (stacked) ...[
                  AppWhiteSpace.hSm,
                  Align(alignment: Alignment.centerRight, child: timerWidget),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTitles extends StatelessWidget {
  const _HeaderTitles({
    required this.workoutTitle,
    required this.exerciseTitle,
    required this.showSubstitute,
    required this.onSubstitute,
  });

  final String workoutTitle;
  final String exerciseTitle;
  final bool showSubstitute;
  final VoidCallback? onSubstitute;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        workoutTitle.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (showSubstitute ? AppTextStyles.labelMd : AppTextStyles.labelSm)
            .copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: AppWorkoutRunnerTokens.eyebrowLetterSpacing,
            ),
      ),
      AppWhiteSpace.hXxs,
      Text(
        exerciseTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyLg.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (showSubstitute) ...[
        AppWhiteSpace.hSm,
        _SubstitutePill(onTap: onSubstitute),
      ],
    ],
  );
}

class _SubstitutePill extends StatelessWidget {
  const _SubstitutePill({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.brightnessOf(context) == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final enabled = onTap != null;

    return Semantics(
      key: const ValueKey<String>('workout_runner_substitute'),
      button: true,
      enabled: enabled,
      label: AppStrings.substitute,
      child: Opacity(
        opacity: enabled ? 1 : AppWorkoutRunnerTokens.upcomingRowOpacity,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.controlGap,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: context.colorScheme.outlineVariant,
                width: AppSizing.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.materialSwapHoriz,
                  width: AppSizing.iconS,
                  height: AppSizing.iconS,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
                AppWhiteSpace.wXs,
                Flexible(
                  child: Text(
                    AppStrings.substitute.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
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
