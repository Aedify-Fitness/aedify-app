import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_controller.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_state.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/cancel_workout_dialog.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/complete_workout_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_exercise_list.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_header.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_resume_banner.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerScreen extends ConsumerWidget {
  const WorkoutRunnerScreen.resume({super.key})
    : mode = WorkoutRunnerMode.resume,
      savedWorkoutId = null,
      programId = null,
      programWorkoutId = null;

  const WorkoutRunnerScreen.savedWorkout({
    super.key,
    required this.savedWorkoutId,
  }) : mode = WorkoutRunnerMode.savedWorkout,
       programId = null,
       programWorkoutId = null;

  const WorkoutRunnerScreen.programWorkout({
    super.key,
    required this.programId,
    required this.programWorkoutId,
  }) : mode = WorkoutRunnerMode.programWorkout,
       savedWorkoutId = null;

  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = (
      mode: mode,
      savedWorkoutId: savedWorkoutId,
      programId: programId,
      programWorkoutId: programWorkoutId,
    );
    final stateAsync = ref.watch(
      AppProviders.workoutRunnerControllerProvider(arg),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.workout)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.workoutRunnerLoadFailed,
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(
                  AppProviders.workoutRunnerControllerProvider(arg),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (state) => _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    WorkoutRunnerState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.phase == WorkoutRunnerPhase.failure) {
      return WorkoutRunnerErrorBanner(
        message: state.errorMessage ?? AppStrings.workoutRunnerLoadFailed,
      );
    }

    if (state.phase == WorkoutRunnerPhase.blocked) {
      return WorkoutRunnerErrorBanner(
        message: state.errorMessage ?? AppStrings.noActiveWorkout,
      );
    }

    if (state.phase == WorkoutRunnerPhase.completed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.workoutCompleted,
              style: context.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    if (!state.hasSession && mode == WorkoutRunnerMode.resume) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.noActiveWorkout,
              style: context.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (state.hasRecoveredSession && state.phase == WorkoutRunnerPhase.ready) {
      final controller = ref.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: mode,
          savedWorkoutId: savedWorkoutId,
          programId: programId,
          programWorkoutId: programWorkoutId,
        )).notifier,
      );
      return WorkoutRunnerResumeBanner(
        onResume: () => controller.resumeRecoveredSession(),
        onDiscard: () => controller.discardRecoveredSession(),
      );
    }

    if (state.session == null) {
      return Center(
        child: Text(
          AppStrings.noActiveWorkout,
          style: context.textTheme.bodyLarge,
        ),
      );
    }

    final session = state.session!;
    final controller = ref.read(
      AppProviders.workoutRunnerControllerProvider((
        mode: mode,
        savedWorkoutId: savedWorkoutId,
        programId: programId,
        programWorkoutId: programWorkoutId,
      )).notifier,
    );

    return Column(
      children: [
        WorkoutRunnerHeader(
          title: session.name,
          onComplete: () => _showCompleteSheet(context, session, controller),
          onCancel: () => _showCancelDialog(context, controller),
          isCompleting: state.isCompleting,
        ),
        if (state.phase == WorkoutRunnerPhase.paused)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: context.colorScheme.primaryContainer,
            child: Row(
              children: [
                Text(
                  AppStrings.workoutInterrupted,
                  style: context.textTheme.bodyMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.continueWorkout(),
                  child: Text(AppStrings.continueWorkout),
                ),
              ],
            ),
          ),
        Expanded(
          child: WorkoutRunnerExerciseList(
            exercises: session.exercises,
            groups: ref
                .watch(AppProviders.workoutRunnerGroupingMapperProvider)
                .buildGroups(session.exercises),
            onUpdateSet: (exerciseId, setId, set) => controller.updateSet(
              exerciseId: exerciseId,
              setId: setId,
              updatedSet: set,
            ),
            onToggleSetCompleted: (exerciseId, setId, completed) =>
                controller.toggleSetCompleted(
                  exerciseId: exerciseId,
                  setId: setId,
                  completed: completed,
                ),
            onToggleSetSkipped: (exerciseId, setId, skipped) =>
                controller.toggleSetSkipped(
                  exerciseId: exerciseId,
                  setId: setId,
                  skipped: skipped,
                ),
          ),
        ),
      ],
    );
  }

  void _showCompleteSheet(
    BuildContext context,
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CompleteWorkoutSheet(
        session: session,
        onComplete: (draft) {
          Navigator.of(context).pop();
          controller.completeWorkout();
        },
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WorkoutRunnerController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) =>
          CancelWorkoutDialog(onConfirm: () => controller.cancelWorkout()),
    );
  }
}
