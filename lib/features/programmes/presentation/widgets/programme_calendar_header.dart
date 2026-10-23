import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
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
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final hasTodayWorkout = viewData.todayWorkoutId != null;
    final hasMatchingSession =
        activeSession != null &&
        activeSession!.programId == programId &&
        activeSession!.programWorkoutId == viewData.todayWorkoutId;
    final hasMismatchedSession = activeSession != null && !hasMatchingSession;
    final workouts = viewData.weeks
        .expand((week) => week.days)
        .where((day) => !day.isRestDay)
        .toList();
    final todayWorkout = workouts
        .where((day) => day.workoutId == viewData.todayWorkoutId)
        .firstOrNull;
    final completedCount = workouts.where((day) => day.isCompleted).length;
    final weekProgress = viewData.todayWeekNumber == null
        ? '${viewData.weeksTotal} ${AppStrings.weeks}'
        : AppStrings.weekOf(viewData.todayWeekNumber!, viewData.weeksTotal);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderNavigationButton(
                asset: OutlinedSvgAssets.arrowLeft,
                label: AppStrings.backLabel,
                onPressed: onBack,
              ),
              AppWhiteSpace.wSm,
              Expanded(
                child: Text(
                  AppStrings.programmeCalendar,
                  textAlign: TextAlign.center,
                  style: _HeaderStyles.label(
                    context,
                  ).copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
              AppWhiteSpace.wSm,
              _HeaderNavigationButton(
                asset: OutlinedSvgAssets.pencil,
                label: AppStrings.edit,
                onPressed: onEdit,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(
                label: viewData.isActive
                    ? AppStrings.programmeActive
                    : AppStrings.programmeInactive,
                backgroundColor: viewData.isActive
                    ? context.colorScheme.secondaryFixed
                    : context.colorScheme.surfaceContainerHigh,
                foregroundColor: viewData.isActive
                    ? context.colorScheme.onSecondaryFixed
                    : context.colorScheme.onSurfaceVariant,
                textStyle: _HeaderStyles.label(context),
                borderRadius: AppRadius.full,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.controlGap,
                  vertical: AppSpacing.xs,
                ),
                fontWeight: FontWeight.w700,
              ),
              if (viewData.blockType?.isNotEmpty ?? false)
                Text(
                  '${AppStrings.currentPhase}: ${viewData.blockType!}',
                  style: _HeaderStyles.label(
                    context,
                  ).copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          AppWhiteSpace.hMd,
          Text(
            viewData.name,
            style:
                (isDark
                        ? AppTextStylesDark.headlineLg
                        : AppTextStyles.headlineLg)
                    .copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
          ),
          if (viewData.description?.isNotEmpty ?? false) ...[
            AppWhiteSpace.hSm,
            Text(
              viewData.description!,
              style: _HeaderStyles.body(
                context,
              ).copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderMetadata(
                asset: OutlinedSvgAssets.calendarDays,
                label: weekProgress,
              ),
              if (viewData.daysPerWeek != null)
                _HeaderMetadata(
                  asset: OutlinedSvgAssets.arrowPath,
                  label: '${viewData.daysPerWeek} ${AppStrings.daysPerWeek}',
                ),
            ],
          ),
          if (workouts.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            _ProgrammeProgress(
              completedCount: completedCount,
              workoutCount: workouts.length,
              accent: accent,
            ),
          ],
          AppWhiteSpace.hLg,
          if (hasTodayWorkout)
            _TodayWorkoutPanel(
              workout: todayWorkout,
              buttonLabel: hasMatchingSession
                  ? AppStrings.resumeWorkout
                  : AppStrings.startTodaysWorkout,
              buttonOnPressed: hasMatchingSession
                  ? onResumeTodayWorkout
                  : hasMismatchedSession
                  ? null
                  : onStartTodayWorkout,
              hasMatchingSession: hasMatchingSession,
              hasMismatchedSession: hasMismatchedSession,
              accent: accent,
            )
          else
            _RecoveryPanel(hasActiveSession: activeSession != null),
        ],
      ),
    );
  }
}

class _HeaderNavigationButton extends StatelessWidget {
  const _HeaderNavigationButton({
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppProgrammeCalendarTokens.controlSize),
        backgroundColor: context.colorScheme.surfaceContainerLow,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      icon: SvgPicture.asset(
        asset,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _ProgrammeProgress extends StatelessWidget {
  const _ProgrammeProgress({
    required this.completedCount,
    required this.workoutCount,
    required this.accent,
  });

  final int completedCount;
  final int workoutCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final completionLabel = AppStrings.programmeWorkoutCompletion(
      completedCount,
      workoutCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              AppStrings.programmeProgress,
              style: _HeaderStyles.label(
                context,
              ).copyWith(color: context.colorScheme.onSurface),
            ),
            Text(
              completionLabel,
              style: _HeaderStyles.label(
                context,
              ).copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        AppWhiteSpace.hSm,
        LinearProgressIndicator(
          key: const ValueKey('programme_calendar_progress'),
          value: completedCount / workoutCount,
          minHeight: AppProgrammeCalendarTokens.progressTrackHeight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          color: accent,
          backgroundColor: context.colorScheme.surfaceContainerHigh,
          semanticsLabel: completionLabel,
        ),
      ],
    );
  }
}

class _TodayWorkoutPanel extends StatelessWidget {
  const _TodayWorkoutPanel({
    required this.workout,
    required this.buttonLabel,
    required this.buttonOnPressed,
    required this.hasMatchingSession,
    required this.hasMismatchedSession,
    required this.accent,
  });

  final DayViewData? workout;
  final String buttonLabel;
  final VoidCallback? buttonOnPressed;
  final bool hasMatchingSession;
  final bool hasMismatchedSession;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final supportingLabel = hasMatchingSession
        ? AppStrings.sessionInProgress
        : hasMismatchedSession
        ? AppStrings.workoutInProgress
        : AppStrings.scheduledToday;
    final buttonForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;

    return Container(
      key: const ValueKey('programme_calendar_today'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.todaysWorkout,
            style: _HeaderStyles.label(
              context,
            ).copyWith(color: accent, fontWeight: FontWeight.w700),
          ),
          AppWhiteSpace.hSm,
          Text(
            workout?.title ?? AppStrings.todaysWorkout,
            style: _HeaderStyles.heading(
              context,
            ).copyWith(color: context.colorScheme.onSurface),
          ),
          AppWhiteSpace.hXs,
          Text(
            supportingLabel,
            style: _HeaderStyles.body(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          if (workout != null) ...[
            AppWhiteSpace.hMd,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _HeaderMetadata(
                  asset: OutlinedSvgAssets.listBullet,
                  label: '${workout!.exerciseCount} ${AppStrings.movements}',
                ),
                if (workout!.durationMinutes > 0)
                  _HeaderMetadata(
                    asset: OutlinedSvgAssets.clock,
                    label:
                        '${workout!.durationMinutes}${AppStrings.durationMinutesAbbreviation}',
                  ),
              ],
            ),
          ],
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: buttonOnPressed,
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? context.colorScheme.primaryContainer
                    : accent,
                foregroundColor: buttonForeground,
                disabledBackgroundColor:
                    context.colorScheme.surfaceContainerHigh,
                disabledForegroundColor: context.colorScheme.onSurfaceVariant,
                minimumSize: const Size.fromHeight(
                  AppProgrammeCalendarTokens.controlSize,
                ),
                textStyle: isDark
                    ? AppTextStylesDark.labelMd
                    : AppTextStyles.labelMd,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    hasMatchingSession
                        ? OutlinedSvgAssets.playPause
                        : OutlinedSvgAssets.playCircle,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      buttonOnPressed == null
                          ? context.colorScheme.onSurfaceVariant
                          : buttonForeground,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Flexible(
                    child: Text(buttonLabel, textAlign: TextAlign.center),
                  ),
                ],
              ),
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
      key: const ValueKey('programme_calendar_recovery'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.leaf,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.activeRecovery,
            style: _HeaderStyles.heading(
              context,
            ).copyWith(color: context.colorScheme.onSurface),
          ),
          AppWhiteSpace.hSm,
          Text(
            hasActiveSession
                ? AppStrings.workoutInProgress
                : AppStrings.noWorkoutToday,
            style: _HeaderStyles.body(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetadata extends StatelessWidget {
  const _HeaderMetadata({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: AppSizing.iconXxs,
          height: AppSizing.iconXxs,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wXs,
        Flexible(
          child: Text(
            label,
            style: _HeaderStyles.label(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

abstract final class _HeaderStyles {
  static TextStyle label(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.labelSm
      : AppTextStyles.labelSm;

  static TextStyle body(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.bodySm
      : AppTextStyles.bodySm;

  static TextStyle heading(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? AppTextStylesDark.headlineMd
      : AppTextStyles.headlineMd;
}
