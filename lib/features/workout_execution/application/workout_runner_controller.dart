import 'dart:async';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/shared/constants/app_strings.dart';
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
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
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
  Future<bool>? _progressSave;
  bool _finalizing = false;
  bool _changingPauseState = false;
  _RunnerFailedOperation? _failedOperation;
  WorkoutRunnerCompletionDraft? _failedCompletionDraft;

  WorkoutRunnerState? get _editableState {
    if (!ref.mounted || _finalizing || _changingPauseState) return null;
    final current = state.asData?.value;
    if (current?.session?.status != WorkoutSessionStatus.inProgress) {
      return null;
    }
    return switch (current!.phase) {
      WorkoutRunnerPhase.ready ||
      WorkoutRunnerPhase.saving ||
      WorkoutRunnerPhase.paused ||
      WorkoutRunnerPhase.failure => current,
      _ => null,
    };
  }

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
            errorMessage: AppStrings.noActiveWorkout,
          );
        }
        try {
          final session = await startUseCase.startFromSavedWorkout(id);
          if (ref.mounted) {
            ref.invalidate(AppProviders.activeWorkoutSessionProvider);
          }
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
            errorMessage: AppStrings.workoutRunnerLoadFailed,
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
            errorMessage: AppStrings.noActiveWorkout,
          );
        }
        try {
          final session = await startUseCase.startFromProgramWorkout(
            programId: pId,
            programWorkoutId: pwId,
          );
          if (ref.mounted) {
            ref.invalidate(AppProviders.activeWorkoutSessionProvider);
          }
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
            errorMessage: AppStrings.workoutRunnerLoadFailed,
          );
        }
    }
  }

  Future<void> startSession() async {
    _logger.info('startSession');
    final current = _editableState;
    if (current == null) return;
    if (current.phase == WorkoutRunnerPhase.ready) return;
    state = AsyncData(current.copyWith(phase: WorkoutRunnerPhase.ready));
  }

  Future<void> resumeRecoveredSession() async {
    _logger.info('resumeRecoveredSession');
    final current = _editableState;
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
    final current = _editableState;
    if (current == null || !current.hasRecoveredSession) return;
    await _cancelWorkout(discardRecovered: true);
  }

  Future<void> updateSet({
    required String exerciseId,
    required String setId,
    required WorkoutRunnerSetItem updatedSet,
  }) async {
    _logger.debug('updateSet — exerciseId: $exerciseId, setId: $setId');
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final exercise = session.exercises
        .where((item) => item.id == exerciseId)
        .firstOrNull;
    final previous = exercise?.sets.where((set) => set.id == setId).firstOrNull;
    if (exercise == null ||
        previous == null ||
        updatedSet.id != setId ||
        updatedSet.exerciseId != previous.exerciseId) {
      return;
    }
    final rir = SetEffort.rirFromRpe(updatedSet.actualRpe);
    final normalized = updatedSet.copyWith(
      actualRir: rir,
      clearActualRir: rir == null,
    );
    final linked = <String>{};
    if (previous.setType != normalized.setType) {
      const resolver = WorkoutRunnerBlockResolver();
      final block = resolver.blockFor(session.exercises, exercise);
      final round = resolver.roundIndex(exercise, previous);
      final rows = previous.setType == SetType.warmup
          ? resolver.warmupRoundSets(block, round)
          : resolver.workingRoundSets(block, round);
      linked.addAll(rows.map((row) => row.set.id));
    }
    final updatedExercises = session.exercises
        .map(
          (member) => member.copyWith(
            sets: [
              for (final set in member.sets)
                if (member.id == exerciseId && set.id == setId)
                  normalized
                else if (linked.contains(set.id))
                  set.copyWith(setType: normalized.setType)
                else
                  set,
            ],
          ),
        )
        .toList();

    state = AsyncData(
      current.copyWith(session: session.copyWith(exercises: updatedExercises)),
    );
    _scheduleAutoSave();
  }

  /// Adds selected exercises without requiring a saved workout template.
  Future<void> addExercises(List<ExerciseReference> selections) async {
    final current = _editableState;
    final session = current?.session;
    if (current == null || session == null || selections.isEmpty) return;
    final ids = session.exercises.map((e) => e.exerciseId).toSet();
    const uuid = Uuid();
    final additions = <WorkoutRunnerExerciseItem>[];
    for (final selection in selections) {
      if (!ids.add(selection.exerciseId)) continue;
      additions.add(
        WorkoutRunnerExerciseItem(
          id: uuid.v4(),
          exerciseId: selection.exerciseId,
          exerciseName: selection.name,
          sortOrder: session.exercises.length + additions.length,
          loggingType: ExerciseLoggingType.fromDbWithDefault(
            selection.loggingType,
          ),
          sets: [
            WorkoutRunnerSetItem(
              id: uuid.v4(),
              exerciseId: selection.exerciseId,
              setIndex: 0,
              setType: SetType.working,
              performedAt: DateTime.now(),
              completed: false,
              skipped: false,
            ),
          ],
        ),
      );
    }
    if (additions.isEmpty) return;
    state = AsyncData(
      current.copyWith(
        session: session.copyWith(
          exercises: [...session.exercises, ...additions],
        ),
      ),
    );
    await saveProgress();
  }

  Future<void> addSet({required String exerciseId}) async {
    _logger.debug('addSet — exerciseId: $exerciseId');
    final current = _editableState;
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
        exerciseId: exercise.exerciseId,
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
        prescribedRir: template.prescribedRir,
        actualRpe: SetEffort.initialRpe(
          rir: template.prescribedRir,
          rpeMin: template.prescribedRpeMin,
          rpeMax: template.prescribedRpeMax,
        ),
        actualRir: SetEffort.rirFromRpe(
          SetEffort.initialRpe(
            rir: template.prescribedRir,
            rpeMin: template.prescribedRpeMin,
            rpeMax: template.prescribedRpeMax,
          ),
        ),
        prescribedDurationSeconds: template.prescribedDurationSeconds,
        prescribedDistanceMeters: template.prescribedDistanceMeters,
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
    ExerciseLoggingType? replacementLoggingType,
  }) async {
    _logger.info(
      'substituteExercise — sessionExerciseId: $sessionExerciseId, '
      'replacementExerciseId: $replacementExerciseId',
    );
    final current = _editableState;
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
        loggingType: replacementLoggingType,
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
                prescribedRir: set.prescribedRir,
                prescribedDurationSeconds: set.prescribedDurationSeconds,
                prescribedDistanceMeters: set.prescribedDistanceMeters,
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
    final current = _editableState;
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
        exerciseId: exercise.exerciseId,
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
        prescribedRir: template.prescribedRir,
        actualRpe: SetEffort.initialRpe(
          rir: template.prescribedRir,
          rpeMin: template.prescribedRpeMin,
          rpeMax: template.prescribedRpeMax,
        ),
        actualRir: SetEffort.rirFromRpe(
          SetEffort.initialRpe(
            rir: template.prescribedRir,
            rpeMin: template.prescribedRpeMin,
            rpeMax: template.prescribedRpeMax,
          ),
        ),
        prescribedDurationSeconds: template.prescribedDurationSeconds,
        prescribedDistanceMeters: template.prescribedDistanceMeters,
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
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    final updatedExercises = session.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final updatedSets = e.sets.map((s) {
        if (s.id != setId) return s;
        if (completed &&
            !WorkoutRunnerSetPolicy.canComplete(
              s,
              loggingType: e.loggingType,
              currentExerciseId: e.exerciseId,
            )) {
          return s;
        }
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
    final current = _editableState;
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
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(
      current.copyWith(session: session.copyWith(notes: notes)),
    );
  }

  Future<void> updateEnergyLevel(int? energyLevel) async {
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    state = AsyncData(
      current.copyWith(session: session.copyWith(energyLevel: energyLevel)),
    );
  }

  Future<void> updatePerceivedDifficulty(int? perceivedDifficulty) async {
    final current = _editableState;
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
    if (_changingPauseState) return;
    final current = _editableState;
    if (current == null) return;
    if (current.phase == WorkoutRunnerPhase.paused) return;
    final session = current.session;
    if (session == null) return;
    _changingPauseState = true;
    _autoSaveTimer?.cancel();
    final elapsed = WorkoutDurationResolver.elapsedSeconds(
      startedAt: session.startedAt,
      accumulatedSeconds: session.durationSeconds,
    );
    state = AsyncData(
      current.copyWith(
        session: session.copyWith(durationSeconds: elapsed),
        isChangingPauseState: true,
      ),
    );
    try {
      final saved = await _persistProgress();
      if (!ref.mounted || _finalizing) return;
      final afterSave = state.asData?.value;
      if (!saved) {
        _failedOperation = _RunnerFailedOperation.pause;
      } else if (afterSave != null &&
          afterSave.phase == WorkoutRunnerPhase.ready) {
        state = AsyncData(afterSave.copyWith(phase: WorkoutRunnerPhase.paused));
      }
    } finally {
      _finishPauseTransition();
    }
  }

  Future<void> continueWorkout() async {
    if (_changingPauseState) return;
    final current = _editableState;
    if (current == null) return;
    if (current.phase != WorkoutRunnerPhase.paused) return;
    final session = current.session;
    if (session == null) return;

    final now = DateTime.now();
    final pausedDuration = session.durationSeconds;
    final adjustedStartedAt = pausedDuration != null
        ? now.subtract(Duration(seconds: pausedDuration))
        : session.startedAt;

    _changingPauseState = true;
    state = AsyncData(
      current.copyWith(
        phase: WorkoutRunnerPhase.ready,
        isChangingPauseState: true,
        session: session.copyWith(
          startedAt: adjustedStartedAt,
          clearDurationSeconds: true,
        ),
      ),
    );
    try {
      await _persistProgress();
    } finally {
      _finishPauseTransition();
    }
  }

  Future<void> saveProgress() async {
    if (_editableState == null) return;
    await _persistProgress();
  }

  Future<bool> _persistProgress({bool allowFinalizing = false}) async {
    while (_progressSave != null) {
      if (!await _progressSave!) return false;
      if (!ref.mounted) return false;
    }
    if (!ref.mounted || (_finalizing && !allowFinalizing)) return false;
    final current = state.asData?.value;
    if (current?.session?.status != WorkoutSessionStatus.inProgress) {
      return false;
    }
    final saving = _saveSnapshot(current!);
    _progressSave = saving;
    try {
      return await saving;
    } finally {
      if (identical(_progressSave, saving)) _progressSave = null;
    }
  }

  Future<bool> _saveSnapshot(WorkoutRunnerState current) async {
    final session = current.session!;
    final retainsPhase =
        current.phase == WorkoutRunnerPhase.completing ||
        current.phase == WorkoutRunnerPhase.cancelling ||
        current.phase == WorkoutRunnerPhase.paused;
    _logger.debug('autoSave — sessionId: ${session.sessionId}');
    state = AsyncData(
      current.copyWith(
        phase: retainsPhase ? current.phase : WorkoutRunnerPhase.saving,
        clearErrors: true,
      ),
    );
    try {
      final saveUseCase = ref.read(
        AppProviders.saveWorkoutSessionProgressUseCaseProvider,
      );
      await saveUseCase.save(session);
      if (!ref.mounted) return false;
      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
      final latest = state.asData?.value;
      if (latest != null && latest.phase == WorkoutRunnerPhase.saving) {
        state = AsyncData(
          latest.copyWith(phase: WorkoutRunnerPhase.ready, clearErrors: true),
        );
      }
      return true;
    } catch (error) {
      if (!ref.mounted) return false;
      _logger.error('saveProgress — failed', error: error);
      final latest = state.asData?.value;
      if (latest != null && latest.phase != WorkoutRunnerPhase.cancelling) {
        _failedOperation = _RunnerFailedOperation.save;
        state = AsyncData(
          latest.copyWith(
            phase: WorkoutRunnerPhase.failure,
            errorCode: 'save_failed',
            errorMessage: AppStrings.workoutRunnerSaveFailed,
          ),
        );
      }
      return false;
    }
  }

  Future<void> completeWorkout([WorkoutRunnerCompletionDraft? draft]) async {
    _logger.info('completeWorkout');
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;
    if (draft != null && draft.sessionId != session.sessionId) return;
    final completedSets = [
      for (final exercise in session.exercises)
        for (final set in exercise.sets)
          if (set.completed && !set.skipped) (exercise, set),
    ];
    if (completedSets.isEmpty ||
        completedSets.any(
          (entry) => !WorkoutRunnerSetPolicy.canComplete(
            entry.$2,
            loggingType: entry.$1.loggingType,
            currentExerciseId: entry.$1.exerciseId,
          ),
        )) {
      state = AsyncData(
        current.copyWith(
          errorCode: 'invalid_completed_sets',
          errorMessage: completedSets.isEmpty
              ? AppErrorStrings.workoutNoCompletedSets
              : AppErrorStrings.workoutInvalidCompletedSets,
        ),
      );
      return;
    }
    _finalizing = true;
    _autoSaveTimer?.cancel();
    final now = DateTime.now();
    final effectiveDraft =
        draft ??
        WorkoutRunnerCompletionDraft(
          sessionId: session.sessionId,
          completedAt: now,
          durationSeconds: WorkoutDurationResolver.elapsedSeconds(
            startedAt: session.startedAt,
            accumulatedSeconds: session.durationSeconds,
            now: now,
          ),
          notes: session.notes,
          energyLevel: session.energyLevel,
          perceivedDifficulty: session.perceivedDifficulty,
        );
    _failedCompletionDraft = effectiveDraft;
    state = AsyncData(
      current.copyWith(
        phase: WorkoutRunnerPhase.completing,
        session: _withCompletionMetadata(session, effectiveDraft),
        clearErrors: true,
      ),
    );
    try {
      if (!await _persistProgress(allowFinalizing: true)) {
        if (ref.mounted) _failedOperation = _RunnerFailedOperation.complete;
        return;
      }
      if (!ref.mounted) return;
      final currentState = state.asData?.value;
      if (currentState == null) return;
      if (currentState.phase == WorkoutRunnerPhase.failure) return;

      final currentSession = currentState.session;
      if (currentSession == null) return;

      final completeUseCase = ref.read(
        AppProviders.completeWorkoutSessionUseCaseProvider,
      );

      await completeUseCase.complete(effectiveDraft);
      if (!ref.mounted) return;

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
          clearErrors: true,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      _logger.error('completeWorkout — failed', error: e);
      _failedOperation = _RunnerFailedOperation.complete;
      final catchState = state.asData?.value;
      if (catchState == null) return;
      state = AsyncData(
        catchState.copyWith(
          phase: WorkoutRunnerPhase.failure,
          errorCode: 'complete_failed',
          errorMessage: AppStrings.workoutRunnerCompleteFailed,
        ),
      );
    } finally {
      _finalizing = false;
    }
  }

  Future<void> cancelWorkout() => _cancelWorkout();

  Future<void> _cancelWorkout({bool discardRecovered = false}) async {
    _logger.info('abandonWorkout');
    final current = _editableState;
    if (current == null) return;
    final session = current.session;
    if (session == null) return;

    _finalizing = true;
    _autoSaveTimer?.cancel();
    state = AsyncData(
      current.copyWith(phase: WorkoutRunnerPhase.cancelling, clearErrors: true),
    );

    try {
      final pending = _progressSave;
      if (pending != null) await pending;
      if (!ref.mounted) return;
      final abandonUseCase = ref.read(
        AppProviders.abandonWorkoutSessionUseCaseProvider,
      );
      await abandonUseCase.abandon(session.sessionId);
      if (!ref.mounted) return;
      ref.invalidate(AppProviders.activeWorkoutSessionProvider);
      ref.invalidate(AppProviders.programmeLibraryControllerProvider);
      final pId = programId;
      if (pId != null) {
        ref.invalidate(AppProviders.programmeSyncProvider(pId));
        ref.invalidate(AppProviders.programmeCalendarControllerProvider(pId));
      }
      ref.read(AppProviders.homeRefreshTriggerProvider.notifier).trigger();
      state = AsyncData(
        discardRecovered
            ? WorkoutRunnerState(
                mode: current.mode,
                phase: WorkoutRunnerPhase.ready,
                resumeDecision: WorkoutRunnerResumeDecision.discard,
              )
            : current.copyWith(
                phase: WorkoutRunnerPhase.completed,
                session: session.copyWith(
                  status: WorkoutSessionStatus.abandoned,
                ),
                clearErrors: true,
              ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      _logger.error('abandonWorkout — failed', error: e);
      _failedOperation = discardRecovered
          ? _RunnerFailedOperation.discardRecovered
          : _RunnerFailedOperation.cancel;
      state = AsyncData(
        current.copyWith(
          phase: WorkoutRunnerPhase.failure,
          errorCode: 'abandon_failed',
          errorMessage: AppStrings.workoutRunnerAbandonFailed,
        ),
      );
    } finally {
      _finalizing = false;
    }
  }

  /// Repeats the failed persistence operation while preserving its user inputs.
  Future<void> retryFailedOperation() async {
    if (_editableState?.phase != WorkoutRunnerPhase.failure) return;
    switch (_failedOperation) {
      case _RunnerFailedOperation.complete:
        await completeWorkout(_failedCompletionDraft);
      case _RunnerFailedOperation.cancel:
        await cancelWorkout();
      case _RunnerFailedOperation.discardRecovered:
        await discardRecoveredSession();
      case _RunnerFailedOperation.pause:
        await pauseWorkout();
      case _RunnerFailedOperation.save:
        await saveProgress();
      case null:
        return;
    }
  }

  void _scheduleAutoSave() {
    if (!ref.mounted || _finalizing) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      saveProgress();
    });
  }

  void _finishPauseTransition() {
    _changingPauseState = false;
    if (!ref.mounted) return;
    final latest = state.asData?.value;
    if (latest?.isChangingPauseState == true) {
      state = AsyncData(latest!.copyWith(isChangingPauseState: false));
    }
  }

  WorkoutRunnerSessionViewData _withCompletionMetadata(
    WorkoutRunnerSessionViewData session,
    WorkoutRunnerCompletionDraft draft,
  ) => WorkoutRunnerSessionViewData(
    sessionId: session.sessionId,
    name: session.name,
    source: session.source,
    status: session.status,
    startedAt: session.startedAt,
    exercises: session.exercises,
    programId: session.programId,
    programWorkoutId: session.programWorkoutId,
    savedWorkoutId: session.savedWorkoutId,
    completedAt: session.completedAt,
    durationSeconds: session.durationSeconds,
    bodyweightKgAtSession: session.bodyweightKgAtSession,
    notes: draft.notes,
    energyLevel: draft.energyLevel,
    perceivedDifficulty: draft.perceivedDifficulty,
  );
}

enum _RunnerFailedOperation { save, complete, cancel, discardRecovered, pause }
