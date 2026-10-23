import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/workout_detail_exercise_flow.dart';
import 'package:aedify/features/programmes/presentation/widgets/workout_detail_style.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Reviews a saved or scheduled workout before starting or resuming its session.
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
    this.programId,
  });

  final String workoutId;
  final String? programId;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  bool _openingRoute = false;

  Future<void> _reload() => ref
      .read(
        AppProviders.workoutDetailControllerProvider((
          programId: widget.programId,
          workoutId: widget.workoutId,
        )).notifier,
      )
      .reload();

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.workout().name);
    }
  }

  Future<void> _openRunner(WorkoutDetailButtonState buttonState) async {
    if (_openingRoute || buttonState == WorkoutDetailButtonState.hidden) return;
    setState(() => _openingRoute = true);
    try {
      if (buttonState == WorkoutDetailButtonState.resume) {
        await context.pushNamed(AppRoutes.workoutRunnerActive().name);
      } else if (widget.programId != null) {
        await context.pushNamed(
          AppRoutes.workoutRunnerProgramWorkout().name,
          pathParameters: {
            'programId': widget.programId!,
            'workoutId': widget.workoutId,
          },
        );
      } else {
        await context.pushNamed(
          AppRoutes.workoutRunnerSavedWorkout().name,
          pathParameters: {'id': widget.workoutId},
        );
      }
      if (mounted) await _reload();
    } finally {
      if (mounted) setState(() => _openingRoute = false);
    }
  }

  Future<void> _openExercise(int exerciseId) async {
    if (_openingRoute) return;
    setState(() => _openingRoute = true);
    try {
      await context.pushNamed(
        AppRoutes.exerciseDetail().name,
        pathParameters: {'id': exerciseId.toString()},
      );
      if (mounted) await _reload();
    } finally {
      if (mounted) setState(() => _openingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      AppProviders.workoutDetailControllerProvider((
        programId: widget.programId,
        workoutId: widget.workoutId,
      )),
    );
    final detail = detailAsync.asData?.value;

    return Scaffold(
      key: const Key('workout_detail_screen'),
      backgroundColor: context.colorScheme.surface,
      bottomNavigationBar:
          detail == null ||
              detail.buttonState == WorkoutDetailButtonState.hidden
          ? null
          : _WorkoutAction(
              state: detail.buttonState,
              isBusy: _openingRoute || detailAsync.isLoading,
              onPressed: () => _openRunner(detail.buttonState),
            ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppWorkoutDetailTokens.maxContentWidth,
            ),
            child: Column(
              children: [
                _WorkoutHeader(onBack: _goBack),
                Expanded(
                  child: detailAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: AppStrings.loading,
                      ),
                    ),
                    error: (_, _) => _WorkoutMessage(
                      icon: OutlinedSvgAssets.exclamationCircle,
                      message: AppStrings.workoutDetailLoadError,
                      onRetry: _reload,
                    ),
                    data: (detail) => detail == null
                        ? const _WorkoutMessage(
                            icon: OutlinedSvgAssets.informationCircle,
                            message: AppStrings.missingSession,
                          )
                        : RefreshIndicator(
                            onRefresh: _reload,
                            child: CustomScrollView(
                              key: const Key('workout_detail_scroll_view'),
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _WorkoutOverview(detail: detail),
                                        AppWhiteSpace.hXl,
                                        Semantics(
                                          header: true,
                                          child: Text(
                                            AppStrings.workoutFlow,
                                            key: const Key(
                                              'workout_detail_flow_heading',
                                            ),
                                            style: WorkoutDetailStyle.heading(
                                              context,
                                            ),
                                          ),
                                        ),
                                        AppWhiteSpace.hSm,
                                        Text(
                                          AppStrings.workoutFlowHint,
                                          style: WorkoutDetailStyle.small(
                                            context,
                                          ),
                                        ),
                                        AppWhiteSpace.hLg,
                                        if (detail.exercises.isEmpty)
                                          const _WorkoutMessage(
                                            icon: OutlinedSvgAssets.listBullet,
                                            message:
                                                AppStrings.noExercisesInWorkout,
                                          )
                                        else
                                          WorkoutDetailExerciseFlow(
                                            key: ValueKey((
                                              widget.programId,
                                              widget.workoutId,
                                            )),
                                            exercises: detail.exercises,
                                            onExerciseTap: _openExercise,
                                          ),
                                        AppWhiteSpace.hLg,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('workout_detail_back'),
            tooltip: AppStrings.backLabel,
            onPressed: onBack,
            style: IconButton.styleFrom(
              minimumSize: const Size.square(
                AppWorkoutDetailTokens.controlSize,
              ),
              backgroundColor: context.colorScheme.surfaceContainerLow,
            ),
            icon: SvgPicture.asset(
              OutlinedSvgAssets.arrowLeft,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              matchTextDirection: true,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              AppStrings.workoutDetail,
              textAlign: TextAlign.center,
              style: WorkoutDetailStyle.label(
                context,
              ).copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(
            width: AppWorkoutDetailTokens.controlSize + AppSpacing.sm,
          ),
        ],
      ),
    );
  }
}

class _WorkoutOverview extends StatelessWidget {
  const _WorkoutOverview({required this.detail});

  final ProgrammeWorkoutDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final setCount = detail.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
    return Container(
      key: const Key('workout_detail_hero'),
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
          if ((detail.programmeName?.trim().isNotEmpty ?? false) ||
              detail.dayLabel.trim().isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (detail.programmeName?.trim().isNotEmpty ?? false)
                  AppBadge(
                    label: detail.programmeName!,
                    textStyle: WorkoutDetailStyle.caption(context),
                    backgroundColor: context.colorScheme.surfaceContainerHigh,
                    foregroundColor: WorkoutDetailStyle.accent(context),
                    borderRadius: AppRadius.full,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.controlGap,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                if (detail.dayLabel.trim().isNotEmpty)
                  Text(
                    detail.dayLabel,
                    style: WorkoutDetailStyle.small(context),
                  ),
              ],
            ),
            AppWhiteSpace.hMd,
          ],
          Semantics(
            header: true,
            child: Text(
              detail.workoutName,
              style: AppTextStyles.headlineLg.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppWhiteSpace.hLg,
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText =
                  MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
                  AppFontSizes.lg;
              final useRow =
                  !largeText &&
                  constraints.maxWidth >=
                      AppSizing.metricTileMinWidth * 3 + AppSpacing.sm * 2;
              final tileWidth = useRow
                  ? (constraints.maxWidth - AppSpacing.sm * 2) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.md,
                children: [
                  _WorkoutMetric(
                    width: tileWidth,
                    value: detail.exercises.length.toString(),
                    label: AppStrings.movements,
                  ),
                  _WorkoutMetric(
                    width: tileWidth,
                    value: setCount.toString(),
                    label: AppStrings.workoutTotalSets,
                  ),
                  _WorkoutMetric(
                    width: tileWidth,
                    value: detail.durationMinutes > 0
                        ? '${detail.durationMinutes} ${AppStrings.durationUnit}'
                        : AppStrings.unavailableValue,
                    label: AppStrings.workoutEstimatedDuration,
                  ),
                ],
              );
            },
          ),
          if (detail.focusAreas.trim().isNotEmpty) ...[
            AppWhiteSpace.hLg,
            Text(
              '${AppStrings.focusLabel}: ${detail.focusAreas}',
              style: WorkoutDetailStyle.small(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkoutMetric extends StatelessWidget {
  const _WorkoutMetric({
    required this.width,
    required this.value,
    required this.label,
  });

  final double width;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: WorkoutDetailStyle.heading(context)),
          AppWhiteSpace.hXs,
          Text(label, style: WorkoutDetailStyle.caption(context)),
        ],
      ),
    );
  }
}

class _WorkoutAction extends StatelessWidget {
  const _WorkoutAction({
    required this.state,
    required this.isBusy,
    required this.onPressed,
  });

  final WorkoutDetailButtonState state;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = WorkoutDetailStyle.actionForeground(context);
    return ColoredBox(
      color: context.colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppWorkoutDetailTokens.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: FilledButton(
                key: const Key('workout_detail_primary_action'),
                onPressed: isBusy ? null : onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: WorkoutDetailStyle.actionFill(context),
                  foregroundColor: foreground,
                  disabledBackgroundColor:
                      context.colorScheme.surfaceContainerHigh,
                  disabledForegroundColor: context.colorScheme.onSurfaceVariant,
                  minimumSize: const Size.fromHeight(
                    AppWorkoutDetailTokens.controlSize + AppSpacing.sm,
                  ),
                  textStyle: WorkoutDetailStyle.label(
                    context,
                  ).copyWith(inherit: false),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isBusy)
                      SizedBox(
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizing.strokeWidth,
                          color: context.colorScheme.onSurfaceVariant,
                          semanticsLabel: AppStrings.loading,
                        ),
                      )
                    else
                      SvgPicture.asset(
                        OutlinedSvgAssets.play,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          foreground,
                          BlendMode.srcIn,
                        ),
                      ),
                    AppWhiteSpace.wSm,
                    Flexible(
                      child: Text(
                        state == WorkoutDetailButtonState.resume
                            ? AppStrings.resumeWorkout
                            : AppStrings.startWorkout,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutMessage extends StatelessWidget {
  const _WorkoutMessage({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final String icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            message,
            textAlign: TextAlign.center,
            style: WorkoutDetailStyle.body(context),
          ),
          if (onRetry != null) ...[
            AppWhiteSpace.hMd,
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppWorkoutDetailTokens.controlSize,
                ),
                foregroundColor: WorkoutDetailStyle.actionForeground(context),
                backgroundColor: WorkoutDetailStyle.actionFill(context),
                textStyle: WorkoutDetailStyle.label(
                  context,
                ).copyWith(inherit: false),
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
