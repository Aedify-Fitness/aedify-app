import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutCompleteScreen extends ConsumerWidget {
  const WorkoutCompleteScreen({super.key, required this.session});

  final WorkoutRunnerSessionViewData session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAt = session.completedAt ?? DateTime.now();
    final durationSeconds =
        session.durationSeconds ??
        completedAt.difference(session.startedAt).inSeconds;
    final totalVolume = _computeTotalVolume();
    final completedSets = _computeCompletedSets();
    final totalSets = _computeTotalSets();
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
      backgroundColor: context.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: context.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _HeroSection(workoutName: session.name),
            const SizedBox(height: 32),
            _MetricsRow(
              durationSeconds: durationSeconds,
              totalVolume: totalVolume,
              completedSets: completedSets,
              totalSets: totalSets,
              weightUnit: weightUnit,
            ),
            const SizedBox(height: 24),
            _InsightCard(),
            const SizedBox(height: 24),
            _ExerciseSummarySection(
              exercises: session.exercises,
              weightUnit: weightUnit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionsLayer(
        onDone: () => Navigator.of(context).pop(),
        onShare: () {},
      ),
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

  int _computeCompletedSets() {
    var count = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.completed) count++;
      }
    }
    return count;
  }

  int _computeTotalSets() {
    var count = 0;
    for (final exercise in session.exercises) {
      count += exercise.sets.length;
    }
    return count;
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.workoutName});

  final String workoutName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PulsingCheckCircle(),
        const SizedBox(height: 16),
        Text(
          AppStrings.sessionComplete,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLgMobile.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          workoutName,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PulsingCheckCircle extends StatefulWidget {
  @override
  State<_PulsingCheckCircle> createState() => _PulsingCheckCircleState();
}

class _PulsingCheckCircleState extends State<_PulsingCheckCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.2,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.secondary.withAlpha(
                  (255 * _animation.value).round(),
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.check_circle,
            size: 40,
            color: context.colorScheme.onSecondaryContainer,
          ),
        );
      },
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.durationSeconds,
    required this.totalVolume,
    required this.completedSets,
    required this.totalSets,
    required this.weightUnit,
  });

  final int durationSeconds;
  final double totalVolume;
  final int completedSets;
  final int totalSets;
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
    return Row(
      children: [
        Expanded(
          child: _BentoStatCard(
            label: AppStrings.duration.toUpperCase(),
            child: Text(
              _formatDuration(durationSeconds),
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoStatCard(
            label: AppStrings.volumeLabel.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatVolume(totalVolume),
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.secondary,
                    height: 1.0,
                  ),
                ),
                Text(
                  weightUnit,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoStatCard(
            label: AppStrings.setsLabel.toUpperCase(),
            child: Text(
              '$completedSets/$totalSets',
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoStatCard extends StatelessWidget {
  const _BentoStatCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Icon(
              Icons.auto_awesome,
              size: 128,
              color: context.colorScheme.secondary.withAlpha(26),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt,
                    size: 20,
                    color: context.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.aedifyInsight.toUpperCase(),
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.completionInsight,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseSummarySection extends StatelessWidget {
  const _ExerciseSummarySection({
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

  int _completedSetCount(WorkoutRunnerExerciseItem exercise) {
    var count = 0;
    for (final set in exercise.sets) {
      if (set.completed) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppStrings.workoutSummary,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...exercises.map((exercise) {
          final volume = _exerciseVolume(exercise);
          final completedCount = _completedSetCount(exercise);
          final formattedVolume = _formatVolume(volume);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExerciseCard(
              name: exercise.exerciseName,
              completedSets: completedCount,
              totalSets: exercise.sets.length,
              formattedVolume: formattedVolume,
              weightUnit: weightUnit,
            ),
          );
        }),
      ],
    );
  }
}

String _formatVolume(double volume) {
  final rounded = volume.round();
  return rounded.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.name,
    required this.completedSets,
    required this.totalSets,
    required this.formattedVolume,
    required this.weightUnit,
  });

  final String name;
  final int completedSets;
  final int totalSets;
  final String formattedVolume;
  final String weightUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.surfaceContainer),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(5),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  name,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedSets sets \u2022 $formattedVolume $weightUnit volume',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

class _BottomActionsLayer extends StatelessWidget {
  const _BottomActionsLayer({required this.onDone, required this.onShare});

  final VoidCallback onDone;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withAlpha(230),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withAlpha(51),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.secondary,
                    foregroundColor: context.colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(AppStrings.done, style: AppTextStyles.labelMd),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onShare,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.surfaceContainer,
                    foregroundColor: context.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        size: 20,
                        color: context.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.shareSummary,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
