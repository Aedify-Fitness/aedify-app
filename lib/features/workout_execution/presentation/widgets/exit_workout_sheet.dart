import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ExitWorkoutSheet extends StatelessWidget {
  const ExitWorkoutSheet({
    super.key,
    required this.session,
    required this.onFinishAndSave,
    required this.onPause,
    required this.onAbandon,
    this.onClose,
  });

  final WorkoutRunnerSessionViewData session;
  final VoidCallback onFinishAndSave;
  final VoidCallback onPause;
  final VoidCallback onAbandon;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final duration = session.durationSeconds ?? 0;
    final minutes = duration ~/ 60;
    final secs = duration.remainder(60);
    final hours = duration ~/ 3600;
    final timeLabel = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final completedExercises = session.exercises
        .where((e) => e.sets.any((s) => s.completed))
        .length;
    final totalExercises = session.exercises.length;
    final progress = totalExercises > 0
        ? completedExercises / totalExercises
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 512),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140052d5),
                      blurRadius: 40,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color(0x0a0052d5),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeaderSection(),
                      const SizedBox(height: 32),
                      _SessionSummaryCard(
                        timeLabel: timeLabel,
                        completedExercises: completedExercises,
                        totalExercises: totalExercises,
                        progress: progress,
                      ),
                      const SizedBox(height: 40),
                      _ActionButtons(
                        onFinishAndSave: onFinishAndSave,
                        onPause: onPause,
                        onAbandon: onAbandon,
                      ),
                      const SizedBox(height: 32),
                      _BottomNote(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppSpacing.xxxl,
          height: AppSpacing.xxxl,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pause_circle_filled,
            color: context.colorScheme.secondary,
            size: AppSizing.iconXxl,
          ),
        ),
        AppWhiteSpace.hLg,
        Text(
          AppStrings.exitWorkoutTitle,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.primary,
          ),
        ),
        AppWhiteSpace.hSm,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            AppStrings.exitWorkoutMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({
    required this.timeLabel,
    required this.completedExercises,
    required this.totalExercises,
    required this.progress,
  });

  final String timeLabel;
  final int completedExercises;
  final int totalExercises;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.currentSession.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              letterSpacing: 1.0,
            ),
          ),
          AppWhiteSpace.hMd,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeLabel,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: context.colorScheme.secondary,
                      ),
                    ),
                    AppWhiteSpace.hXxs,
                    Text(
                      AppStrings.timeElapsed,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$completedExercises',
                          style: AppTextStyles.headlineMd.copyWith(
                            color: context.colorScheme.secondary,
                          ),
                        ),
                        AppWhiteSpace.wXs,
                        Text(
                          '/ $totalExercises',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    AppWhiteSpace.hXxs,
                    Text(
                      AppStrings.exercisesComplete,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
              valueColor: AlwaysStoppedAnimation(context.colorScheme.secondary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onFinishAndSave,
    required this.onPause,
    required this.onAbandon,
  });

  final VoidCallback onFinishAndSave;
  final VoidCallback onPause;
  final VoidCallback onAbandon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onFinishAndSave,
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.secondary,
              foregroundColor: context.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.save, size: AppSizing.iconSm),
                    AppWhiteSpace.wSm,
                    Text(AppStrings.finishAndSave),
                  ],
                ),
                const Icon(Icons.arrow_forward, size: AppSizing.iconSm),
              ],
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onPause,
                icon: Icon(
                  Icons.play_arrow,
                  size: AppSizing.iconSm,
                  color: context.colorScheme.secondary,
                ),
                label: Text(
                  AppStrings.pauseWorkout,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.surfaceContainerHigh,
                  foregroundColor: context.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                ),
              ),
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAbandon,
                icon: Icon(
                  Icons.delete_forever,
                  size: AppSizing.iconSm,
                  color: context.colorScheme.error,
                ),
                label: Text(
                  AppStrings.abandonSession,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.error,
                  side: BorderSide(color: context.colorScheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.labelSm.copyWith(
          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        children: [
          TextSpan(text: '${AppStrings.savedWorkoutsHistoryNote} '),
          TextSpan(
            text: AppStrings.historyTab,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: ' ${AppStrings.historyTabSuffix}'),
        ],
      ),
    );
  }
}
