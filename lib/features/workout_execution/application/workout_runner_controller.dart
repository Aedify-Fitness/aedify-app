import 'dart:async';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_state.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_duration_resolver.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_resume_decision.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:uuid/uuid.dart';

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
    final session = current.session;
    if (session == null) return;

    final now = DateTime.now();
    final accumulated = session.durationSeconds;
    final adjustedStartedAt = accumulated != null
        ? now.subtract(Duration(seconds: accumulated))
        : session.startedAt;

    state = AsyncData(
      current.copyWith(
        phase: WorkoutRunnerPhase.ready,
        hasRecoveredSession: false,
        resumeDecision: WorkoutRunnerResumeDecision.resume,
        session: session.copyWith(
          startedAt: adjustedStartedAt,
          clearDurationSeconds: true,
        ),
      ),
    );
    await saveProgress();
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

  Future<void> addSet({required String exerciseId}) async {
    _logger.debug('addSet — exerciseId: $exerciseId');
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final updatedExercises = session.exercises.map((exercise) {
      if (exercise.id != exerciseId || exercise.sets.isEmpty) return exercise;
      final template = exercise.sets.last;
      final nextSetIndex = exercise.sets.fold<int>(
        0,
        (next, set) => set.setIndex >= next ? set.setIndex + 1 : next,
      );
      final addedSet = WorkoutRunnerSetItem(
        id: const Uuid().v4(),
        exerciseId: template.exerciseId,
        setIndex: nextSetIndex,
        setType: template.setType,
        performedAt: DateTime.now(),
        completed: false,
        skipped: false,
        setIntent: template.setIntent,
        prescribedRepsMin: template.prescribedRepsMin,
        prescribedRepsMax: template.prescribedRepsMax,
        prescribedRepsExact: template.prescribedRepsExact,
        prescribedWeightKg: template.prescribedWeightKg,
        prescribedRpeMin: template.prescribedRpeMin,
        prescribedRpeMax: template.prescribedRpeMax,
        restSeconds: template.restSeconds,
      );
      return exercise.copyWith(sets: [...exercise.sets, addedSet]);
    }).toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  /// Swaps a session exercise for a replacement chosen from the library.
  ///
  /// Completed or skipped set logs keep their original per-set `exerciseId`
  /// so finished work stays attributed to the original exercise. Pending sets
  /// are recreated fresh for the replacement with their prescriptions kept
  /// and in-progress actuals cleared.
  Future<void> substituteExercise({
    required String sessionExerciseId,
    required int replacementExerciseId,
    required String replacementExerciseName,
  }) async {
    _logger.info(
      'substituteExercise — sessionExerciseId: $sessionExerciseId, '
      'replacementExerciseId: $replacementExerciseId',
    );
    final current = state.asData?.value;
    if (current == null) return;
    // Swapping is only offered while running; autosave would otherwise reset
    // a paused or saving phase.
    if (current.phase != WorkoutRunnerPhase.ready) return;
    final session = current.session;
    if (session == null) return;

    final target = session.exercises
        .where((exercise) => exercise.id == sessionExerciseId)
        .firstOrNull;
    if (target == null || target.exerciseId == replacementExerciseId) return;

    final updatedExercises = session.exercises.map((exercise) {
      if (exercise.id != sessionExerciseId) return exercise;
      return exercise.copyWith(
        exerciseId: replacementExerciseId,
        exerciseName: replacementExerciseName,
        sets: [
          for (final set in exercise.sets)
            if (set.completed || set.skipped)
              set
            else
              WorkoutRunnerSetItem(
                id: set.id,
                exerciseId: replacementExerciseId,
                setIndex: set.setIndex,
                setType: set.setType,
                performedAt: set.performedAt,
                completed: false,
                skipped: false,
                setIntent: set.setIntent,
                prescribedRepsMin: set.prescribedRepsMin,
                prescribedRepsMax: set.prescribedRepsMax,
                prescribedRepsExact: set.prescribedRepsExact,
                prescribedWeightKg: set.prescribedWeightKg,
                prescribedRpeMin: set.prescribedRpeMin,
                prescribedRpeMax: set.prescribedRpeMax,
                restSeconds: set.restSeconds,
              ),
        ],
      );
    }).toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  /// Appends one set to each exercise, cloning from that exercise's final set.
  ///
  /// Used to add a superset round so every member stays aligned.
  Future<void> addSetToExercises({required List<String> exerciseIds}) async {
    _logger.debug('addSetToExercises — exerciseIds: $exerciseIds');
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final ids = exerciseIds.toSet();
    final updatedExercises = session.exercises.map((exercise) {
      if (!ids.contains(exercise.id) || exercise.sets.isEmpty) return exercise;
      final template = exercise.sets.last;
      final nextSetIndex = exercise.sets.fold<int>(
        0,
        (next, set) => set.setIndex >= next ? set.setIndex + 1 : next,
      );
      final addedSet = WorkoutRunnerSetItem(
        id: const Uuid().v4(),
        exerciseId: template.exerciseId,
        setIndex: nextSetIndex,
        setType: template.setType,
        performedAt: DateTime.now(),
        completed: false,
        skipped: false,
        setIntent: template.setIntent,
        prescribedRepsMin: template.prescribedRepsMin,
        prescribedRepsMax: template.prescribedRepsMax,
        prescribedRepsExact: template.prescribedRepsExact,
        prescribedWeightKg: template.prescribedWeightKg,
        prescribedRpeMin: template.prescribedRpeMin,
        prescribedRpeMax: template.prescribedRpeMax,
        restSeconds: template.restSeconds,
      );
      return exercise.copyWith(sets: [...exercise.sets, addedSet]);
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
    final session = current.session;
    if (session == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(session.startedAt).inSeconds;

    // Set duration in memory first
    state = AsyncData(
      current.copyWith(session: session.copyWith(durationSeconds: elapsed)),
    );

    // Persist the accumulated duration
    await saveProgress();

    // Restore paused phase (saveProgress resets phase to ready)
    final afterSave = state.asData?.value;
    if (afterSave != null) {
      state = AsyncData(afterSave.copyWith(phase: WorkoutRunnerPhase.paused));
    }
  }

  Future<void> continueWorkout() async {
    final current = state.asData?.value;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final now = DateTime.now();
    final pausedDuration = session.durationSeconds;
    final adjustedStartedAt = pausedDuration != null
        ? now.subtract(Duration(seconds: pausedDuration))
        : session.startedAt;

    state = AsyncData(
      current.copyWith(
        phase: WorkoutRunnerPhase.ready,
        session: session.copyWith(
          startedAt: adjustedStartedAt,
          clearDurationSeconds: true,
        ),
      ),
    );
    await saveProgress();
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
      final latest = state.asData?.value;
      if (latest != null && latest.phase == WorkoutRunnerPhase.saving) {
        state = AsyncData(latest.copyWith(phase: WorkoutRunnerPhase.ready));
      }
    } catch (e) {
      _logger.error('saveProgress — failed', error: e);
      final latest = state.asData?.value;
      if (latest != null && latest.phase == WorkoutRunnerPhase.saving) {
        state = AsyncData(
          latest.copyWith(
            phase: WorkoutRunnerPhase.failure,
            errorMessage: e.toString(),
          ),
        );
      }
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
            durationSeconds: WorkoutDurationResolver.elapsedSeconds(
              startedAt: currentSession.startedAt,
              accumulatedSeconds: currentSession.durationSeconds,
              now: now,
            ),
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
