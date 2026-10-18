import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/start_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/load_active_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/save_workout_session_progress_use_case.dart';
import 'package:aedify/features/workout_execution/application/complete_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/abandon_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_resume_decision.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/domain/set_type.dart';

WorkoutRunnerSessionViewData _sampleSession() {
  final now = DateTime(2025, 6, 1, 10, 0, 0);
  return WorkoutRunnerSessionViewData(
    sessionId: 'session-1',
    name: 'Morning Push',
    source: SessionSource.savedWorkout,
    status: WorkoutSessionStatus.inProgress,
    startedAt: now,
    exercises: [
      WorkoutRunnerExerciseItem(
        id: 'ex-1',
        exerciseId: 1,
        exerciseName: 'Bench Press',
        sortOrder: 0,
        sets: [
          WorkoutRunnerSetItem(
            id: 'set-1',
            exerciseId: 1,
            setIndex: 0,
            setType: SetType.working,
            performedAt: now,
            completed: false,
            skipped: false,
            prescribedRepsMin: 8,
            prescribedRepsMax: 12,
            prescribedWeightKg: 60.0,
          ),
          WorkoutRunnerSetItem(
            id: 'set-2',
            exerciseId: 1,
            setIndex: 1,
            setType: SetType.working,
            performedAt: now,
            completed: false,
            skipped: false,
            prescribedRepsMin: 8,
            prescribedRepsMax: 12,
            prescribedWeightKg: 60.0,
          ),
        ],
      ),
      WorkoutRunnerExerciseItem(
        id: 'ex-2',
        exerciseId: 2,
        exerciseName: 'Overhead Press',
        sortOrder: 1,
        sets: [
          WorkoutRunnerSetItem(
            id: 'set-3',
            exerciseId: 2,
            setIndex: 0,
            setType: SetType.working,
            performedAt: now,
            completed: false,
            skipped: false,
          ),
        ],
      ),
    ],
  );
}

class _FakeStartUseCase implements StartWorkoutSessionUseCase {
  bool shouldThrow = false;

  @override
  Future<WorkoutRunnerSessionViewData> startFromSavedWorkout(
    String savedWorkoutId,
  ) async {
    if (shouldThrow) throw Exception('start failed');
    return _sampleSession();
  }

  @override
  Future<WorkoutRunnerSessionViewData> startFromProgramWorkout({
    required String programId,
    required String programWorkoutId,
  }) async {
    if (shouldThrow) throw Exception('start failed');
    return _sampleSession();
  }
}

class _FakeLoadUseCase implements LoadActiveWorkoutSessionUseCase {
  WorkoutRunnerSessionViewData? sessionToReturn;

  @override
  Future<WorkoutRunnerSessionViewData?> load() async {
    return sessionToReturn;
  }
}

class _FakeSaveUseCase implements SaveWorkoutSessionProgressUseCase {
  bool shouldThrow = false;
  int saveCallCount = 0;
  WorkoutRunnerSessionViewData? lastSavedSession;
  Completer<void>? pendingSave;

  @override
  Future<void> save(WorkoutRunnerSessionViewData session) async {
    saveCallCount++;
    lastSavedSession = session;
    final pending = pendingSave;
    if (pending != null) await pending.future;
    if (shouldThrow) throw Exception('save failed');
  }
}

class _FakeCompleteUseCase implements CompleteWorkoutSessionUseCase {
  bool shouldThrow = false;

  @override
  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    if (shouldThrow) throw Exception('complete failed');
  }
}

class _FakeAbandonUseCase implements AbandonWorkoutSessionUseCase {
  bool shouldThrow = false;
  String? lastAbandonedId;

  @override
  Future<void> abandon(String sessionId) async {
    if (shouldThrow) throw Exception('abandon failed');
    lastAbandonedId = sessionId;
  }
}

void main() {
  late _FakeStartUseCase fakeStart;
  late _FakeLoadUseCase fakeLoad;
  late _FakeSaveUseCase fakeSave;
  late _FakeCompleteUseCase fakeComplete;
  late _FakeAbandonUseCase fakeAbandon;

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
          fakeStart,
        ),
        AppProviders.loadActiveWorkoutSessionUseCaseProvider.overrideWithValue(
          fakeLoad,
        ),
        AppProviders.saveWorkoutSessionProgressUseCaseProvider
            .overrideWithValue(fakeSave),
        AppProviders.completeWorkoutSessionUseCaseProvider.overrideWithValue(
          fakeComplete,
        ),
        AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
          fakeAbandon,
        ),
      ],
    );
  }

  setUp(() {
    fakeStart = _FakeStartUseCase();
    fakeLoad = _FakeLoadUseCase();
    fakeSave = _FakeSaveUseCase();
    fakeComplete = _FakeCompleteUseCase();
    fakeAbandon = _FakeAbandonUseCase();
  });

  group('build (resume mode)', () {
    test(
      'returns ready with recovered session when active session exists',
      () async {
        fakeLoad.sessionToReturn = _sampleSession();
        final container = createContainer();
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.resume,
            savedWorkoutId: null,
            programId: null,
            programWorkoutId: null,
          )).notifier,
        );
        final state = await controller.future;

        expect(state.phase, WorkoutRunnerPhase.ready);
        expect(state.mode, WorkoutRunnerMode.resume);
        expect(state.hasRecoveredSession, isTrue);
        expect(state.session, isNotNull);
      },
    );

    test(
      'returns ready without recovered session when no active session',
      () async {
        final container = createContainer();
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.resume,
            savedWorkoutId: null,
            programId: null,
            programWorkoutId: null,
          )).notifier,
        );
        final state = await controller.future;

        expect(state.phase, WorkoutRunnerPhase.ready);
        expect(state.mode, WorkoutRunnerMode.resume);
        expect(state.hasRecoveredSession, isFalse);
        expect(state.session, isNull);
      },
    );
  });

  group('build (saved workout mode)', () {
    test('returns ready with session when start succeeds', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.ready);
      expect(state.mode, WorkoutRunnerMode.savedWorkout);
      expect(state.session, isNotNull);
    });

    test('returns blocked state when savedWorkoutId is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.blocked);
    });

    test('returns failure state when start throws', () async {
      fakeStart.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.failure);
    });
  });

  group('build (program workout mode)', () {
    test('returns ready with session when start succeeds', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.programWorkout,
          savedWorkoutId: null,
          programId: 'prog-1',
          programWorkoutId: 'pw-1',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.ready);
      expect(state.mode, WorkoutRunnerMode.programWorkout);
      expect(state.session, isNotNull);
    });

    test('returns blocked state when programId is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.programWorkout,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: 'pw-1',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.blocked);
    });

    test('returns blocked state when programWorkoutId is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.programWorkout,
          savedWorkoutId: null,
          programId: 'prog-1',
          programWorkoutId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.blocked);
    });

    test('returns failure state when start throws', () async {
      fakeStart.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.programWorkout,
          savedWorkoutId: null,
          programId: 'prog-1',
          programWorkoutId: 'pw-1',
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, WorkoutRunnerPhase.failure);
    });
  });

  group('resumeRecoveredSession', () {
    test('transitions to ready with resume decision', () async {
      fakeLoad.sessionToReturn = _sampleSession().copyWith(
        durationSeconds: 120,
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.resumeRecoveredSession();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.ready);
      expect(state.resumeDecision, WorkoutRunnerResumeDecision.resume);
      expect(state.session!.durationSeconds, isNull);
      expect(fakeSave.saveCallCount, 1);
      expect(fakeSave.lastSavedSession!.durationSeconds, isNull);
    });

    test('does nothing when no recovered session', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.resumeRecoveredSession();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.resumeDecision, isNull);
    });
  });

  group('discardRecoveredSession', () {
    test('abandons session and transitions to ready', () async {
      fakeLoad.sessionToReturn = _sampleSession();
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.discardRecoveredSession();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.ready);
      expect(state.resumeDecision, WorkoutRunnerResumeDecision.discard);
      expect(state.session, isNull);
      expect(fakeAbandon.lastAbandonedId, 'session-1');
    });

    test('does nothing when no recovered session', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.discardRecoveredSession();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.resumeDecision, isNull);
      expect(fakeAbandon.lastAbandonedId, isNull);
    });
  });

  group('updateSet', () {
    test('updates a specific set in the session', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateSet(
        exerciseId: 'ex-1',
        setId: 'set-1',
        updatedSet: _sampleSession().exercises[0].sets[0].copyWith(
          actualReps: 10,
          actualWeightKg: 65.0,
        ),
      );

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      final updatedSet = state.session!.exercises[0].sets[0];
      expect(updatedSet.actualReps, 10);
      expect(updatedSet.actualWeightKg, 65.0);
    });

    test('does nothing when session is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateSet(
        exerciseId: 'ex-1',
        setId: 'set-1',
        updatedSet: _sampleSession().exercises[0].sets[0],
      );

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.session, isNull);
    });
  });

  group('addSet', () {
    test('appends an incomplete set from the final prescription', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final argument = (
        mode: WorkoutRunnerMode.savedWorkout,
        savedWorkoutId: 'sw-1',
        programId: null,
        programWorkoutId: null,
      );
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider(argument).notifier,
      );
      await controller.future;

      await controller.addSet(exerciseId: 'ex-1');

      final sets = container
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .requireValue
          .session!
          .exercises
          .first
          .sets;
      expect(sets, hasLength(3));
      expect(sets.last.id, isNot(sets[1].id));
      expect(sets.last.setIndex, 2);
      expect(sets.last.setType, sets[1].setType);
      expect(sets.last.prescribedWeightKg, sets[1].prescribedWeightKg);
      expect(sets.last.prescribedRepsMin, sets[1].prescribedRepsMin);
      expect(sets.last.prescribedRepsMax, sets[1].prescribedRepsMax);
      expect(sets.last.actualWeightKg, isNull);
      expect(sets.last.actualReps, isNull);
      expect(sets.last.completed, isFalse);
      expect(sets.last.skipped, isFalse);
    });

    test('appends one incomplete set to each selected exercise', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final argument = (
        mode: WorkoutRunnerMode.savedWorkout,
        savedWorkoutId: 'sw-1',
        programId: null,
        programWorkoutId: null,
      );
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider(argument).notifier,
      );
      await controller.future;

      await controller.addSetToExercises(exerciseIds: ['ex-1', 'ex-2']);

      final exercises = container
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .requireValue
          .session!
          .exercises;

      expect(exercises[0].sets, hasLength(3));
      expect(exercises[0].sets.last.setIndex, 2);
      expect(exercises[0].sets.last.prescribedWeightKg, 60);
      expect(exercises[0].sets.last.prescribedRepsMin, 8);
      expect(exercises[0].sets.last.prescribedRepsMax, 12);
      expect(exercises[0].sets.last.completed, isFalse);

      expect(exercises[1].sets, hasLength(2));
      expect(exercises[1].sets.last.setIndex, 1);
      expect(exercises[1].sets.last.exerciseId, 2);
      expect(exercises[1].sets.last.completed, isFalse);
    });
  });

  group('substituteExercise', () {
    test(
      'swaps identity, keeps completed set attribution, resets pending sets',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final argument = (
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        );
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider(argument).notifier,
        );
        await controller.future;

        await controller.toggleSetCompleted(
          exerciseId: 'ex-1',
          setId: 'set-1',
          completed: true,
        );
        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: 'set-2',
          updatedSet: _sampleSession().exercises[0].sets[1].copyWith(
            actualReps: 9,
            actualWeightKg: 61,
          ),
        );

        await controller.substituteExercise(
          sessionExerciseId: 'ex-1',
          replacementExerciseId: 99,
          replacementExerciseName: 'Dumbbell Bench Press',
        );

        final session = container
            .read(AppProviders.workoutRunnerControllerProvider(argument))
            .requireValue
            .session!;
        final swapped = session.exercises.first;
        expect(swapped.id, 'ex-1');
        expect(swapped.exerciseId, 99);
        expect(swapped.exerciseName, 'Dumbbell Bench Press');

        final completedSet = swapped.sets[0];
        expect(completedSet.id, 'set-1');
        expect(completedSet.completed, isTrue);
        expect(completedSet.exerciseId, 1);

        final pendingSet = swapped.sets[1];
        expect(pendingSet.id, 'set-2');
        expect(pendingSet.exerciseId, 99);
        expect(pendingSet.completed, isFalse);
        expect(pendingSet.skipped, isFalse);
        expect(pendingSet.actualReps, isNull);
        expect(pendingSet.actualWeightKg, isNull);
        expect(pendingSet.prescribedWeightKg, 60.0);
        expect(pendingSet.prescribedRepsMin, 8);
        expect(pendingSet.prescribedRepsMax, 12);
        expect(pendingSet.setIndex, 1);

        final untouched = session.exercises[1];
        expect(untouched.exerciseId, 2);
        expect(untouched.exerciseName, 'Overhead Press');
        expect(untouched.sets.single.exerciseId, 2);
      },
    );

    test('does nothing for the same exercise or a paused session', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final argument = (
        mode: WorkoutRunnerMode.savedWorkout,
        savedWorkoutId: 'sw-1',
        programId: null,
        programWorkoutId: null,
      );
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider(argument).notifier,
      );
      await controller.future;

      await controller.substituteExercise(
        sessionExerciseId: 'ex-1',
        replacementExerciseId: 1,
        replacementExerciseName: 'Ignored',
      );

      var exercise = container
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .requireValue
          .session!
          .exercises
          .first;
      expect(exercise.exerciseId, 1);
      expect(exercise.exerciseName, 'Bench Press');

      await controller.pauseWorkout();
      await controller.substituteExercise(
        sessionExerciseId: 'ex-1',
        replacementExerciseId: 99,
        replacementExerciseName: 'Dumbbell Bench Press',
      );

      final state = container
          .read(AppProviders.workoutRunnerControllerProvider(argument))
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.paused);
      exercise = state.session!.exercises.first;
      expect(exercise.exerciseId, 1);
      expect(exercise.exerciseName, 'Bench Press');
    });
  });

  group('toggleSetCompleted', () {
    test('marks a set completed and clears skipped', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.toggleSetCompleted(
        exerciseId: 'ex-1',
        setId: 'set-1',
        completed: true,
      );

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      final updatedSet = state.session!.exercises[0].sets[0];
      expect(updatedSet.completed, isTrue);
      expect(updatedSet.skipped, isFalse);
    });
  });

  group('toggleSetSkipped', () {
    test('marks a set skipped and clears completed', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.toggleSetSkipped(
        exerciseId: 'ex-1',
        setId: 'set-1',
        skipped: true,
      );

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      final updatedSet = state.session!.exercises[0].sets[0];
      expect(updatedSet.skipped, isTrue);
      expect(updatedSet.completed, isFalse);
    });
  });

  group('pause and continue', () {
    test('pauseWorkout sets phase to paused', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.pauseWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.paused);
      expect(state.session!.durationSeconds, isNotNull);
      expect(state.session!.durationSeconds, greaterThanOrEqualTo(0));
    });

    test('continueWorkout sets phase to ready', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.pauseWorkout();
      await controller.continueWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.ready);
      expect(state.session!.durationSeconds, isNull);
      expect(fakeSave.saveCallCount, 2);
      expect(fakeSave.lastSavedSession!.durationSeconds, isNull);
    });
  });

  group('saveProgress', () {
    test(
      'preserves and persists a set edit made while save is pending',
      () async {
        final pendingSave = Completer<void>();
        fakeSave.pendingSave = pendingSave;
        final container = createContainer();
        addTearDown(container.dispose);
        final argument = (
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        );
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider(argument).notifier,
        );
        await controller.future;

        final saveFuture = controller.saveProgress();
        await Future<void>.delayed(Duration.zero);
        final set = container
            .read(AppProviders.workoutRunnerControllerProvider(argument))
            .requireValue
            .session!
            .exercises
            .first
            .sets
            .first;
        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: set.id,
          updatedSet: set.copyWith(actualReps: 11),
        );
        pendingSave.complete();
        await saveFuture;

        final state = container
            .read(AppProviders.workoutRunnerControllerProvider(argument))
            .requireValue;
        expect(state.phase, WorkoutRunnerPhase.ready);
        expect(state.session!.exercises.first.sets.first.actualReps, 11);

        await Future<void>.delayed(const Duration(seconds: 3));

        expect(fakeSave.saveCallCount, 2);
        expect(
          fakeSave.lastSavedSession!.exercises.first.sets.first.actualReps,
          11,
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('saves and returns to ready', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.saveProgress();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.ready);
    });

    test('sets failure when save throws', () async {
      fakeSave.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.saveProgress();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.failure);
    });

    test('does nothing when session is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.saveProgress();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.ready);
    });
  });

  group('auto-save', () {
    test(
      'triggers save after debounce when set is updated',
      () async {
        fakeSave.saveCallCount = 0;
        final container = createContainer();
        final subscription = container.listen(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.savedWorkout,
            savedWorkoutId: 'sw-1',
            programId: null,
            programWorkoutId: null,
          )),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.savedWorkout,
            savedWorkoutId: 'sw-1',
            programId: null,
            programWorkoutId: null,
          )).notifier,
        );
        await controller.future;

        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: 'set-1',
          updatedSet: _sampleSession().exercises[0].sets[0].copyWith(
            actualReps: 10,
          ),
        );

        expect(fakeSave.saveCallCount, 0);

        await Future.delayed(const Duration(seconds: 3));

        expect(fakeSave.saveCallCount, 1);
        expect(fakeSave.lastSavedSession, isNotNull);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'rapid edits only trigger one save',
      () async {
        fakeSave.saveCallCount = 0;
        final container = createContainer();
        final subscription = container.listen(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.savedWorkout,
            savedWorkoutId: 'sw-1',
            programId: null,
            programWorkoutId: null,
          )),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        final controller = container.read(
          AppProviders.workoutRunnerControllerProvider((
            mode: WorkoutRunnerMode.savedWorkout,
            savedWorkoutId: 'sw-1',
            programId: null,
            programWorkoutId: null,
          )).notifier,
        );
        await controller.future;

        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: 'set-1',
          updatedSet: _sampleSession().exercises[0].sets[0].copyWith(
            actualReps: 10,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));

        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: 'set-1',
          updatedSet: _sampleSession().exercises[0].sets[0].copyWith(
            actualReps: 12,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));

        await controller.updateSet(
          exerciseId: 'ex-1',
          setId: 'set-1',
          updatedSet: _sampleSession().exercises[0].sets[0].copyWith(
            actualReps: 8,
          ),
        );

        await Future.delayed(const Duration(seconds: 3));

        expect(fakeSave.saveCallCount, 1);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });

  group('completeWorkout', () {
    test('completes session and sets phase to completed', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.completeWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.completed);
      expect(state.session!.status, WorkoutSessionStatus.completed);
      expect(state.session!.completedAt, isNotNull);
      expect(state.session!.durationSeconds, greaterThan(0));
    });

    test('sets failure when complete throws', () async {
      fakeComplete.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.completeWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.failure);
    });

    test('completion failure leaves session recoverable', () async {
      fakeComplete.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.completeWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.failure);
      expect(state.session!.status, WorkoutSessionStatus.inProgress);
    });
  });

  group('cancelWorkout', () {
    test('abandons session and sets phase to completed', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.cancelWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.completed);
      expect(fakeAbandon.lastAbandonedId, 'session-1');
    });

    test('sets failure when abandon throws', () async {
      fakeAbandon.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.cancelWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.phase, WorkoutRunnerPhase.failure);
    });

    test('does nothing when session is null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.resume,
          savedWorkoutId: null,
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.cancelWorkout();

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.resume,
              savedWorkoutId: null,
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.session, isNull);
      expect(fakeAbandon.lastAbandonedId, isNull);
    });
  });

  group('updateSessionNotes', () {
    test('updates session notes', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateSessionNotes('Great session');

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.session!.notes, 'Great session');
    });
  });

  group('updateEnergyLevel', () {
    test('updates energy level', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateEnergyLevel(7);

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.session!.energyLevel, 7);
    });
  });

  group('updatePerceivedDifficulty', () {
    test('updates perceived difficulty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updatePerceivedDifficulty(6);

      final state = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue;
      expect(state.session!.perceivedDifficulty, 6);
    });
  });
}
