import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reviews the saved workout before resuming or abandoning its session.
class WorkoutRunnerResumeBanner extends StatefulWidget {
  const WorkoutRunnerResumeBanner({
    super.key,
    required this.session,
    required this.onResume,
    required this.onDiscard,
    this.errorMessage,
    this.onRetry,
  });

  final WorkoutRunnerSessionViewData session;
  final Future<void> Function() onResume;
  final Future<void> Function() onDiscard;
  final String? errorMessage;
  final Future<void> Function()? onRetry;

  @override
  State<WorkoutRunnerResumeBanner> createState() =>
      _WorkoutRunnerResumeBannerState();
}

class _WorkoutRunnerResumeBannerState extends State<WorkoutRunnerResumeBanner> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.session.exercises;
    final sets = exercises.expand((exercise) => exercise.sets).toList();
    final completedSets = sets.where((set) => set.completed).length;
    final progress = sets.isEmpty ? 0.0 : completedSets / sets.length;
    final completedExercises = exercises
        .where(
          (exercise) =>
              exercise.sets.isNotEmpty &&
              exercise.sets.every((set) => set.completed),
        )
        .length;
    const resolver = WorkoutRunnerBlockResolver();
    final lead = resolver.firstIncompleteExercise(exercises);
    final current = lead == null
        ? null
        : resolver
              .firstIncompleteSet(resolver.blockFor(exercises, lead))
              ?.exercise;
    final elapsed = widget.session.durationSeconds ?? 0;
    final seconds = elapsed < 0 ? 0 : elapsed;
    final timeString =
        '${(seconds ~/ Duration.secondsPerMinute).toString().padLeft(2, '0')}:'
        '${seconds.remainder(Duration.secondsPerMinute).toString().padLeft(2, '0')}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppWorkoutRunnerTokens.resumeMaxContentWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _HeaderSection(),
              AppWhiteSpace.hXxl,
              if (widget.errorMessage != null) ...[
                WorkoutRunnerErrorBanner(
                  message: widget.errorMessage!,
                  onRetry: _busy || widget.onRetry == null
                      ? null
                      : () => _run(widget.onRetry!),
                ),
                AppWhiteSpace.hLg,
              ],
              _ResumeSummaryCard(
                name: widget.session.name,
                timeString: timeString,
                completedExercises: completedExercises,
                totalExercises: exercises.length,
                current: current,
                showProgress: sets.isNotEmpty,
                progress: progress,
              ),
              AppWhiteSpace.hXxl,
              _ActionSection(
                busy: _busy,
                onResume: () => _run(widget.onResume),
                onDiscard: () => _run(widget.onDiscard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _ResumeLayout {
  static bool stacksContent(BuildContext context) =>
      MediaQuery.sizeOf(context).width <
          AppWorkoutRunnerTokens.stackedHeaderBreakpoint ||
      MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
          AppFontSizes.sm * AppWorkoutRunnerTokens.largeTextBreakpoint;
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        header: true,
        child: Text(
          AppStrings.sessionInProgress,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
      AppWhiteSpace.hMd,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          AppStrings.resumeSessionSubtitle,
          textAlign: TextAlign.center,
          style: WorkoutRunnerStyle.body(context).copyWith(
            fontSize: AppFontSizes.lg,
            height: AppTextStyles.bodyLg.height,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class _ResumeSummaryCard extends StatelessWidget {
  const _ResumeSummaryCard({
    required this.name,
    required this.timeString,
    required this.completedExercises,
    required this.totalExercises,
    required this.current,
    required this.showProgress,
    required this.progress,
  });

  final String name;
  final String timeString;
  final int completedExercises;
  final int totalExercises;
  final WorkoutRunnerExerciseItem? current;
  final bool showProgress;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final compact = _ResumeLayout.stacksContent(context);
    final cs = context.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AedifyLightColors.onPrimary.withValues(
            alpha: AppWorkoutRunnerTokens.resumeBorderOpacity,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(
              alpha: AppWorkoutRunnerTokens.shadowOpacity,
            ),
            blurRadius: AppSpacing.formSectionGap,
            offset: const Offset(0, AppSpacing.controlGap),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.md : AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            _StatusRow(name: name),
            AppWhiteSpace.hXl,
            _StatsGrid(
              timeString: timeString,
              completedExercises: completedExercises,
              totalExercises: totalExercises,
              stacked: compact,
            ),
            if (current != null) ...[
              AppWhiteSpace.hXl,
              const Divider(
                height: AppSizing.divider,
                thickness: AppSizing.divider,
              ),
              AppWhiteSpace.hLg,
              _CurrentFocusRow(
                exerciseName: current!.exerciseName,
                showProgress: showProgress,
                progress: progress,
                stacked: compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.inProgressLabel.toUpperCase(),
              style: WorkoutRunnerStyle.caption(context).copyWith(
                color: context.colorScheme.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: AppWorkoutRunnerTokens.eyebrowLetterSpacing,
              ),
            ),
            AppWhiteSpace.hXs,
            Text(name, style: WorkoutRunnerStyle.heading(context)),
          ],
        ),
      ),
      AppWhiteSpace.wSm,
      ExcludeSemantics(
        child: Container(
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              OutlinedSvgAssets.clock,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.timeString,
    required this.completedExercises,
    required this.totalExercises,
    required this.stacked,
  });
  final String timeString;
  final int completedExercises;
  final int totalExercises;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final elapsed = _StatTile(
      label: AppStrings.timeElapsed,
      compact: stacked,
      child: Text(timeString, style: WorkoutRunnerStyle.heading(context)),
    );
    final exercises = _StatTile(
      label: AppStrings.exercisesCompleted,
      compact: stacked,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$completedExercises'),
            TextSpan(
              text: ' ${AppStrings.runnerExerciseTotal(totalExercises)}',
              style: WorkoutRunnerStyle.body(context).copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        style: WorkoutRunnerStyle.heading(context),
        semanticsLabel: AppStrings.runnerExerciseFraction(
          completedExercises,
          totalExercises,
        ),
      ),
    );
    return stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [elapsed, AppWhiteSpace.hSm, exercises],
          )
        : Row(
            children: [
              Expanded(child: elapsed),
              AppWhiteSpace.wSm,
              Expanded(child: exercises),
            ],
          );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.child,
    required this.compact,
  });
  final String label;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? AppSpacing.sm : AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow.withValues(
        alpha: AppWorkoutRunnerTokens.resumeSubtleOpacity,
      ),
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: WorkoutRunnerStyle.caption(context)),
        AppWhiteSpace.hXs,
        child,
      ],
    ),
  );
}

class _CurrentFocusRow extends StatelessWidget {
  const _CurrentFocusRow({
    required this.exerciseName,
    required this.showProgress,
    required this.progress,
    required this.stacked,
  });
  final String exerciseName;
  final bool showProgress;
  final double progress;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final focus = Row(
      children: [
        ExcludeSemantics(
          child: Container(
            width: AppSpacing.xxxl,
            height: AppSpacing.xxxl,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            ),
            child: Center(
              child: SvgPicture.asset(
                OutlinedSvgAssets.bolt,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant.withValues(
                    alpha: AppWorkoutRunnerTokens.resumeSubtleOpacity,
                  ),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.currentExercise,
                style: WorkoutRunnerStyle.caption(context),
              ),
              AppWhiteSpace.hXxs,
              Text(
                exerciseName,
                style: WorkoutRunnerStyle.label(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
    final progressWidget = _FocusProgress(progress: progress);
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          focus,
          if (showProgress) ...[AppWhiteSpace.hMd, progressWidget],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: focus),
        if (showProgress)
          SizedBox(width: AppSpacing.xxl * 2, child: progressWidget),
      ],
    );
  }
}

class _FocusProgress extends StatelessWidget {
  const _FocusProgress({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      LinearProgressIndicator(
        value: progress,
        minHeight: AppWorkoutRunnerTokens.progressTrackHeight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        backgroundColor: context.colorScheme.surfaceContainerHighest,
        color: context.colorScheme.secondary,
        semanticsLabel: AppStrings.progressLabel,
      ),
      AppWhiteSpace.hXs,
      Text(
        AppStrings.runnerProgressPercent((progress * 100).round()),
        textAlign: TextAlign.end,
        style: WorkoutRunnerStyle.caption(context).copyWith(
          color: context.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.busy,
    required this.onResume,
    required this.onDiscard,
  });
  final bool busy;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : onResume,
          icon: busy
              ? SizedBox(
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizing.strokeWidth,
                    semanticsLabel: AppStrings.loading,
                    color: cs.onSecondary,
                  ),
                )
              : SvgPicture.asset(
                  OutlinedSvgAssets.play,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    cs.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
          label: const Text(AppStrings.resumeWorkout),
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondary,
            foregroundColor: cs.onSecondary,
            minimumSize: const Size.fromHeight(
              AppWorkoutRunnerTokens.controlSize,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            textStyle: WorkoutRunnerStyle.label(
              context,
            ).copyWith(inherit: false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            ),
          ),
        ),
        AppWhiteSpace.hSm,
        OutlinedButton.icon(
          onPressed: busy ? null : onDiscard,
          icon: SvgPicture.asset(
            OutlinedSvgAssets.trash,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
          ),
          label: const Text(AppStrings.abandonWorkout),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.onSurfaceVariant,
            side: BorderSide(
              color: cs.surfaceContainerHighest,
              width: AppSizing.strokeWidth,
            ),
            minimumSize: const Size.fromHeight(
              AppWorkoutRunnerTokens.controlSize,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            textStyle: WorkoutRunnerStyle.label(
              context,
            ).copyWith(inherit: false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            ),
          ),
        ),
      ],
    );
  }
}
