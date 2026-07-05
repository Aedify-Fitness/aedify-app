import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class FinishEarlySessionCompleteScreen extends ConsumerWidget {
  const FinishEarlySessionCompleteScreen({super.key, required this.session});

  final WorkoutRunnerSessionViewData session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAt = session.completedAt ?? DateTime.now();
    final durationSeconds =
        session.durationSeconds ??
        completedAt.difference(session.startedAt).inSeconds;
    final totalVolume = _computeTotalVolume();
    final completedExCount = _computeCompletedExercises();
    final totalExCount = session.exercises.length;
    final progress = totalExCount > 0 ? completedExCount / totalExCount : 0.0;
    final percentage = _computePercentage();
    final preferredUnit =
        ref
            .watch(AppProviders.profileControllerProvider)
            .asData
            ?.value
            .profile
            ?.preferredUnits ??
        PreferredUnit.metric;
    final weightUnit = preferredUnit.weightUnit;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: context.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppWhiteSpace.hXl,
            Text(
              AppStrings.sessionComplete,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineXl.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.80,
                height: 1.20,
              ),
            ),
            AppWhiteSpace.hSm,
            Text(
              session.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLg.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            AppWhiteSpace.hSm,
            Text(
              AppStrings.finishEarly,
              style: AppTextStyles.bodyLg.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colorScheme.secondary,
              ),
            ),
            AppWhiteSpace.custom(height: AppSpacing.xxl - AppSpacing.sm),
            _StatsGrid(
              durationSeconds: durationSeconds,
              totalVolume: totalVolume,
              completedExercises: completedExCount,
              totalExercises: totalExCount,
              progress: progress,
              weightUnit: weightUnit,
            ),
            AppWhiteSpace.hXxl,
            _WorkoutSummarySection(
              exercises: session.exercises,
              weightUnit: weightUnit,
            ),
            AppWhiteSpace.hXxl,
            _InsightCard(percentage: percentage),
            AppWhiteSpace.hXxl,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                ),
                child: Text(AppStrings.done, style: AppTextStyles.labelMd),
              ),
            ),
            AppWhiteSpace.hXl,
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }

  double _computeTotalVolume() {
    var volume = 0.0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.completed &&
            set.actualWeightKg != null &&
            set.actualReps != null) {
          volume += set.actualWeightKg! * set.actualReps!;
        }
      }
    }
    return volume;
  }

  int _computeCompletedExercises() {
    var count = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.completed) {
          count++;
          break;
        }
      }
    }
    return count;
  }

  int _computePercentage() {
    var allHavePrescribed = true;
    var plannedVolume = 0.0;
    var completedVolume = 0.0;
    var totalSets = 0;
    var completedSets = 0;

    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        totalSets++;
        if (set.completed) completedSets++;

        if (set.prescribedWeightKg == null) {
          allHavePrescribed = false;
        } else {
          final reps =
              set.prescribedRepsExact ??
              set.prescribedRepsMin ??
              set.prescribedRepsMax;
          if (reps == null) {
            allHavePrescribed = false;
          } else {
            plannedVolume += set.prescribedWeightKg! * reps;
          }
        }

        if (set.completed &&
            set.actualWeightKg != null &&
            set.actualReps != null) {
          completedVolume += set.actualWeightKg! * set.actualReps!;
        }
      }
    }

    if (allHavePrescribed && plannedVolume > 0) {
      return (completedVolume / plannedVolume * 100).round().clamp(0, 100);
    }
    if (totalSets > 0) {
      return (completedSets / totalSets * 100).round().clamp(0, 100);
    }
    return 0;
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.durationSeconds,
    required this.totalVolume,
    required this.completedExercises,
    required this.totalExercises,
    required this.progress,
    required this.weightUnit,
  });

  final int durationSeconds;
  final double totalVolume;
  final int completedExercises;
  final int totalExercises;
  final double progress;
  final String weightUnit;

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String _formatVolume(double volume) {
    final rounded = volume.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: AppStrings.duration,
                child: Text(
                  _formatDuration(durationSeconds),
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: _StatCard(
                label: AppStrings.totalVolume,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatVolume(totalVolume),
                      style: AppTextStyles.headlineMd.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    AppWhiteSpace.wXs,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        weightUnit,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        _StatCard(
          label: AppStrings.exercisesCompleted,
          child: Row(
            children: [
              Text(
                '$completedExercises/$totalExercises',
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
              AppWhiteSpace.wSm,
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: context.colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation(
                      context.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withAlpha(128),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hXs,
          child,
        ],
      ),
    );
  }
}

class _WorkoutSummarySection extends StatelessWidget {
  const _WorkoutSummarySection({
    required this.exercises,
    required this.weightUnit,
  });

  final List<WorkoutRunnerExerciseItem> exercises;
  final String weightUnit;

  double _exerciseVolume(WorkoutRunnerExerciseItem exercise) {
    var volume = 0.0;
    for (final set in exercise.sets) {
      if (set.completed &&
          set.actualWeightKg != null &&
          set.actualReps != null) {
        volume += set.actualWeightKg! * set.actualReps!;
      }
    }
    return volume;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.workoutSummary,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hLg,
        ...exercises.map((exercise) {
          final hasCompleted = exercise.sets.any((s) => s.completed);

          if (!hasCompleted) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.buttonVertical),
              child: _SkippedExerciseCard(exercise: exercise),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.buttonVertical),
            child: _CompletedExerciseCard(
              exercise: exercise,
              volume: _exerciseVolume(exercise),
              weightUnit: weightUnit,
            ),
          );
        }),
      ],
    );
  }
}

class _CompletedExerciseCard extends StatelessWidget {
  const _CompletedExerciseCard({
    required this.exercise,
    required this.volume,
    required this.weightUnit,
  });

  final WorkoutRunnerExerciseItem exercise;
  final double volume;
  final String weightUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppSizing.handleWidth,
            height: AppSizing.handleWidth,
            decoration: BoxDecoration(
              color: context.colorScheme.secondary.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: SvgPicture.asset(
                SolidSvgAssets.checkCircle,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
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
                  exercise.exerciseName,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  '${exercise.sets.length} sets \u2022 ${_formatVolume(volume)} $weightUnit volume',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppStrings.done,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    final rounded = volume.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _SkippedExerciseCard extends StatelessWidget {
  const _SkippedExerciseCard({required this.exercise});

  final WorkoutRunnerExerciseItem exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Row(
          children: [
            Container(
              width: AppSizing.handleWidth,
              height: AppSizing.handleWidth,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Center(
                child: Icon(
                  Icons.block,
                  size: AppSizing.iconSm,
                  color: context.colorScheme.outline,
                ),
              ),
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                  AppWhiteSpace.hXs,
                  Text(
                    '${AppStrings.planned}: ${exercise.sets.length} sets',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppStrings.skipped,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colorScheme.secondary.withAlpha(26)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withAlpha(13),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.leaf,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: AppSpacing.buttonVertical),
                  Text(
                    AppStrings.aedifyInsight,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hLg,
              Text(
                AppStrings.recoveryIsProgress(percentage),
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.md),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.calendar_today,
              label: AppStrings.today,
              isSelected: false,
            ),
            _NavItem(
              icon: Icons.fitness_center,
              label: 'Programs',
              isSelected: false,
            ),
            _NavItem(
              icon: Icons.history,
              label: AppStrings.historyTab,
              isSelected: true,
            ),
            _NavItem(
              icon: Icons.person,
              label: AppStrings.profile,
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizing.iconMd,
            color: isSelected
                ? context.colorScheme.onSecondaryContainer
                : context.colorScheme.onSurfaceVariant,
          ),
          AppWhiteSpace.hXs,
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isSelected
                  ? context.colorScheme.onSecondaryContainer
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
