import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
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
import 'package:aedify/features/workout_execution/domain/workout_launch_strings.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/exit_workout_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/finish_early_dialog.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_active_view.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_error_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_resume_banner.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_set_note_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/rest_resolver.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class WorkoutRunnerScreen extends ConsumerStatefulWidget {
  const WorkoutRunnerScreen.resume({super.key, this.launchedSessionId})
    : mode = WorkoutRunnerMode.resume,
      savedWorkoutId = null,
      programId = null,
      programWorkoutId = null;

  const WorkoutRunnerScreen.savedWorkout({
    super.key,
    required this.savedWorkoutId,
  }) : mode = WorkoutRunnerMode.savedWorkout,
       launchedSessionId = null,
       programId = null,
       programWorkoutId = null;

  const WorkoutRunnerScreen.programWorkout({
    super.key,
    required this.programId,
    required this.programWorkoutId,
  }) : mode = WorkoutRunnerMode.programWorkout,
       launchedSessionId = null,
       savedWorkoutId = null;

  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;
  final String? launchedSessionId;

  @override
  ConsumerState<WorkoutRunnerScreen> createState() =>
      _WorkoutRunnerScreenState();
}

class _WorkoutRunnerScreenState extends ConsumerState<WorkoutRunnerScreen> {
  bool _showRestTimer = false;
  int _restSeconds = 90;
  int _restTimerSerial = 0;
  bool _hasNavigatedToCompletion = false;
  bool _exitSheetOpen = false;
  bool _hasResumedLaunch = false;

  ({
    WorkoutRunnerMode mode,
    String? savedWorkoutId,
    String? programId,
    String? programWorkoutId,
  })
  get _argument => (
    mode: widget.mode,
    savedWorkoutId: widget.savedWorkoutId,
    programId: widget.programId,
    programWorkoutId: widget.programWorkoutId,
  );

  bool get _isFinalizing {
    final state = ref
        .read(AppProviders.workoutRunnerControllerProvider(_argument))
        .asData
        ?.value;
    return state?.isChangingPauseState == true ||
        state?.phase == WorkoutRunnerPhase.completing ||
        state?.phase == WorkoutRunnerPhase.cancelling;
  }

  void _resetTransientUi() {
    if (!mounted) return;
    setState(() {
      _showRestTimer = false;
      _restSeconds = 90;
      _restTimerSerial++;
    });
  }

  void _startRestTimer(int seconds) {
    if (!mounted) return;
    setState(() {
      _restSeconds = seconds;
      _showRestTimer = true;
      _restTimerSerial++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final argument = _argument;
    final stateAsync = ref.watch(
      AppProviders.workoutRunnerControllerProvider(argument),
    );
    final currentState = stateAsync.asData?.value;

    if (!_hasResumedLaunch &&
        widget.launchedSessionId != null &&
        currentState?.hasRecoveredSession == true &&
        currentState?.session?.sessionId == widget.launchedSessionId) {
      _hasResumedLaunch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(
                AppProviders.workoutRunnerControllerProvider(argument).notifier,
              )
              .resumeRecoveredSession();
        }
      });
    }

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
            currentState?.phase == WorkoutRunnerPhase.saving ||
            currentState?.phase == WorkoutRunnerPhase.completing ||
            currentState?.phase == WorkoutRunnerPhase.cancelling ||
            currentState?.phase == WorkoutRunnerPhase.failure);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    Widget body = PopScope(
      canPop: !hasActiveSession && !_isFinalizing,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !hasActiveSession) return;
        if (_isFinalizing) return;
        final session = currentState!.session!;
        final controller = ref.read(
          AppProviders.workoutRunnerControllerProvider(argument).notifier,
        );
        _showExitWorkoutSheet(context, session, controller);
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: stateAsync.when(
          loading: () => const _RunnerStatePage(child: _LoadingView()),
          error: (_, _) => _RunnerStatePage(
            child: _ProviderErrorView(
              onRetry: () => ref.invalidate(
                AppProviders.workoutRunnerControllerProvider(argument),
              ),
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

  Future<void> _showExitWorkoutSheet(
    BuildContext context,
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerController controller,
  ) async {
    if (_exitSheetOpen || _isFinalizing) return;
    _exitSheetOpen = true;
    final elapsed = WorkoutDurationResolver.elapsedSeconds(
      startedAt: session.startedAt,
      accumulatedSeconds: session.durationSeconds,
    );
    final sessionWithDuration = session.copyWith(durationSeconds: elapsed);

    try {
      await showModalBottomSheet<void>(
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
            if (context.mounted &&
                ref
                        .read(
                          AppProviders.workoutRunnerControllerProvider(
                            _argument,
                          ),
                        )
                        .asData
                        ?.value
                        .phase ==
                    WorkoutRunnerPhase.paused) {
              _RunnerNavigation.exit(context);
            }
          },
          onAbandon: () async {
            context.pop();
            _resetTransientUi();
            await controller.cancelWorkout();
            if (context.mounted &&
                ref
                        .read(
                          AppProviders.workoutRunnerControllerProvider(
                            _argument,
                          ),
                        )
                        .asData
                        ?.value
                        .session
                        ?.status ==
                    WorkoutSessionStatus.abandoned) {
              _RunnerNavigation.exit(context);
            }
          },
          onClose: () => context.pop(),
        ),
      );
    } finally {
      _exitSheetOpen = false;
    }
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
        state.isChangingPauseState ||
        state.phase == WorkoutRunnerPhase.cancelling ||
        state.phase == WorkoutRunnerPhase.completing) {
      return const _RunnerStatePage(allowExit: false, child: _LoadingView());
    }
    if (state.phase == WorkoutRunnerPhase.failure && state.session == null) {
      return _RunnerStatePage(
        child: WorkoutRunnerErrorBanner(
          message: state.errorMessage ?? AppStrings.workoutRunnerLoadFailed,
          onRetry: () => ref.invalidate(
            AppProviders.workoutRunnerControllerProvider((
              mode: mode,
              savedWorkoutId: savedWorkoutId,
              programId: programId,
              programWorkoutId: programWorkoutId,
            )),
          ),
        ),
      );
    }
    if (state.phase == WorkoutRunnerPhase.blocked) {
      return _RunnerStatePage(
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

    Future<void> retryOperation() async {
      await controller.retryFailedOperation();
      if (!context.mounted) return;
      final after = ref
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .asData
          ?.value;
      if (after?.session?.status == WorkoutSessionStatus.abandoned ||
          after?.phase == WorkoutRunnerPhase.paused ||
          (state.hasRecoveredSession &&
              after?.session == null &&
              after?.phase == WorkoutRunnerPhase.ready)) {
        _RunnerNavigation.exit(context);
      }
    }

    if (state.hasRecoveredSession) {
      return SafeArea(
        child: WorkoutRunnerResumeBanner(
          session: state.session!,
          onResume: controller.resumeRecoveredSession,
          errorMessage: state.phase == WorkoutRunnerPhase.failure
              ? state.errorMessage
              : null,
          onRetry: retryOperation,
          onDiscard: () async {
            await controller.discardRecoveredSession();
            if (context.mounted &&
                ref
                        .read(
                          AppProviders.workoutRunnerControllerProvider(
                            argument,
                          ),
                        )
                        .asData
                        ?.value
                        .session ==
                    null) {
              _RunnerNavigation.exit(context);
            }
          },
        ),
      );
    }

    final session = state.session;
    if (session == null) {
      return const _RunnerStatePage(child: _NoActiveWorkoutView());
    }

    if (session.exercises.isEmpty) {
      return _EmptyWorkoutView(
        errorMessage: state.errorMessage,
        onAdd: () => _showAddExercisePicker(context, ref, controller, session),
        onClose: () => onExitRequested(session, controller),
      );
    }

    const blockResolver = WorkoutRunnerBlockResolver();
    final leadExercise =
        blockResolver.firstIncompleteExercise(session.exercises) ??
        session.exercises
            .where(
              (exercise) => exercise.sets.any(
                (set) =>
                    set.completed &&
                    !set.skipped &&
                    !WorkoutRunnerSetPolicy.canComplete(
                      set,
                      loggingType: exercise.loggingType,
                      currentExerciseId: exercise.exerciseId,
                    ),
              ),
            )
            .firstOrNull ??
        (session.source == SessionSource.standalone ||
                !session.exercises.any(
                  (exercise) =>
                      exercise.sets.any((set) => set.completed && !set.skipped),
                )
            ? session.exercises.lastOrNull
            : null);
    if (leadExercise == null) {
      if (state.phase == WorkoutRunnerPhase.failure) {
        return _RunnerStatePage(
          child: WorkoutRunnerErrorBanner(
            message:
                state.errorMessage ?? AppStrings.workoutRunnerCompleteFailed,
            onRetry: retryOperation,
          ),
        );
      }
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
    final canLogSet =
        activeSet != null &&
        WorkoutRunnerSetPolicy.canComplete(
          activeSet,
          loggingType: activeExercise.loggingType,
        );

    Future<void> logActiveSet() async {
      final set = activeSet;
      if (set == null || !canLogSet) return;
      final setToComplete = set;
      await controller.toggleSetCompleted(
        exerciseId: activeExercise.id,
        setId: setToComplete.id,
        completed: true,
      );
      if (!context.mounted) return;
      final latestSession = ref
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .asData
          ?.value
          .session;
      if (latestSession == null ||
          !latestSession.exercises.any(
            (exercise) =>
                exercise.sets.any((set) => !set.completed && !set.skipped),
          )) {
        return;
      }
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
      errorMessage: state.errorMessage,
      onRetry: retryOperation,
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
      onToggleSkipped: (exerciseId, set, skipped) =>
          controller.toggleSetSkipped(
            exerciseId: exerciseId,
            setId: set.id,
            skipped: skipped,
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
      onAddExercise: () =>
          _showAddExercisePicker(context, ref, controller, session),
      onShowExercise: (exerciseId) => context.pushNamed(
        AppRoutes.exerciseDetail().name,
        pathParameters: {'id': exerciseId.toString()},
      ),
      onFinish: () => _showFinishEarlyDialog(context, session, controller),
    );
  }

  void _showAddExercisePicker(
    BuildContext context,
    WidgetRef ref,
    WorkoutRunnerController controller,
    WorkoutRunnerSessionViewData session,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExerciseBottomSheet(
        excludedExerciseIds: session.exercises.map((e) => e.exerciseId),
        onSelectExercises: controller.addExercises,
      ),
    ).then((_) {
      if (context.mounted) {
        ref
            .read(AppProviders.exerciseSearchControllerProvider.notifier)
            .clearFilters();
      }
    });
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
            replacementLoggingType: ExerciseLoggingType.fromDbWithDefault(
              replacement.loggingType,
            ),
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

class _EmptyWorkoutView extends StatelessWidget {
  const _EmptyWorkoutView({
    required this.onAdd,
    required this.onClose,
    this.errorMessage,
  });
  final VoidCallback onAdd;
  final VoidCallback onClose;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: onClose,
            child: const Text(AppStrings.close),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkoutLaunchStrings.emptyTitle,
                    style: context.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  AppWhiteSpace.hMd,
                  Text(
                    WorkoutLaunchStrings.emptyMessage,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    AppWhiteSpace.hMd,
                    WorkoutRunnerErrorBanner(message: errorMessage!),
                  ],
                  AppWhiteSpace.hLg,
                  FilledButton(
                    onPressed: onAdd,
                    child: const Text(WorkoutLaunchStrings.addExercises),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
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
                style: WorkoutRunnerStyle.body(context),
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
            style: WorkoutRunnerStyle.body(context),
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
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
      ),
    );
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
      prescribedRir: set.prescribedRir,
      prescribedDurationSeconds: set.prescribedDurationSeconds,
      prescribedDistanceMeters: set.prescribedDistanceMeters,
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

class _RunnerStatePage extends StatelessWidget {
  const _RunnerStatePage({required this.child, this.allowExit = true});
  final Widget child;
  final bool allowExit;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppWorkoutRunnerTokens.horizontalPadding,
              vertical: AppSpacing.sm,
            ),
            child: IconButton(
              tooltip: AppStrings.exitWorkout,
              onPressed: allowExit
                  ? () => _RunnerNavigation.exit(context)
                  : null,
              constraints: const BoxConstraints(
                minWidth: AppWorkoutRunnerTokens.controlSize,
                minHeight: AppWorkoutRunnerTokens.controlSize,
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowLeft,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  allowExit
                      ? context.colorScheme.onSurface
                      : context.colorScheme.outline,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

abstract final class _RunnerNavigation {
  static void exit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.programmes().name);
    }
  }
}
