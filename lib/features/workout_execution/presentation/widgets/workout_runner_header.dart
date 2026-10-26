import 'package:aedify/features/workout_execution/presentation/widgets/workout_duration_timer.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Grounds the active exercise in its workout and elapsed session time.
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
  final VoidCallback? onSubstitute;
  final bool showSubstitute;
  final int? pausedDurationSeconds;

  /// Legacy clearance estimate; new layouts use the header's natural height.
  static double extentFor(BuildContext context, {bool showSubstitute = true}) {
    final scaler = MediaQuery.textScalerOf(context);
    final contextStyle = WorkoutRunnerStyle.caption(context);
    final titleStyle = WorkoutRunnerStyle.heading(context);
    final titlesHeight =
        scaler.scale(contextStyle.fontSize!) * contextStyle.height! +
        AppSpacing.xs +
        scaler.scale(titleStyle.fontSize!) * titleStyle.height!;
    return titlesHeight.clamp(
          AppWorkoutRunnerTokens.controlSize,
          double.infinity,
        ) +
        (AppSpacing.md * 2) +
        (_stacksTimer(context)
            ? AppSpacing.sm + AppWorkoutRunnerTokens.controlSize
            : 0) +
        (showSubstitute
            ? AppSpacing.sm + AppWorkoutRunnerTokens.controlSize
            : 0);
  }

  static bool _stacksTimer(BuildContext context) =>
      MediaQuery.sizeOf(context).width <
          AppWorkoutRunnerTokens.stackedHeaderBreakpoint ||
      MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
          AppFontSizes.sm * AppWorkoutRunnerTokens.largeTextBreakpoint;

  @override
  Widget build(BuildContext context) {
    final stacked = _stacksTimer(context);
    final timer = WorkoutDurationTimer(
      startedAt: workoutStartedAt,
      isPaused: isPaused,
      pausedDurationSeconds: pausedDurationSeconds,
    );
    return ColoredBox(
      key: const ValueKey<String>('workout_runner_header'),
      color: context.colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppWorkoutRunnerTokens.horizontalPadding,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    key: const ValueKey<String>('workout_runner_close_button'),
                    tooltip: AppStrings.exitWorkout,
                    onPressed: onClose,
                    constraints: const BoxConstraints(
                      minWidth: AppWorkoutRunnerTokens.controlSize,
                      minHeight: AppWorkoutRunnerTokens.controlSize,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorScheme.surfaceContainerLow,
                    ),
                    icon: SvgPicture.asset(
                      OutlinedSvgAssets.materialClose,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
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
                  if (!stacked) ...[AppWhiteSpace.wSm, timer],
                ],
              ),
              if (stacked) ...[
                AppWhiteSpace.hSm,
                Align(alignment: AlignmentDirectional.centerEnd, child: timer),
              ],
            ],
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            exerciseTitle,
            style: WorkoutRunnerStyle.heading(
              context,
            ).copyWith(fontSize: AppFontSizes.xl, fontWeight: FontWeight.w600),
          ),
        ),
        if (showSubstitute) ...[
          AppWhiteSpace.hSm,
          TextButton.icon(
            key: const ValueKey<String>('workout_runner_substitute'),
            onPressed: onSubstitute,
            style: TextButton.styleFrom(
              foregroundColor: WorkoutRunnerStyle.accent(context),
              backgroundColor: context.colorScheme.surfaceContainerLow,
              disabledForegroundColor: context.colorScheme.onSurfaceVariant,
              minimumSize: const Size(
                AppWorkoutRunnerTokens.controlSize,
                AppWorkoutRunnerTokens.controlSize,
              ),
              textStyle: WorkoutRunnerStyle.label(
                context,
              ).copyWith(inherit: false),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.controlGap,
                vertical: AppSpacing.controlGap,
              ),
              shape: const StadiumBorder(),
            ),
            icon: SvgPicture.asset(
              OutlinedSvgAssets.materialSwapHoriz,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                onSubstitute == null
                    ? context.colorScheme.onSurfaceVariant
                    : WorkoutRunnerStyle.accent(context),
                BlendMode.srcIn,
              ),
            ),
            label: const Text(AppStrings.substitute),
          ),
        ],
      ],
    );
  }
}
