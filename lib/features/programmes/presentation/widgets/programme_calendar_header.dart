import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgrammeCalendarHeader extends StatelessWidget {
  const ProgrammeCalendarHeader({
    super.key,
    required this.viewData,
    required this.onStartTodayWorkout,
    required this.onResumeTodayWorkout,
    required this.onBack,
    required this.onEdit,
    required this.programId,
    this.activeSession,
  });

  final ProgrammeCalendarViewData viewData;
  final VoidCallback? onStartTodayWorkout;
  final VoidCallback onResumeTodayWorkout;
  final VoidCallback onBack;
  final VoidCallback onEdit;
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
        ? onResumeTodayWorkout
        : hasMismatchedSession || !hasTodayWorkout
        ? null
        : onStartTodayWorkout;
    final weekProgress = viewData.todayWeekNumber == null
        ? '${viewData.weeksTotal} ${AppStrings.weeks}'
        : AppStrings.weekOf(viewData.todayWeekNumber!, viewData.weeksTotal);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        top: AppSpacing.sm,
        right: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                asset: OutlinedSvgAssets.arrowLeft,
                onPressed: onBack,
                semanticLabel: AppStrings.backLabel,
                backgroundColor: context.colorScheme.surfaceContainerLow,
              ),
              AppIconButton(
                asset: OutlinedSvgAssets.pencil,
                onPressed: onEdit,
                semanticLabel: AppStrings.edit,
                backgroundColor: context.colorScheme.surfaceContainerLow,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(
                label: viewData.isActive
                    ? AppStrings.programmeActive
                    : AppStrings.programmeInactive,
                backgroundColor: viewData.isActive
                    ? context.colorScheme.secondaryContainer
                    : context.colorScheme.surfaceContainerHigh,
                foregroundColor: viewData.isActive
                    ? context.colorScheme.onSecondaryContainer
                    : context.colorScheme.onSurfaceVariant,
                borderRadius: AppRadius.full,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                fontWeight: FontWeight.w700,
              ),
              if (viewData.blockType != null && viewData.blockType!.isNotEmpty)
                AppBadge(
                  label: '${AppStrings.currentPhase}: ${viewData.blockType!}',
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                  foregroundColor: context.colorScheme.onSurfaceVariant,
                  borderRadius: AppRadius.full,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
            ],
          ),
          AppWhiteSpace.hMd,
          Text(
            viewData.name,
            style: context.textTheme.headlineLarge?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (viewData.description != null &&
              viewData.description!.isNotEmpty) ...[
            AppWhiteSpace.hXs,
            Text(
              viewData.description!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ProgrammeMetric(label: weekProgress),
              if (viewData.daysPerWeek != null)
                _ProgrammeMetric(
                  label: '${viewData.daysPerWeek} ${AppStrings.daysPerWeek}',
                ),
            ],
          ),
          AppWhiteSpace.hLg,
          if (hasTodayWorkout)
            _TodayWorkoutPanel(
              buttonLabel: buttonLabel,
              buttonOnPressed: buttonOnPressed,
              hasMatchingSession: hasMatchingSession,
              hasMismatchedSession: hasMismatchedSession,
            )
          else
            _RecoveryPanel(hasActiveSession: activeSession != null),
        ],
      ),
    );
  }
}

class _ProgrammeMetric extends StatelessWidget {
  const _ProgrammeMetric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TodayWorkoutPanel extends StatelessWidget {
  const _TodayWorkoutPanel({
    required this.buttonLabel,
    required this.buttonOnPressed,
    required this.hasMatchingSession,
    required this.hasMismatchedSession,
  });

  final String buttonLabel;
  final VoidCallback? buttonOnPressed;
  final bool hasMatchingSession;
  final bool hasMismatchedSession;

  @override
  Widget build(BuildContext context) {
    final supportingLabel = hasMatchingSession
        ? AppStrings.sessionInProgress
        : hasMismatchedSession
        ? AppStrings.workoutInProgress
        : AppStrings.scheduledToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIcon(
                asset: hasMatchingSession
                    ? OutlinedSvgAssets.playPause
                    : OutlinedSvgAssets.bolt,
                foregroundColor: context.colorScheme.secondary,
                backgroundColor: context.colorScheme.secondaryContainer,
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.todaysWorkout,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppWhiteSpace.hXxs,
                    Text(
                      supportingLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: buttonOnPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              icon: SvgPicture.asset(
                hasMatchingSession
                    ? OutlinedSvgAssets.playPause
                    : OutlinedSvgAssets.playCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  buttonOnPressed == null
                      ? context.colorScheme.onSurfaceVariant
                      : context.colorScheme.onSecondary,
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

class _RecoveryPanel extends StatelessWidget {
  const _RecoveryPanel({required this.hasActiveSession});

  final bool hasActiveSession;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: AppSizing.hairlineStrokeWidth,
        ),
      ),
      child: Row(
        children: [
          _HeaderIcon(
            asset: OutlinedSvgAssets.leaf,
            foregroundColor: context.colorScheme.onSurfaceVariant,
            backgroundColor: context.colorScheme.surfaceContainerHigh,
          ),
          AppWhiteSpace.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.activeRecovery,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppWhiteSpace.hXxs,
                Text(
                  hasActiveSession
                      ? AppStrings.workoutInProgress
                      : AppStrings.noWorkoutToday,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.asset,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String asset;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconXxl,
      height: AppSizing.iconXxl,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: SvgPicture.asset(
        asset,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
      ),
    );
  }
}
