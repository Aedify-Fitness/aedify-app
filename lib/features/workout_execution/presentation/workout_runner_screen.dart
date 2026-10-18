import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_controller.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_state.dart';
import 'package:aedify/features/workout_execution/domain/workout_duration_resolver.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/exit_workout_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/finish_early_dialog.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_active_view.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_resume_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_set_note_sheet.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/rest_resolver.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutRunnerScreen extends ConsumerStatefulWidget {
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
  ConsumerState<WorkoutRunnerScreen> createState() =>
      _WorkoutRunnerScreenState();
}

class _WorkoutRunnerScreenState extends ConsumerState<WorkoutRunnerScreen> {
  bool _showRestTimer = false;
  int _restSeconds = 90;
  int _restTimerSerial = 0;
  bool _hasNavigatedToCompletion = false;

  void _resetTransientUi() {
    setState(() {
      _showRestTimer = false;
      _restSeconds = 90;
      _restTimerSerial++;
    });
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _restSeconds = seconds;
      _showRestTimer = true;
      _restTimerSerial++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final argument = (
      mode: widget.mode,
      savedWorkoutId: widget.savedWorkoutId,
      programId: widget.programId,
      programWorkoutId: widget.programWorkoutId,
    );
    final stateAsync = ref.watch(
      AppProviders.workoutRunnerControllerProvider(argument),
    );
    final currentState = stateAsync.asData?.value;

    if (currentState?.phase == WorkoutRunnerPhase.completed &&
        currentState?.session?.status == WorkoutSessionStatus.completed &&
        currentState?.session != null &&
        !_hasNavigatedToCompletion) {
      _hasNavigatedToCompletion = true;
      final session = currentState!.session!;
      final allSetsResolved = session.exercises.every(
        (exercise) =>
            exercise.sets.every((set) => set.completed || set.skipped),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.pushReplacementNamed(
          allSetsResolved
              ? AppRoutes.sessionComplete().name
              : AppRoutes.finishEarlySummary().name,
          extra: session,
        );
      });
    }

    final hasActiveSession =
        currentState?.session != null &&
        !(currentState?.hasRecoveredSession ?? false) &&
        (currentState?.phase == WorkoutRunnerPhase.ready ||
            currentState?.phase == WorkoutRunnerPhase.paused ||
            currentState?.phase == WorkoutRunnerPhase.saving);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    Widget body = PopScope(
      canPop: !hasActiveSession,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !hasActiveSession) return;
        final session = currentState!.session!;
        final controller = ref.read(
          AppProviders.workoutRunnerControllerProvider(argument).notifier,
        );
        _showExitWorkoutSheet(context, session, controller);
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: stateAsync.when(
          loading: () => const _LoadingView(),
          error: (_, _) => _ProviderErrorView(
            onRetry: () => ref.invalidate(
              AppProviders.workoutRunnerControllerProvider(argument),
            ),
          ),
          data: (state) => _WorkoutRunnerBody(
            state: state,
            mode: widget.mode,
            savedWorkoutId: widget.savedWorkoutId,
            programId: widget.programId,
            programWorkoutId: widget.programWorkoutId,
            restSeconds: _restSeconds,
            restTimerSerial: _restTimerSerial,
            showRestTimer: _showRestTimer,
            onResetTransientUi: _resetTransientUi,
            onSetLogged: _startRestTimer,
            onDismissRestTimer: () => setState(() => _showRestTimer = false),
            onExitRequested: (session, controller) =>
                _showExitWorkoutSheet(context, session, controller),
          ),
        ),
      ),
    );

    if (isIOS && hasActiveSession) {
      body = Stack(
        children: [
          body,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: AppWorkoutRunnerTokens.edgeSwipeWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null ||
                    details.primaryVelocity! <=
                        AppWorkoutRunnerTokens.edgeSwipeMinimumVelocity) {
                  return;
                }
                final session = currentState!.session!;
                final controller = ref.read(
                  AppProviders.workoutRunnerControllerProvider(
                    argument,
                  ).notifier,
                );
                _showExitWorkoutSheet(context, session, controller);
              },
            ),
          ),
        ],
      );
    }

    return body;
  }

  void _showExitWorkoutSheet(
    BuildContext context,
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  ) {
    final elapsed = WorkoutDurationResolver.elapsedSeconds(
      startedAt: session.startedAt,
      accumulatedSeconds: session.durationSeconds,
    );
    final sessionWithDuration = session.copyWith(durationSeconds: elapsed);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExitWorkoutSheet(
        session: sessionWithDuration,
        onFinishAndSave: () async {
          context.pop();
          _resetTransientUi();
          await controller.completeWorkout();
        },
        onPause: () async {
          context.pop();
          await controller.pauseWorkout();
          if (context.mounted) context.pop();
        },
        onAbandon: () async {
          context.pop();
          _resetTransientUi();
          await controller.cancelWorkout();
          if (context.mounted) context.pop();
        },
        onClose: () => context.pop(),
      ),
    );
  }
}

class _WorkoutRunnerBody extends ConsumerWidget {
  const _WorkoutRunnerBody({
    required this.state,
    required this.mode,
    required this.savedWorkoutId,
    required this.programId,
    required this.programWorkoutId,
    required this.restSeconds,
    required this.restTimerSerial,
    required this.showRestTimer,
    required this.onResetTransientUi,
    required this.onSetLogged,
    required this.onDismissRestTimer,
    required this.onExitRequested,
  });

  final WorkoutRunnerState state;
  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;
  final int restSeconds;
  final int restTimerSerial;
  final bool showRestTimer;
  final VoidCallback onResetTransientUi;
  final ValueChanged<int> onSetLogged;
  final VoidCallback onDismissRestTimer;
  final void Function(
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  )
  onExitRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading ||
        state.phase == WorkoutRunnerPhase.cancelling ||
        state.phase == WorkoutRunnerPhase.completing) {
      return const _LoadingView();
    }
    if (state.phase == WorkoutRunnerPhase.failure) {
      return SafeArea(
        child: WorkoutRunnerErrorBanner(
          message: state.errorMessage ?? AppStrings.workoutRunnerLoadFailed,
        ),
      );
    }
    if (state.phase == WorkoutRunnerPhase.blocked) {
      return SafeArea(
        child: WorkoutRunnerErrorBanner(
          message: state.errorMessage ?? AppStrings.noActiveWorkout,
        ),
      );
    }
    if (state.phase == WorkoutRunnerPhase.completed) {
      return const SizedBox.shrink();
    }

    final argument = (
      mode: mode,
      savedWorkoutId: savedWorkoutId,
      programId: programId,
      programWorkoutId: programWorkoutId,
    );
    final controller = ref.read(
      AppProviders.workoutRunnerControllerProvider(argument).notifier,
    );

    if (state.hasRecoveredSession && state.phase == WorkoutRunnerPhase.ready) {
      return SafeArea(
        child: WorkoutRunnerResumeBanner(
          session: state.session!,
          onResume: controller.resumeRecoveredSession,
          onDiscard: () async {
            await controller.discardRecoveredSession();
            if (context.mounted) context.pop();
          },
        ),
      );
    }

    final session = state.session;
    if (session == null) {
      return const _NoActiveWorkoutView();
    }

    const blockResolver = WorkoutRunnerBlockResolver();
    final leadExercise = blockResolver.firstIncompleteExercise(
      session.exercises,
    );
    if (leadExercise == null) {
      return _AutoCompleteWorkoutGuard(
        mode: mode,
        savedWorkoutId: savedWorkoutId,
        programId: programId,
        programWorkoutId: programWorkoutId,
        onResetTransientUi: onResetTransientUi,
      );
    }

    final block = blockResolver.blockFor(session.exercises, leadExercise);
    final activeSelection = blockResolver.firstIncompleteSet(block);
    final activeExercise = activeSelection?.exercise ?? leadExercise;
    final activeSet = activeSelection?.set;
    final effectiveWeight =
        activeSet?.actualWeightKg ?? activeSet?.prescribedWeightKg;
    final effectiveReps =
        activeSet?.actualReps ??
        activeSet?.prescribedRepsExact ??
        activeSet?.prescribedRepsMin ??
        activeSet?.prescribedRepsMax;
    final canLogSet =
        activeSet != null && effectiveWeight != null && effectiveReps != null;

    Future<void> logActiveSet() async {
      final set = activeSet;
      if (set == null || !canLogSet) return;
      var setToComplete = set;
      if (set.actualWeightKg == null || set.actualReps == null) {
        setToComplete = set.copyWith(
          actualWeightKg: effectiveWeight,
          actualReps: effectiveReps,
        );
        await controller.updateSet(
          exerciseId: activeExercise.id,
          setId: set.id,
          updatedSet: setToComplete,
        );
      }
      await controller.toggleSetCompleted(
        exerciseId: activeExercise.id,
        setId: setToComplete.id,
        completed: true,
      );
      if (!blockResolver.restAfterLog(block, activeExercise, setToComplete)) {
        return;
      }
      final effectiveRest = RestResolver.effectiveRest(
        setRest: setToComplete.restSeconds,
        exerciseRest: activeExercise.restBetweenExercisesSeconds,
      );
      onSetLogged(effectiveRest);
    }

    final blockTitle = block.isSuperset
        ? AppStrings.supersetBlockTitle(
            blockResolver.blockNumber(session.exercises, block),
          )
        : activeExercise.exerciseName;

    return WorkoutRunnerActiveView(
      session: session,
      block: block,
      activeExercise: activeExercise,
      activeSet: activeSet,
      blockTitle: blockTitle,
      showRestTimer: showRestTimer,
      restSeconds: restSeconds,
      restTimerSerial: restTimerSerial,
      isPaused: state.phase == WorkoutRunnerPhase.paused,
      canLogSet: canLogSet,
      onClose: () => onExitRequested(session, controller),
      onContinue: controller.continueWorkout,
      onDismissRestTimer: onDismissRestTimer,
      onUpdateSet: (exerciseId, updatedSet) => controller.updateSet(
        exerciseId: exerciseId,
        setId: updatedSet.id,
        updatedSet: updatedSet,
      ),
      onToggleCompleted: (exerciseId, set, completed) =>
          controller.toggleSetCompleted(
            exerciseId: exerciseId,
            setId: set.id,
            completed: completed,
          ),
      onLogSet: logActiveSet,
      onSubstitute: () =>
          _showSubstitutePicker(context, ref, controller, activeExercise),
      onAddSet: () => block.isSuperset
          ? controller.addSetToExercises(
              exerciseIds: block.members.map((member) => member.id).toList(),
            )
          : controller.addSet(exerciseId: activeExercise.id),
      onAddNote: (exerciseId, set) {
        final exercise = block.members.firstWhere(
          (member) => member.id == exerciseId,
          orElse: () => activeExercise,
        );
        _showSetNoteSheet(context, controller, exercise, set);
      },
      onShowExercise: (exerciseId) => context.pushNamed(
        AppRoutes.exerciseDetail().name,
        pathParameters: {'id': exerciseId.toString()},
      ),
      onFinish: () => _showFinishEarlyDialog(context, session, controller),
    );
  }

  void _showSubstitutePicker(
    BuildContext context,
    WidgetRef ref,
    WorkoutRunnerController controller,
    WorkoutRunnerExerciseItem exercise,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AddExerciseBottomSheet(
        excludedExerciseIds: [exercise.exerciseId],
        onSelectExercises: (selections) {
          if (selections.isEmpty) return;
          final replacement = selections.first;
          controller.substituteExercise(
            sessionExerciseId: exercise.id,
            replacementExerciseId: replacement.exerciseId,
            replacementExerciseName: replacement.name,
          );
        },
      ),
    ).then((_) {
      if (!context.mounted) return;
      ref
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .clearFilters();
    });
  }

  void _showSetNoteSheet(
    BuildContext context,
    WorkoutRunnerController controller,
    WorkoutRunnerExerciseItem exercise,
    WorkoutRunnerSetItem set,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => WorkoutRunnerSetNoteSheet(
        initialNote: set.notes,
        onSave: (note) async {
          await controller.updateSet(
            exerciseId: exercise.id,
            setId: set.id,
            updatedSet: _WorkoutRunnerSetMutations.copyWithNote(set, note),
          );
          if (sheetContext.mounted) sheetContext.pop();
        },
      ),
    );
  }

  void _showFinishEarlyDialog(
    BuildContext context,
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  ) {
    showDialog<void>(
      useSafeArea: false,
      context: context,
      builder: (_) => FinishEarlyDialog(
        session: session,
        onComplete: (draft) async {
          context.pop();
          onResetTransientUi();
          await controller.completeWorkout(draft);
        },
      ),
    );
  }
}

class _AutoCompleteWorkoutGuard extends ConsumerStatefulWidget {
  const _AutoCompleteWorkoutGuard({
    required this.mode,
    required this.savedWorkoutId,
    required this.programId,
    required this.programWorkoutId,
    required this.onResetTransientUi,
  });

  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;
  final VoidCallback onResetTransientUi;

  @override
  ConsumerState<_AutoCompleteWorkoutGuard> createState() =>
      _AutoCompleteWorkoutGuardState();
}

class _AutoCompleteWorkoutGuardState
    extends ConsumerState<_AutoCompleteWorkoutGuard> {
  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didStart) return;
      _didStart = true;
      widget.onResetTransientUi();
      final controller = ref.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: widget.mode,
          savedWorkoutId: widget.savedWorkoutId,
          programId: widget.programId,
          programWorkoutId: widget.programWorkoutId,
        )).notifier,
      );
      await controller.completeWorkout();
    });
  }

  @override
  Widget build(BuildContext context) => const _LoadingView();
}

class _ProviderErrorView extends StatelessWidget {
  const _ProviderErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.workoutRunnerLoadFailed,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoActiveWorkoutView extends StatelessWidget {
  const _NoActiveWorkoutView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            AppStrings.noActiveWorkout,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: CircularProgressIndicator()));
  }
}

class _WorkoutRunnerSetMutations {
  _WorkoutRunnerSetMutations._();

  static WorkoutRunnerSetItem copyWithNote(
    WorkoutRunnerSetItem set,
    String? note,
  ) {
    return WorkoutRunnerSetItem(
      id: set.id,
      exerciseId: set.exerciseId,
      setIndex: set.setIndex,
      setType: set.setType,
      performedAt: set.performedAt,
      completed: set.completed,
      skipped: set.skipped,
      setIntent: set.setIntent,
      prescribedRepsMin: set.prescribedRepsMin,
      prescribedRepsMax: set.prescribedRepsMax,
      prescribedRepsExact: set.prescribedRepsExact,
      prescribedWeightKg: set.prescribedWeightKg,
      prescribedRpeMin: set.prescribedRpeMin,
      prescribedRpeMax: set.prescribedRpeMax,
      actualReps: set.actualReps,
      actualWeightKg: set.actualWeightKg,
      actualDurationSeconds: set.actualDurationSeconds,
      actualDistanceMeters: set.actualDistanceMeters,
      actualRpe: set.actualRpe,
      actualRir: set.actualRir,
      restSeconds: set.restSeconds,
      notes: note,
    );
  }
}
