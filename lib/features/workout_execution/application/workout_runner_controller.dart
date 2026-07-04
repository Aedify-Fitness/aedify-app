import 'dart:async';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_state.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_resume_decision.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

class WorkoutRunnerController extends AsyncNotifier<WorkoutRunnerState> {
  WorkoutRunnerController({
    required this.mode,
    this.savedWorkoutId,
    this.programId,
    this.programWorkoutId,
  });

  static final _logger = AppLogger(name: 'WorkoutRunnerController');

  final WorkoutRunnerMode mode;
  final String? savedWorkoutId;
  final String? programId;
  final String? programWorkoutId;
  Timer? _autoSaveTimer;

  @override
  Future<WorkoutRunnerState> build() async {
    _logger.info('build — mode: ${mode.name}');
    ref.onDispose(() => _autoSaveTimer?.cancel());
    final startUseCase = ref.read(
      AppProviders.startWorkoutSessionUseCaseProvider,
    );
    final loadUseCase = ref.read(
      AppProviders.loadActiveWorkoutSessionUseCaseProvider,
    );

    switch (mode) {
      case WorkoutRunnerMode.resume:
        final existing = await loadUseCase.load();
        if (existing != null) {
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.resume,
            phase: WorkoutRunnerPhase.ready,
            session: existing,
            hasRecoveredSession: true,
          );
        }
        return WorkoutRunnerState(
          mode: WorkoutRunnerMode.resume,
          phase: WorkoutRunnerPhase.ready,
          hasRecoveredSession: false,
        );

      case WorkoutRunnerMode.savedWorkout:
        final id = savedWorkoutId;
        if (id == null) {
          _logger.error('build — savedWorkout: missing ID');
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.savedWorkout,
            phase: WorkoutRunnerPhase.blocked,
            errorMessage: 'Saved workout ID is required',
          );
        }
        try {
          final session = await startUseCase.startFromSavedWorkout(id);
          ref.invalidate(AppProviders.activeWorkoutSessionProvider);
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.savedWorkout,
            phase: WorkoutRunnerPhase.ready,
            session: session,
          );
        } catch (e) {
          _logger.error('build — savedWorkout failed: $id', error: e);
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.savedWorkout,
            phase: WorkoutRunnerPhase.failure,
            errorMessage: e.toString(),
          );
        }

      case WorkoutRunnerMode.programWorkout:
        final pId = programId;
        final pwId = programWorkoutId;
        if (pId == null || pwId == null) {
          _logger.error('build — programWorkout: missing IDs');
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.programWorkout,
            phase: WorkoutRunnerPhase.blocked,
            errorMessage: 'Program ID and workout ID are required',
          );
        }
        try {
          final session = await startUseCase.startFromProgramWorkout(
            programId: pId,
            programWorkoutId: pwId,
          );
          ref.invalidate(AppProviders.activeWorkoutSessionProvider);
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.programWorkout,
            phase: WorkoutRunnerPhase.ready,
            session: session,
          );
        } catch (e) {
          _logger.error('build — programWorkout failed: $pId/$pwId', error: e);
          return WorkoutRunnerState(
            mode: WorkoutRunnerMode.programWorkout,
            phase: WorkoutRunnerPhase.failure,
            errorMessage: e.toString(),
          );
        }
    }
  }

  Future<void> startSession() async {
    _logger.info('startSession');
    final current = state.asData?.value;
    if (current == null) return;
    if (current.phase == WorkoutRunnerPhase.ready) return;
    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.ready));
  }

  Future<void> resumeRecoveredSession() async {
    _logger.info('resumeRecoveredSession');
    final current = state.asData?.value;
    if (current == null || !current.hasRecoveredSession) return;

    state = AsyncData(
      current.copyWith(
        phase: WorkoutRunnerPhase.ready,
        hasRecoveredSession: false,
        resumeDecision: WorkoutRunnerResumeDecision.resume,
      ),
    );
  }

  Future<void> discardRecoveredSession() async {
    _logger.info('discardRecoveredSession');
    final current = state.asData?.value;
    if (current == null || !current.hasRecoveredSession) return;

    final session = current.session;
    if (session != null) {
      final abandonUseCase = ref.read(
        AppProviders.abandonWorkoutSessionUseCaseProvider,
      );
      await abandonUseCase.abandon(session.sessionId);
      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
    }

    state = AsyncData(
      WorkoutRunnerState(
        mode: current.mode,
        phase: WorkoutRunnerPhase.ready,
        resumeDecision: WorkoutRunnerResumeDecision.discard,
      ),
    );
  }

  Future<void> updateSet({
    required String exerciseId,
    required String setId,
    required WorkoutRunnerSetItem updatedSet,
  }) async {
    _logger.debug('updateSet — exerciseId: $exerciseId, setId: $setId');
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final updatedExercises = session.exercises.map((e) {
      if (e.id != exerciseId) return e;
      return _replaceSet(e, setId, updatedSet);
    }).toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  Future<void> toggleSetCompleted({
    required String exerciseId,
    required String setId,
    required bool completed,
  }) async {
    _logger.debug(
      'toggleSetCompleted — exerciseId: $exerciseId, setId: $setId, completed: $completed',
    );
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final updatedExercises = session.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final updatedSets = e.sets.map((s) {
        if (s.id != setId) return s;
        return s.copyWith(
          completed: completed,
          skipped: completed ? false : s.skipped,
          performedAt: completed ? DateTime.now() : s.performedAt,
        );
      }).toList();
      return e.copyWith(sets: updatedSets);
    }).toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  Future<void> toggleSetSkipped({
    required String exerciseId,
    required String setId,
    required bool skipped,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final updatedExercises = session.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final updatedSets = e.sets.map((s) {
        if (s.id != setId) return s;
        return s.copyWith(
          skipped: skipped,
          completed: skipped ? false : s.completed,
        );
      }).toList();
      return e.copyWith(sets: updatedSets);
    }).toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  Future<void> updateSessionNotes(String? notes) async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(
      current.copyWith(session: session.copyWith(notes: notes)),
    );
  }

  Future<void> updateEnergyLevel(int? energyLevel) async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(
      current.copyWith(session: session.copyWith(energyLevel: energyLevel)),
    );
  }

  Future<void> updatePerceivedDifficulty(int? perceivedDifficulty) async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(
      current.copyWith(
        session: session.copyWith(perceivedDifficulty: perceivedDifficulty),
      ),
    );
  }

  Future<void> pauseWorkout() async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.paused));
  }

  Future<void> continueWorkout() async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.ready));
  }

  Future<void> saveProgress() async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;
    if (session.status != WorkoutSessionStatus.inProgress) return;

    _logger.debug('autoSave — sessionId: ${session.sessionId}');
    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.saving));

    try {
      final saveUseCase = ref.read(
        AppProviders.saveWorkoutSessionProgressUseCaseProvider,
      );
      await saveUseCase.save(session);
      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
      state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.ready));
    } catch (e) {
      _logger.error('saveProgress — failed', error: e);
      state = AsyncData(
        current.copyWith(
          phase: WorkoutRunnerPhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> completeWorkout([WorkoutRunnerCompletionDraft? draft]) async {
    _logger.info('completeWorkout');
    _autoSaveTimer?.cancel();
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.completing));

    try {
      await saveProgress();

      final currentState = state.asData?.value;
      if (currentState == null) return;
      if (currentState.phase == WorkoutRunnerPhase.failure) return;

      final currentSession = currentState.session;
      if (currentSession == null) return;

      final now = DateTime.now();
      final effectiveDraft =
          draft ??
          WorkoutRunnerCompletionDraft(
            sessionId: currentSession.sessionId,
            completedAt: now,
            durationSeconds: now.difference(currentSession.startedAt).inSeconds,
            notes: currentSession.notes,
            energyLevel: currentSession.energyLevel,
            perceivedDifficulty: currentSession.perceivedDifficulty,
          );

      final completeUseCase = ref.read(
        AppProviders.completeWorkoutSessionUseCaseProvider,
      );

      await completeUseCase.complete(effectiveDraft);

      final completedSession = currentSession.copyWith(
        status: WorkoutSessionStatus.completed,
        completedAt: effectiveDraft.completedAt,
        durationSeconds: effectiveDraft.durationSeconds,
      );

      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
      ref.invalidate(AppProviders.programmeLibraryControllerProvider);
      final pId = programId;
      if (pId != null) {
        ref.invalidate(AppProviders.programmeSyncProvider(pId));
        ref.invalidate(AppProviders.programmeCalendarControllerProvider(pId));
      }
      ref.read(AppProviders.homeRefreshTriggerProvider.notifier).trigger();

      state = AsyncData(
        currentState.copyWith(
          phase: WorkoutRunnerPhase.completed,
          session: completedSession,
        ),
      );
    } catch (e) {
      _logger.error('completeWorkout — failed', error: e);
      final catchState = state.asData?.value;
      if (catchState == null) return;
      state = AsyncData(
        catchState.copyWith(
          phase: WorkoutRunnerPhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> cancelWorkout() async {
    _logger.info('abandonWorkout');
    _autoSaveTimer?.cancel();
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.cancelling));

    try {
      final abandonUseCase = ref.read(
        AppProviders.abandonWorkoutSessionUseCaseProvider,
      );
      await abandonUseCase.abandon(session.sessionId);
      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
      ref.invalidate(AppProviders.programmeLibraryControllerProvider);
      final pId = programId;
      if (pId != null) {
        ref.invalidate(AppProviders.programmeSyncProvider(pId));
        ref.invalidate(AppProviders.programmeCalendarControllerProvider(pId));
      }
      ref.read(AppProviders.homeRefreshTriggerProvider.notifier).trigger();
      state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.completed));
    } catch (e) {
      _logger.error('abandonWorkout — failed', error: e);
      state = AsyncData(
        current.copyWith(
          phase: WorkoutRunnerPhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      saveProgress();
    });
  }

  WorkoutRunnerExerciseItem _replaceSet(
    WorkoutRunnerExerciseItem exercise,
    String setId,
    WorkoutRunnerSetItem updatedSet,
  ) {
    final updatedSets = exercise.sets.map((s) {
      if (s.id != setId) return s;
      return updatedSet;
    }).toList();
    return exercise.copyWith(sets: updatedSets);
  }
}
