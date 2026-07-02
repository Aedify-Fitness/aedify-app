import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(AppProviders.profileControllerProvider);
    final programmeState = ref.watch(
      AppProviders.programmeLibraryControllerProvider,
    );

    final name = profileState.asData?.value.profile?.displayName ?? 'there';
    final programmes = programmeState.asData?.value.items ?? [];
    final activeProgramme = programmes.cast<ProgrammeListItem?>().firstWhere(
      (p) => p?.active == true,
      orElse: () => null,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _GreetingRow(name: name),
            const SizedBox(height: AppSpacing.lg),
            const _PlateauBanner(),
            const SizedBox(height: AppSpacing.lg),
            if (activeProgramme != null) ...[
              _ActiveProgramCard(programme: activeProgramme),
              const SizedBox(height: AppSpacing.lg),
            ],
            _TodayWorkoutCard(activeProgramme: activeProgramme),
            const SizedBox(height: AppSpacing.lg),
            const _VolumeMetricCard(),
            const SizedBox(height: AppSpacing.lg),
            const _QuickActionGrid(),
          ],
        ),
      ),
    );
  }
}

// ─── Section 1: Greeting ────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.name});

  final String name;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return AppStrings.goodMorning;
    if (hour >= 12 && hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, $name',
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.readyForSession,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _StreakBadge(),
      ],
    );
  }
}

class _StreakBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _computeStreak(ref);
    if (streak == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$streak ${AppStrings.dayStreak}',
            style: context.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  int _computeStreak(WidgetRef ref) {
    // TODO: M5 — compute actual streak from completed workout history
    return 0;
  }
}

// ─── Section 2: Plateau Alert ────────────────────────────────────

class _PlateauBanner extends StatelessWidget {
  const _PlateauBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colorScheme.error.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.exclamationTriangle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onErrorContainer,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.plateauAlert,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.plateauComingSoon,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section 3: Active Program ───────────────────────────────────

class _ActiveProgramCard extends StatelessWidget {
  const _ActiveProgramCard({required this.programme});

  final ProgrammeListItem programme;

  @override
  Widget build(BuildContext context) {
    final totalWeeks = programme.weeksTotal ?? 0;
    final currentWeek = 1; // TODO: compute from startDate
    final progress = totalWeeks > 0 ? currentWeek / totalWeeks : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.activeProgramLabel.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    programme.name,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                Text(
                  AppStrings.weekOf(currentWeek, totalWeeks),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${programme.daysPerWeek ?? 0} ${AppStrings.sessionsRemaining}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section 4: Today's Workout ──────────────────────────────────

class _TodayWorkoutCard extends ConsumerStatefulWidget {
  const _TodayWorkoutCard({this.activeProgramme});

  final ProgrammeListItem? activeProgramme;

  @override
  ConsumerState<_TodayWorkoutCard> createState() => _TodayWorkoutCardState();
}

class _TodayWorkoutCardState extends ConsumerState<_TodayWorkoutCard> {
  _ProgrammeDetail? _detail;
  String? _programWorkoutId;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void didUpdateWidget(covariant _TodayWorkoutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeProgramme?.id != widget.activeProgramme?.id) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    final id = widget.activeProgramme?.id;
    if (id == null) return;
    final repo = ref.read(AppProviders.programmeRepositoryProvider);
    final aggregate = await repo.getProgramme(id);
    if (!mounted) return;
    if (aggregate != null) {
      final totalExercises = aggregate.exercises.length;
      final totalDuration = aggregate.templates.fold<int>(
        0,
        (sum, t) => sum + (t.estimatedDurationMinutes ?? 0),
      );
      final todayIndex = DateTime.now().weekday - 1;
      final todayWorkout = aggregate.workouts.cast<dynamic>().firstWhere(
        (w) => (w as dynamic).scheduledDayIndex == todayIndex,
        orElse: () => null,
      );
      setState(() {
        _detail = _ProgrammeDetail(
          exerciseCount: totalExercises,
          durationMinutes: totalDuration,
        );
        _programWorkoutId = todayWorkout?.id?.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(30),
            blurRadius: AppRadius.lg,
          ),
        ],
      ),
      child: widget.activeProgramme != null
          ? _ScheduledView(
              activeProgramme: widget.activeProgramme!,
              exerciseCount: _detail?.exerciseCount ?? 0,
              durationMinutes: _detail?.durationMinutes ?? 0,
              programWorkoutId: _programWorkoutId,
            )
          : const _EmptyView(),
    );
  }
}

class _ScheduledView extends StatelessWidget {
  const _ScheduledView({
    required this.activeProgramme,
    required this.exerciseCount,
    required this.durationMinutes,
    this.programWorkoutId,
  });

  final ProgrammeListItem activeProgramme;
  final int exerciseCount;
  final int durationMinutes;
  final String? programWorkoutId;

  @override
  Widget build(BuildContext context) {
    final name = activeProgramme.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(label: AppStrings.scheduledToday.toUpperCase()),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          style: context.textTheme.headlineLarge?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _MetaChip(
              icon: OutlinedSvgAssets.clock,
              label: '$durationMinutes min',
            ),
            const SizedBox(width: AppSpacing.md),
            _MetaChip(
              icon: OutlinedSvgAssets.sparkles,
              label: '$exerciseCount Exercises',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            FilledButton.icon(
              onPressed: programWorkoutId != null
                  ? () {
                      context.pushNamed(
                        AppRoutes.workoutRunnerProgramWorkout().name,
                        pathParameters: {
                          'programId': activeProgramme.id,
                          'workoutId': programWorkoutId!,
                        },
                      );
                    }
                  : null,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  programWorkoutId != null
                      ? context.colorScheme.onSecondary
                      : context.colorScheme.onSecondary.withAlpha(128),
                  BlendMode.srcIn,
                ),
              ),
              label: Text(AppStrings.startWorkout),
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.secondary,
                foregroundColor: context.colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  AppRoutes.programmeCalendar().name,
                  pathParameters: {'id': activeProgramme.id},
                );
              },
              child: Text(
                AppStrings.viewDetails,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.noActiveProgramme,
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.noActiveProgrammeHint,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onPrimary.withAlpha(179),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () {
            final shell = StatefulNavigationShell.of(context);
            shell.goBranch(2);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.colorScheme.onPrimary),
            foregroundColor: context.colorScheme.onPrimary,
          ),
          child: const Text(AppStrings.browseProgrammes),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: AppSizing.iconXs,
          height: AppSizing.iconXs,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onPrimary.withAlpha(179),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Section 5: Volume Metric ────────────────────────────────────

class _VolumeMetricCard extends StatelessWidget {
  const _VolumeMetricCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.volumeThisWeek.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('—', style: AppTextStyles.headlineMd),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.volumeTrackingComingSoon,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                OutlinedSvgAssets.chartBar,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section 6: Quick Action Grid ────────────────────────────────

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionTile(
          icon: OutlinedSvgAssets.sparkles,
          label: AppStrings.generateWorkout,
          onTap: () => _showComingSoon(context),
        ),
        _ActionTile(
          icon: OutlinedSvgAssets.pencilSquare,
          label: AppStrings.manualLog,
          onTap: () {
            context.pushNamed(AppRoutes.workoutBuilderCreate().name);
          },
        ),
        _ActionTile(
          icon: OutlinedSvgAssets.scale,
          label: AppStrings.logBodyweight,
          onTap: () => _showComingSoon(context),
        ),
        _ActionTile(
          icon: OutlinedSvgAssets.camera,
          label: AppStrings.progressPhoto,
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.comingSoon)));
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  icon,
                  width: AppSizing.iconLg,
                  height: AppSizing.iconLg,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: context.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgrammeDetail {
  const _ProgrammeDetail({
    required this.exerciseCount,
    required this.durationMinutes,
  });

  final int exerciseCount;
  final int durationMinutes;
}
