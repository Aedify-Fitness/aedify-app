import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class CompleteWorkoutSheet extends StatelessWidget {
  const CompleteWorkoutSheet({
    super.key,
    required this.session,
    required this.onComplete,
  });

  final WorkoutRunnerSessionViewData session;
  final void Function(WorkoutRunnerCompletionDraft draft) onComplete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final duration =
        session.durationSeconds ?? now.difference(session.startedAt).inSeconds;
    final minutes = duration ~/ 60;
    final durationLabel = '$minutes min';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.finishWorkoutSummary,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.finishWorkoutSummaryMessage,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: AppStrings.workout, value: session.name),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(label: AppStrings.duration, value: durationLabel),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: AppStrings.totalVolume,
            value:
                '${_CompleteWorkoutMetrics.totalVolume(session)} ${AppStrings.metricWeightUnit}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: AppStrings.setsCompleted,
            value:
                '${_CompleteWorkoutMetrics.completedSets(session)} / ${_CompleteWorkoutMetrics.totalSets(session)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: AppStrings.exercisesCompleted,
            value:
                '${_CompleteWorkoutMetrics.completedExercises(session)} / ${session.exercises.length}',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                onComplete(
                  WorkoutRunnerCompletionDraft(
                    sessionId: session.sessionId,
                    completedAt: now,
                    durationSeconds: duration,
                    notes: session.notes,
                    energyLevel: session.energyLevel,
                    perceivedDifficulty: session.perceivedDifficulty,
                  ),
                );
              },
              child: Text(AppStrings.completeWorkout),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteWorkoutMetrics {
  _CompleteWorkoutMetrics._();

  static int totalVolume(WorkoutRunnerSessionViewData session) {
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
    return volume.round();
  }

  static int completedSets(WorkoutRunnerSessionViewData session) {
    var count = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.completed) count++;
      }
    }
    return count;
  }

  static int totalSets(WorkoutRunnerSessionViewData session) {
    var count = 0;
    for (final exercise in session.exercises) {
      count += exercise.sets.length;
    }
    return count;
  }

  static int completedExercises(WorkoutRunnerSessionViewData session) {
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
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodyMedium),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
