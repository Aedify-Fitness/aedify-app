import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';

class ProgrammeCalendarHeader extends StatelessWidget {
  const ProgrammeCalendarHeader({
    super.key,
    required this.viewData,
    required this.onStartTodayWorkout,
    required this.programId,
    this.activeSession,
  });

  final ProgrammeCalendarViewData viewData;
  final VoidCallback? onStartTodayWorkout;
  final String programId;
  final WorkoutRunnerSessionViewData? activeSession;

  @override
  Widget build(BuildContext context) {
    final hasTodayWorkout = viewData.todayWorkoutId != null;
    final hasMatchingSession =
        activeSession != null &&
        activeSession!.programId == programId &&
        activeSession!.programWorkoutId == viewData.todayWorkoutId;
    final hasMismatchedSession = activeSession != null && !hasMatchingSession;

    final buttonLabel = hasMatchingSession
        ? AppStrings.resumeWorkout
        : AppStrings.startTodaysWorkout;
    final buttonOnPressed = hasMatchingSession
        ? () => context.pushNamed(AppRoutes.workoutRunnerActive().name)
        : hasMismatchedSession || !hasTodayWorkout
        ? null
        : onStartTodayWorkout;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewData.blockType != null && viewData.blockType!.isNotEmpty) ...[
            AppBadge(
              label: '${AppStrings.currentPhase}: ${viewData.blockType!}'
                  .toUpperCase(),
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              foregroundColor: context.colorScheme.onSecondaryFixedVariant,
              borderRadius: AppRadius.full,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs + 1,
              ),
              letterSpacing: 0.02,
            ),
            AppWhiteSpace.hMd,
          ],
          Text(
            viewData.name,
            style: context.textTheme.headlineLarge?.copyWith(
              fontSize: AppFontSizes.displayMd,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.02,
              color: context.colorScheme.onSurface,
            ),
          ),
          if (viewData.description != null &&
              viewData.description!.isNotEmpty) ...[
            AppWhiteSpace.hXs,
            Text(
              viewData.description!,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: AppFontSizes.lg,
                height: 28 / 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: buttonOnPressed,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  buttonOnPressed != null
                      ? context.colorScheme.onSecondary
                      : context.colorScheme.onSecondary.withAlpha(128),
                  BlendMode.srcIn,
                ),
              ),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
