import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerResumeBanner extends StatelessWidget {
  const WorkoutRunnerResumeBanner({
    super.key,
    required this.session,
    required this.onResume,
    required this.onDiscard,
  });

  final WorkoutRunnerSessionViewData session;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final elapsedSeconds = session.durationSeconds ?? 0;
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final completedSets = session.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.where((s) => s.completed).length,
    );
    final totalSets = session.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.length,
    );
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;
    final progressPercent = (progress * 100).round();

    final firstIncomplete = _firstIncomplete(session.exercises);
    final completedExercises = session.exercises
        .where((e) => e.sets.any((s) => s.completed))
        .length;
    final totalExercises = session.exercises.length;

    final showProgress = totalSets > 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              _HeaderSection(),
              const SizedBox(height: AppSpacing.xxl),
              _ResumeSummaryCard(
                name: session.name,
                timeString: timeString,
                completedExercises: completedExercises,
                totalExercises: totalExercises,
                firstIncomplete: firstIncomplete,
                showProgress: showProgress,
                progress: progress,
                progressPercent: progressPercent,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _ActionSection(onResume: onResume, onDiscard: onDiscard),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  static WorkoutRunnerExerciseItem? _firstIncomplete(
    List<WorkoutRunnerExerciseItem> exercises,
  ) {
    for (final ex in exercises) {
      for (final set in ex.sets) {
        if (!set.completed && !set.skipped) return ex;
      }
    }
    return null;
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.sessionInProgress,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            AppStrings.resumeSessionSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResumeSummaryCard extends StatelessWidget {
  const _ResumeSummaryCard({
    required this.name,
    required this.timeString,
    required this.completedExercises,
    required this.totalExercises,
    required this.firstIncomplete,
    required this.showProgress,
    required this.progress,
    required this.progressPercent,
  });

  final String name;
  final String timeString;
  final int completedExercises;
  final int totalExercises;
  final WorkoutRunnerExerciseItem? firstIncomplete;
  final bool showProgress;
  final double progress;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withAlpha(160)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withAlpha(20),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            _StatusRow(name: name),
            const SizedBox(height: AppSpacing.xl),
            _StatsGrid(
              timeString: timeString,
              completedExercises: completedExercises,
              totalExercises: totalExercises,
            ),
            if (firstIncomplete != null) ...[
              const SizedBox(height: AppSpacing.xl),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: AppSpacing.lg),
              _CurrentFocusRow(
                exerciseName: firstIncomplete!.exerciseName,
                showProgress: showProgress,
                progress: progress,
                progressPercent: progressPercent,
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.inProgressLabel.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
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
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.timeString,
    required this.completedExercises,
    required this.totalExercises,
  });

  final String timeString;
  final int completedExercises;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(label: AppStrings.timeElapsed, value: timeString),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: AppStrings.exercisesCompleted,
            valueWidget: _ExercisesValue(
              completed: completedExercises,
              total: totalExercises,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (value != null)
            Text(
              value!,
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            )
          else
            valueWidget ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _ExercisesValue extends StatelessWidget {
  const _ExercisesValue({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.headlineMd.copyWith(
          color: context.colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: '$completed'),
          TextSpan(
            text: ' of $total',
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentFocusRow extends StatelessWidget {
  const _CurrentFocusRow({
    required this.exerciseName,
    required this.showProgress,
    required this.progress,
    required this.progressPercent,
  });

  final String exerciseName;
  final bool showProgress;
  final double progress;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
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
                context.colorScheme.onSurfaceVariant.withAlpha(128),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.currentExercise,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                exerciseName,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (showProgress)
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: SizedBox(
                    width: 96,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          context.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        context.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$progressPercent% ${AppStrings.progressLabel}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.onResume, required this.onDiscard});

  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onResume,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.play,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSecondary,
                BlendMode.srcIn,
              ),
            ),
            label: Text(AppStrings.resumeWorkout),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.secondary,
              foregroundColor: context.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDiscard,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.trash,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: Text(AppStrings.abandonWorkout),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colorScheme.onSurfaceVariant,
              side: BorderSide(
                color: context.colorScheme.surfaceContainerHighest,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
