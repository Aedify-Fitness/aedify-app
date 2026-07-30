import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/components/app_section_header.dart';
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

  double _computeWeekProgress(ProgrammeSync sync, int weekNumber) {
    final week = sync.aggregate.weeks.firstWhere(
      (week) => week.weekNumber == weekNumber,
    );
    final weekWorkoutIds = sync.aggregate.workouts
        .where((workout) => workout.programWeekId == week.id)
        .map((workout) => workout.id)
        .toSet();
    if (weekWorkoutIds.isEmpty) return 0;
    final completedInWeek = weekWorkoutIds
        .where(sync.resolution.completedWorkoutIds.contains)
        .length;
    return completedInWeek / weekWorkoutIds.length;
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
    final weekProgress = sync != null && currentWeek != null
        ? _computeWeekProgress(sync, currentWeek)
        : 0.0;
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

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: AppSizing.navBarHeight + AppSpacing.xxl,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
              ),
              child: _GreetingHeader(name: displayName),
            ),
            AppWhiteSpace.hLg,
            if (activeSession != null)
              _OngoingWorkoutSurface(session: activeSession)
            else if (isWorkoutLoading)
              const _HomeLoadingSurface()
            else if (loadErrorMessage != null)
              _HomeErrorSurface(
                message: loadErrorMessage,
                onRetry: () {
                  ref.invalidate(
                    AppProviders.programmeLibraryControllerProvider,
                  );
                  ref.invalidate(AppProviders.activeWorkoutSessionProvider);
                  if (activeProgramme != null) {
                    ref.invalidate(
                      AppProviders.programmeSyncProvider(activeProgramme.id),
                    );
                  }
                },
              )
            else
              _TodayWorkoutSurface(
                activeProgramme: activeProgramme,
                todayWorkoutId: todayWorkoutId,
                workoutName: todayWorkoutName,
                exerciseCount: exerciseCount,
                durationMinutes: durationMinutes,
              ),
            if (activeProgramme != null && sync != null) ...[
              AppWhiteSpace.hLg,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                child: _ActiveProgrammePanel(
                  programme: activeProgramme,
                  currentWeek: currentWeek,
                  sessionsRemaining: sessionsRemaining,
                  totalWeeks: activeProgramme.weeksTotal ?? 0,
                  progress: weekProgress,
                ),
              ),
            ],
            AppWhiteSpace.hXl,
            const _TrainingSignalsSection(),
            AppWhiteSpace.hXl,
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(title: AppStrings.quickActions),
                  AppWhiteSpace.hMd,
                  _QuickActionGrid(),
                ],
              ),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineLgMobile.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hXs,
        Text(
          AppStrings.readyForSession,
          style: AppTextStyles.bodyMd.copyWith(
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
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
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
            AppWhiteSpace.wXs,
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
    // TODO: M5 - compute actual streak from completed workout history.
    return 0;
  }
}

class _WorkoutFeatureSurface extends StatelessWidget {
  const _WorkoutFeatureSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return ColoredBox(
      color: isDark
          ? context.colorScheme.surfaceContainerHigh
          : context.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: child,
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
      return _RestDaySurface(programme: activeProgramme!);
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
            style: AppTextStyles.headlineLg.copyWith(color: foreground),
          ),
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroMetaItem(
                icon: OutlinedSvgAssets.clock,
                label: '$durationMinutes ${AppStrings.minutes}',
                foreground: foreground,
              ),
              _HeroMetaItem(
                icon: OutlinedSvgAssets.clipboardDocumentList,
                label: '$exerciseCount ${AppStrings.exercisesCompleted}',
                foreground: foreground,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('home_start_workout_button'),
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
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  actionForeground,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.startWorkout),
              style: FilledButton.styleFrom(
                backgroundColor: actionBackground,
                foregroundColor: actionForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDaySurface extends StatelessWidget {
  const _RestDaySurface({required this.programme});

  final ProgrammeListItem programme;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final foreground = isDark
        ? context.colorScheme.onSurface
        : context.colorScheme.onPrimary;
    final accent = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final onAccent = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;
    return _WorkoutFeatureSurface(
      child: Column(
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
            programme.name,
            style: AppTextStyles.headlineLg.copyWith(color: foreground),
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.restDay,
            style: AppTextStyles.bodyMd.copyWith(
              color: foreground.withAlpha(179),
            ),
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
    return ColoredBox(
      color: context.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          iconAsset: OutlinedSvgAssets.clipboardDocumentList,
          title: AppStrings.noActiveProgramme,
          message: AppStrings.noActiveProgrammeHint,
          actionLabel: AppStrings.browseProgrammes,
          onAction: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(2);
          },
        ),
      ),
    );
  }
}

class _HomeLoadingSurface extends StatelessWidget {
  const _HomeLoadingSurface();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerLow,
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
    return ColoredBox(
      color: context.colorScheme.surfaceContainerLow,
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
          colorFilter: ColorFilter.mode(
            foreground.withAlpha(179),
            BlendMode.srcIn,
          ),
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
            style: AppTextStyles.headlineLg.copyWith(color: foreground),
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                '$completedSets/$totalSets ${AppStrings.setsCompleted}',
                style: AppTextStyles.labelMd.copyWith(color: foreground),
              ),
              _HeroMetaItem(
                icon: OutlinedSvgAssets.clock,
                label: '$elapsedMinutes ${AppStrings.minutes}',
                foreground: foreground,
              ),
            ],
          ),
          AppWhiteSpace.hSm,
          LinearProgressIndicator(
            value: progress,
            color: actionBackground,
            backgroundColor: foreground.withAlpha(51),
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
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  actionForeground,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.resumeWorkout),
              style: FilledButton.styleFrom(
                backgroundColor: actionBackground,
                foregroundColor: actionForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
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
                foregroundColor: foreground.withAlpha(204),
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
    final displayedWeek = currentWeek ?? (totalWeeks > 0 ? totalWeeks : 0);
    return Material(
      key: const Key('home_active_programme_panel'),
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(title: AppStrings.activeProgramLabel),
            AppWhiteSpace.hMd,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  programme.name,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppBadge(
                  label: AppStrings.programmeActive,
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                  foregroundColor: context.colorScheme.secondary,
                  borderRadius: AppRadius.full,
                ),
              ],
            ),
            AppWhiteSpace.hMd,
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                _ProgrammeMetric(
                  icon: OutlinedSvgAssets.calendarDays,
                  label: AppStrings.weekOf(displayedWeek, totalWeeks),
                ),
                _ProgrammeMetric(
                  icon: OutlinedSvgAssets.clipboardDocumentCheck,
                  label:
                      '${sessionsRemaining ?? 0} ${AppStrings.sessionsRemaining}',
                ),
              ],
            ),
            AppWhiteSpace.hMd,
            LinearProgressIndicator(
              value: progress,
              color: context.colorScheme.secondary,
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            AppWhiteSpace.hSm,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.programmeCalendar().name,
                    pathParameters: {'id': programme.id},
                  );
                },
                iconAlignment: IconAlignment.end,
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.arrowRight,
                  width: AppSizing.iconS,
                  height: AppSizing.iconS,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
                label: const Text(AppStrings.viewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeMetric extends StatelessWidget {
  const _ProgrammeMetric({required this.icon, required this.label});

  final String icon;
  final String label;

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
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrainingSignalsSection extends StatelessWidget {
  const _TrainingSignalsSection();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerLow,
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            _UtilityPanel(
              icon: OutlinedSvgAssets.chartBar,
              title: AppStrings.volumeThisWeek,
              description: AppStrings.volumeTrackingComingSoon,
            ),
            AppWhiteSpace.hMd,
            _UtilityPanel(
              icon: OutlinedSvgAssets.exclamationTriangle,
              title: AppStrings.plateauAlert,
              description: AppStrings.plateauComingSoon,
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityPanel extends StatelessWidget {
  const _UtilityPanel({
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: AppSizing.cardBadge,
                height: AppSizing.cardBadge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  icon,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppBadge(
                label: AppStrings.comingSoon,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                foregroundColor: context.colorScheme.onSurfaceVariant,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
          AppWhiteSpace.hSm,
          Text(
            description,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: tileWidth,
              child: const _ActionTile(
                icon: OutlinedSvgAssets.sparkles,
                label: AppStrings.generateWorkout,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _ActionTile(
                icon: OutlinedSvgAssets.pencilSquare,
                label: AppStrings.manualLog,
                onTap: () {
                  context.pushNamed(AppRoutes.workoutBuilderCreate().name);
                },
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: const _ActionTile(
                icon: OutlinedSvgAssets.scale,
                label: AppStrings.logBodyweight,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: const _ActionTile(
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
  const _ActionTile({required this.icon, required this.label, this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final foreground = isEnabled
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurfaceVariant.withAlpha(153);
    return Semantics(
      button: true,
      enabled: isEnabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSizing.optionCardMinHeight + AppSpacing.lg,
        ),
        child: Material(
          color: isEnabled
              ? context.colorScheme.surfaceContainer
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: AppSizing.iconXxl,
                    height: AppSizing.iconXxl,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? context.colorScheme.secondary.withAlpha(26)
                          : context.colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        isEnabled ? context.colorScheme.secondary : foreground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppWhiteSpace.hMd,
                  Text(
                    label,
                    style: AppTextStyles.labelMd.copyWith(color: foreground),
                  ),
                  AppWhiteSpace.hSm,
                  Visibility(
                    visible: !isEnabled,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: AppBadge(
                      label: AppStrings.comingSoon,
                      backgroundColor: context.colorScheme.surfaceContainerHigh,
                      foregroundColor: foreground,
                      borderRadius: AppRadius.full,
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
