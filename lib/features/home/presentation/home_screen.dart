import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  int _computeWeekSessionsRemaining(ProgrammeSync sync, int weekNumber) {
    final week = sync.aggregate.weeks.firstWhere(
      (week) => week.weekNumber == weekNumber,
    );
    final weekWorkoutIds = sync.aggregate.workouts
        .where((workout) => workout.programWeekId == week.id)
        .map((workout) => workout.id)
        .toSet();
    final completedInWeek = weekWorkoutIds
        .where(sync.resolution.completedWorkoutIds.contains)
        .length;
    return weekWorkoutIds.length - completedInWeek;
  }

  double _computeProgrammeProgress(
    ProgrammeSync? sync,
    int? currentWeek,
    int totalWeeks,
  ) {
    if (totalWeeks <= 0) return 0;
    if (currentWeek != null) {
      return (currentWeek / totalWeeks).clamp(0.0, 1.0).toDouble();
    }
    final workouts = sync?.aggregate.workouts ?? [];
    if (workouts.isEmpty) return 0;
    final allWorkoutsResolved = workouts.every(
      (workout) =>
          workout.status == 'skipped' ||
          sync!.resolution.completedWorkoutIds.contains(workout.id),
    );
    return allWorkoutsResolved ? 1 : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(AppProviders.homeRefreshTriggerProvider);
    final profileState = ref.watch(AppProviders.profileControllerProvider);
    final programmeState = ref.watch(
      AppProviders.programmeLibraryControllerProvider,
    );
    final programmeData = programmeState.asData?.value;
    final programmes = programmeData?.items ?? [];
    final activeProgramme = programmes.cast<ProgrammeListItem?>().firstWhere(
      (programme) => programme?.active == true,
      orElse: () => null,
    );
    final activeSessionAsync = ref.watch(
      AppProviders.activeWorkoutSessionProvider,
    );
    final activeSession = activeSessionAsync.asData?.value;
    final syncAsync = activeProgramme != null
        ? ref.watch(AppProviders.programmeSyncProvider(activeProgramme.id))
        : null;
    final sync = syncAsync?.asData?.value;
    final currentWeek = sync?.resolution.todayFlatIndex != null
        ? (sync!.resolution.todayFlatIndex! ~/ 7) + 1
        : null;
    final sessionsRemaining = sync != null && currentWeek != null
        ? _computeWeekSessionsRemaining(sync, currentWeek)
        : null;
    final programmeProgress = _computeProgrammeProgress(
      sync,
      currentWeek,
      activeProgramme?.weeksTotal ?? 0,
    );
    final todayWorkoutId = sync?.resolution.todayWorkoutId;
    final todayWorkoutName = () {
      if (todayWorkoutId == null || sync == null) return '';
      final workouts = sync.aggregate.workouts.where(
        (workout) => workout.id == todayWorkoutId,
      );
      return workouts.isEmpty
          ? activeProgramme?.name ?? ''
          : workouts.first.name;
    }();
    final exerciseCount = () {
      if (todayWorkoutId == null || sync == null) return 0;
      return sync.aggregate.exercises
          .where((exercise) => exercise.programWorkoutId == todayWorkoutId)
          .length;
    }();
    final durationMinutes = () {
      if (todayWorkoutId == null || sync == null) return 0;
      final workouts = sync.aggregate.workouts.where(
        (workout) => workout.id == todayWorkoutId,
      );
      if (workouts.isEmpty) return 0;
      final templateId = workouts.first.workoutTemplateId;
      if (templateId == null) return 0;
      final templates = sync.aggregate.templates.where(
        (template) => template.id == templateId,
      );
      return templates.isEmpty
          ? 0
          : templates.first.estimatedDurationMinutes ?? 0;
    }();

    String? loadErrorMessage;
    if (programmeState.hasError || programmeData?.errorCode != null) {
      loadErrorMessage =
          programmeData?.errorMessage ?? AppStrings.programmesLoadFailed;
    } else if (activeSessionAsync.hasError) {
      loadErrorMessage = AppStrings.workoutRunnerLoadFailed;
    } else if (syncAsync?.hasError == true) {
      loadErrorMessage = AppStrings.programmesLoadFailed;
    }
    final isWorkoutLoading =
        loadErrorMessage == null &&
        (programmeState.isLoading ||
            programmeData?.isLoading == true ||
            activeSessionAsync.isLoading ||
            syncAsync?.isLoading == true);
    final displayName =
        profileState.asData?.value.profile?.displayName?.trim() ?? '';
    final contentTopInset =
        (AppSizing.homeContentTopOffset - MediaQuery.paddingOf(context).top)
            .clamp(0.0, AppSizing.homeContentTopOffset)
            .toDouble();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          key: const Key('home_scroll_view'),
          padding: EdgeInsets.only(
            top: contentTopInset,
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            bottom: AppSizing.navBarHeight + AppSpacing.xxl,
          ),
          children: [
            _GreetingHeader(name: displayName),
            AppWhiteSpace.hXl,
            const _TrainingSignalsSection(),
            AppWhiteSpace.hXl,
            if (activeProgramme != null && sync != null) ...[
              _ActiveProgrammePanel(
                programme: activeProgramme,
                currentWeek: currentWeek,
                sessionsRemaining: sessionsRemaining,
                totalWeeks: activeProgramme.weeksTotal ?? 0,
                progress: programmeProgress,
              ),
              AppWhiteSpace.hLg,
            ],
            KeyedSubtree(
              key: const Key('home_workout_surface'),
              child: activeSession != null
                  ? _OngoingWorkoutSurface(session: activeSession)
                  : isWorkoutLoading
                  ? const _HomeLoadingSurface()
                  : loadErrorMessage != null
                  ? _HomeErrorSurface(
                      message: loadErrorMessage,
                      onRetry: () {
                        ref.invalidate(
                          AppProviders.programmeLibraryControllerProvider,
                        );
                        ref.invalidate(
                          AppProviders.activeWorkoutSessionProvider,
                        );
                        if (activeProgramme != null) {
                          ref.invalidate(
                            AppProviders.programmeSyncProvider(
                              activeProgramme.id,
                            ),
                          );
                        }
                      },
                    )
                  : _TodayWorkoutSurface(
                      activeProgramme: activeProgramme,
                      todayWorkoutId: todayWorkoutId,
                      workoutName: todayWorkoutName,
                      exerciseCount: exerciseCount,
                      durationMinutes: durationMinutes,
                    ),
            ),
            AppWhiteSpace.hXl,
            const _QuickActionGrid(),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name});

  final String name;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return AppStrings.goodMorning;
    if (hour >= 12 && hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    final title = name.isEmpty ? greeting : '$greeting, $name';
    return Column(
      key: const Key('home_greeting_header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hXs,
        Text(
          AppStrings.readyForSession,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const _StreakBadge(),
      ],
    );
  }
}

class _StreakBadge extends ConsumerWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _computeStreak(ref);
    if (streak == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.secondary.withValues(alpha: 0.3),
              blurRadius: AppSpacing.sm,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.fire,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wControlGap,
            Text(
              '$streak ${AppStrings.dayStreak}',
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _computeStreak(WidgetRef ref) {
    // TODO: M5 - compute the real streak from completed workout history.
    return 0;
  }
}

class _TrainingSignalsSection extends StatelessWidget {
  const _TrainingSignalsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_PlateauSignalCard(), AppWhiteSpace.hXl, _VolumeSignalCard()],
    );
  }
}

class _PlateauSignalCard extends StatelessWidget {
  const _PlateauSignalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_plateau_signal'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: context.colorScheme.error.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizing.homeAlertIconTile,
                height: AppSizing.homeAlertIconTile,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
                child: SvgPicture.asset(
                  OutlinedSvgAssets.arrowRight,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onErrorContainer,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppWhiteSpace.wControlGap,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    AppStrings.plateauAlert,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              AppBadge(
                label: AppStrings.comingSoon,
                backgroundColor: context.colorScheme.errorContainer,
                foregroundColor: context.colorScheme.onErrorContainer,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
          AppWhiteSpace.hControlGap,
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizing.homeAlertIconTile + AppSpacing.controlGap,
            ),
            child: Text(
              AppStrings.plateauComingSoon,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeSignalCard extends StatelessWidget {
  const _VolumeSignalCard();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return Container(
      key: const Key('home_volume_signal'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? context.colorScheme.surfaceContainerLow
            : context.colorScheme.surfaceContainerLowest,
        border: Border.all(color: context.colorScheme.surfaceContainerLow),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.volumeThisWeek,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  AppStrings.comingSoon,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  AppStrings.volumeTrackingComingSoon,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppWhiteSpace.wMd,
          Container(
            width: AppSizing.homeMetricIconSize,
            height: AppSizing.homeMetricIconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              OutlinedSvgAssets.materialAnalytics,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutFeatureSurface extends StatelessWidget {
  const _WorkoutFeatureSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final background = isDark
        ? context.colorScheme.surfaceContainerHigh
        : context.colorScheme.primaryContainer;
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSizing.homeWorkoutHeroMinHeight,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -AppSizing.homeWorkoutGlowOffset,
            right: -AppSizing.homeWorkoutGlowOffset,
            child: Container(
              width: AppSizing.homeWorkoutGlowSize,
              height: AppSizing.homeWorkoutGlowSize,
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.secondary.withValues(alpha: 0.2),
                    blurRadius: AppSizing.homeWorkoutGlowBlur,
                    spreadRadius: AppSpacing.xl,
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: child),
        ],
      ),
    );
  }
}

class _TodayWorkoutSurface extends StatelessWidget {
  const _TodayWorkoutSurface({
    required this.exerciseCount,
    required this.durationMinutes,
    required this.workoutName,
    this.activeProgramme,
    this.todayWorkoutId,
  });

  final ProgrammeListItem? activeProgramme;
  final String? todayWorkoutId;
  final String workoutName;
  final int exerciseCount;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    if (activeProgramme == null) return const _NoProgrammeSurface();
    if (todayWorkoutId == null) {
      return const _NoWorkoutTodaySurface();
    }
    return _ScheduledWorkoutSurface(
      activeProgramme: activeProgramme!,
      workoutName: workoutName,
      exerciseCount: exerciseCount,
      durationMinutes: durationMinutes,
      programWorkoutId: todayWorkoutId!,
    );
  }
}

class _ScheduledWorkoutSurface extends StatelessWidget {
  const _ScheduledWorkoutSurface({
    required this.activeProgramme,
    required this.workoutName,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.programWorkoutId,
  });

  final ProgrammeListItem activeProgramme;
  final String workoutName;
  final int exerciseCount;
  final int durationMinutes;
  final String programWorkoutId;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isDark
        ? context.colorScheme.onSurface
        : context.colorScheme.onPrimary;
    final mutedForeground = isDark
        ? context.colorScheme.onSurfaceVariant
        : context.colorScheme.onPrimaryContainer;
    final actionBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final actionForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;
    return _WorkoutFeatureSurface(
      child: Column(
        key: const Key('home_scheduled_workout_panel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: AppStrings.scheduledToday.toUpperCase(),
            backgroundColor: actionBackground,
            foregroundColor: actionForeground,
            borderRadius: AppRadius.full,
          ),
          AppWhiteSpace.hMd,
          Text(
            workoutName,
            style: AppTextStyles.headlineXl.copyWith(color: foreground),
          ),
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroMetaItem(
                icon: OutlinedSvgAssets.clock,
                label: '$durationMinutes ${AppStrings.durationUnit}',
                foreground: mutedForeground,
              ),
              _HeroMetaItem(
                icon: OutlinedSvgAssets.materialFitnessCenter,
                label: '$exerciseCount ${AppStrings.exercisesCompleted}',
                foreground: mutedForeground,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('home_start_workout_button'),
              iconAlignment: IconAlignment.end,
              onPressed: () {
                context.pushNamed(
                  AppRoutes.workoutRunnerProgramWorkout().name,
                  pathParameters: {
                    'programId': activeProgramme.id,
                    'workoutId': programWorkoutId,
                  },
                );
              },
              icon: SvgPicture.asset(
                OutlinedSvgAssets.play,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  actionForeground,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.startWorkout),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizing.homePrimaryActionHeight,
                ),
                backgroundColor: actionBackground,
                foregroundColor: actionForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
          AppWhiteSpace.hControlGap,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              key: const Key('home_view_workout_details_button'),
              onPressed: () {
                context.pushNamed(
                  AppRoutes.programmeWorkoutDetail().name,
                  pathParameters: {
                    'programId': activeProgramme.id,
                    'workoutId': programWorkoutId,
                  },
                );
              },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizing.homeSecondaryActionHeight,
                ),
                foregroundColor: foreground,
                shape: const StadiumBorder(),
              ),
              child: const Text(AppStrings.viewDetails),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoWorkoutTodaySurface extends StatelessWidget {
  const _NoWorkoutTodaySurface();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isDark
        ? context.colorScheme.onSurface
        : context.colorScheme.onPrimary;
    final mutedForeground = isDark
        ? context.colorScheme.onSurfaceVariant
        : context.colorScheme.onPrimaryContainer;
    final accent = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final onAccent = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;
    return _WorkoutFeatureSurface(
      child: Column(
        key: const Key('home_no_workout_panel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: AppStrings.rest.toUpperCase(),
            backgroundColor: accent,
            foregroundColor: onAccent,
            borderRadius: AppRadius.full,
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noWorkoutToday,
            style: AppTextStyles.headlineXl.copyWith(color: foreground),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noWorkoutTodayMessage,
            style: AppTextStyles.bodyLg.copyWith(color: mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _NoProgrammeSurface extends StatelessWidget {
  const _NoProgrammeSurface();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isDark
        ? context.colorScheme.onSurface
        : context.colorScheme.onPrimary;
    final mutedForeground = isDark
        ? context.colorScheme.onSurfaceVariant
        : context.colorScheme.onPrimaryContainer;
    final actionBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final actionForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;
    return _WorkoutFeatureSurface(
      child: Column(
        key: const Key('home_no_programme_panel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: AppStrings.scheduledToday.toUpperCase(),
            backgroundColor: actionBackground,
            foregroundColor: actionForeground,
            borderRadius: AppRadius.full,
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noActiveProgramme,
            style: AppTextStyles.headlineXl.copyWith(color: foreground),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noActiveProgrammeHint,
            style: AppTextStyles.bodyLg.copyWith(color: mutedForeground),
          ),
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('home_browse_programmes_button'),
              iconAlignment: IconAlignment.end,
              onPressed: () {
                final shell = StatefulNavigationShell.of(context);
                shell.goBranch(2);
              },
              icon: SvgPicture.asset(
                OutlinedSvgAssets.materialArrowForward,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  actionForeground,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.browseProgrammes),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizing.homePrimaryActionHeight,
                ),
                backgroundColor: actionBackground,
                foregroundColor: actionForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingSurface extends StatelessWidget {
  const _HomeLoadingSurface();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return Material(
      color: isDark
          ? context.colorScheme.surfaceContainerLow
          : context.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: AppSizing.emptyStateHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.colorScheme.secondary),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.loadingProgrammes,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeErrorSurface extends StatelessWidget {
  const _HomeErrorSurface({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return Material(
      color: isDark
          ? context.colorScheme.surfaceContainerLow
          : context.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          iconAsset: OutlinedSvgAssets.exclamationTriangle,
          title: message,
          actionLabel: AppStrings.retry,
          onAction: onRetry,
        ),
      ),
    );
  }
}

class _HeroMetaItem extends StatelessWidget {
  const _HeroMetaItem({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final String icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        SvgPicture.asset(
          icon,
          width: AppSizing.iconS,
          height: AppSizing.iconS,
          colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
        ),
        Text(label, style: AppTextStyles.labelMd.copyWith(color: foreground)),
      ],
    );
  }
}

class _OngoingWorkoutSurface extends ConsumerWidget {
  const _OngoingWorkoutSurface({required this.session});

  final WorkoutRunnerSessionViewData session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedSets = session.exercises.fold<int>(
      0,
      (sum, exercise) =>
          sum + exercise.sets.where((set) => set.completed).length,
    );
    final totalSets = session.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
    final elapsedMinutes = (session.durationSeconds ?? 0) ~/ 60;
    final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isDark
        ? context.colorScheme.onSurface
        : context.colorScheme.onPrimary;
    final mutedForeground = isDark
        ? context.colorScheme.onSurfaceVariant
        : context.colorScheme.onPrimaryContainer;
    final actionBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final actionForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;

    return _WorkoutFeatureSurface(
      child: Column(
        key: const Key('home_resume_workout_panel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: AppStrings.workoutInProgress.toUpperCase(),
            backgroundColor: actionBackground,
            foregroundColor: actionForeground,
            borderRadius: AppRadius.full,
          ),
          AppWhiteSpace.hMd,
          Text(
            session.name,
            style: AppTextStyles.headlineXl.copyWith(color: foreground),
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                '$completedSets/$totalSets ${AppStrings.setsCompleted}',
                style: AppTextStyles.labelMd.copyWith(color: mutedForeground),
              ),
              _HeroMetaItem(
                icon: OutlinedSvgAssets.clock,
                label: '$elapsedMinutes ${AppStrings.durationUnit}',
                foreground: mutedForeground,
              ),
            ],
          ),
          AppWhiteSpace.hSm,
          LinearProgressIndicator(
            value: progress,
            minHeight: AppSizing.progressBarHeight,
            color: actionBackground,
            backgroundColor: foreground.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('home_resume_workout_button'),
              onPressed: () {
                context.pushNamed(AppRoutes.workoutRunnerActive().name);
              },
              icon: SvgPicture.asset(
                OutlinedSvgAssets.play,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  actionForeground,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.resumeWorkout),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppSizing.homePrimaryActionHeight,
                ),
                backgroundColor: actionBackground,
                foregroundColor: actionForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
          AppWhiteSpace.hSm,
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _discardWorkout(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: foreground.withValues(alpha: 0.8),
              ),
              child: const Text(AppStrings.discardWorkout),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _discardWorkout(BuildContext context, WidgetRef ref) async {
    final abandonUseCase = ref.read(
      AppProviders.abandonWorkoutSessionUseCaseProvider,
    );
    await abandonUseCase.abandon(session.sessionId);
    ref.invalidate(AppProviders.activeWorkoutSessionProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.workoutCancelled)));
  }
}

class _ActiveProgrammePanel extends StatelessWidget {
  const _ActiveProgrammePanel({
    required this.programme,
    required this.totalWeeks,
    required this.progress,
    this.currentWeek,
    this.sessionsRemaining,
  });

  final ProgrammeListItem programme;
  final int totalWeeks;
  final double progress;
  final int? currentWeek;
  final int? sessionsRemaining;

  @override
  Widget build(BuildContext context) {
    final displayedWeek =
        currentWeek ?? (progress >= 1 && totalWeeks > 0 ? totalWeeks : 1);
    return Container(
      key: const Key('home_active_programme_panel'),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              AppRoutes.programmeCalendar().name,
              pathParameters: {'id': programme.id},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.activeProgramLabel.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    letterSpacing: AppSizing.homeEyebrowLetterSpacing,
                  ),
                ),
                AppWhiteSpace.hSm,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        programme.name,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AppWhiteSpace.wSm,
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        AppStrings.weekOf(displayedWeek, totalWeeks),
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                AppWhiteSpace.hMd,
                LinearProgressIndicator(
                  value: progress,
                  minHeight: AppSizing.homeProgrammeTrackHeight,
                  color: context.colorScheme.secondary,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                AppWhiteSpace.hControlGap,
                Text(
                  AppStrings.sessionsRemainingThisWeek(sessionsRemaining ?? 0),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
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

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  static const int _columnCount = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.md) / _columnCount;
        return Wrap(
          key: const Key('home_quick_actions'),
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox.square(
              dimension: tileWidth,
              child: const _ActionTile(
                key: Key('home_generate_workout_action'),
                icon: OutlinedSvgAssets.sparkles,
                label: AppStrings.generateWorkout,
              ),
            ),
            SizedBox.square(
              dimension: tileWidth,
              child: _ActionTile(
                key: const Key('home_manual_log_action'),
                icon: OutlinedSvgAssets.materialEditNote,
                label: AppStrings.manualLog,
                onTap: () {
                  context.pushNamed(AppRoutes.workoutBuilderCreate().name);
                },
              ),
            ),
            SizedBox.square(
              dimension: tileWidth,
              child: const _ActionTile(
                key: Key('home_log_bodyweight_action'),
                icon: OutlinedSvgAssets.scale,
                label: AppStrings.logBodyweight,
              ),
            ),
            SizedBox.square(
              dimension: tileWidth,
              child: const _ActionTile(
                key: Key('home_progress_photo_action'),
                icon: OutlinedSvgAssets.camera,
                label: AppStrings.progressPhoto,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isEnabled
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.65);
    return Semantics(
      button: true,
      enabled: isEnabled,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? context.colorScheme.surfaceContainerLow
              : context.colorScheme.surfaceContainerLowest,
          border: Border.all(color: context.colorScheme.surfaceContainerLow),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: AppSpacing.md,
              offset: const Offset(0, AppSpacing.xs),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSizing.homeQuickActionIconSize,
                    height: AppSizing.homeQuickActionIconSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: AppSizing.iconLg,
                      height: AppSizing.iconLg,
                      colorFilter: ColorFilter.mode(
                        isEnabled ? context.colorScheme.secondary : foreground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppWhiteSpace.hControlGap,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMd.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
