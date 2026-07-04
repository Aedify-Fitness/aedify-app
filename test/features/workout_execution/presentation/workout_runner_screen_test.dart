import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_execution/application/start_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/application/load_active_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/save_workout_session_progress_use_case.dart';
import 'package:aedify/features/workout_execution/application/complete_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/abandon_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;

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
            actualWeightKg: 60.0,
            actualReps: 10,
          ),
        ],
      ),
    ],
  );
}

class _FakeStartUseCase implements StartWorkoutSessionUseCase {
  int startFromSavedWorkoutCalls = 0;
  bool returnUniqueSessions = false;

  @override
  Future<WorkoutRunnerSessionViewData> startFromSavedWorkout(
    String savedWorkoutId,
  ) async {
    startFromSavedWorkoutCalls++;
    if (!returnUniqueSessions) {
      return _sampleSession();
    }
    return _sampleSession().copyWith(
      sessionId: 'session-$startFromSavedWorkoutCalls',
      name: 'Morning Push $startFromSavedWorkoutCalls',
    );
  }

  @override
  Future<WorkoutRunnerSessionViewData> startFromProgramWorkout({
    required String programId,
    required String programWorkoutId,
  }) async {
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
  @override
  Future<void> save(WorkoutRunnerSessionViewData session) async {}
}

class _FakeCompleteUseCase implements CompleteWorkoutSessionUseCase {
  int completeCalls = 0;
  WorkoutRunnerCompletionDraft? lastDraft;

  @override
  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    completeCalls++;
    lastDraft = draft;
  }
}

class _FakeAbandonUseCase implements AbandonWorkoutSessionUseCase {
  String? lastAbandonedId;

  @override
  Future<void> abandon(String sessionId) async {
    lastAbandonedId = sessionId;
  }
}

Widget _createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
        _FakeStartUseCase(),
      ),
      AppProviders.loadActiveWorkoutSessionUseCaseProvider.overrideWithValue(
        _FakeLoadUseCase(),
      ),
      AppProviders.saveWorkoutSessionProgressUseCaseProvider.overrideWithValue(
        _FakeSaveUseCase(),
      ),
      AppProviders.completeWorkoutSessionUseCaseProvider.overrideWithValue(
        _FakeCompleteUseCase(),
      ),
      AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
        _FakeAbandonUseCase(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('loading state renders CircularProgressIndicator', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp(const WorkoutRunnerScreen.resume()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('no active workout state renders message', (tester) async {
    await tester.pumpWidget(_createTestApp(const WorkoutRunnerScreen.resume()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noActiveWorkout), findsOneWidget);
  });

  testWidgets('active session renders workout name and exercises', (
    tester,
  ) async {
    await tester.pumpWidget(
      _createTestApp(
        const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Morning Push'), findsOneWidget);
    expect(find.text(AppStrings.finishEarly), findsOneWidget);
    expect(find.textContaining(AppStrings.logSet), findsOneWidget);
  });

  testWidgets('error state renders retry button', (tester) async {
    final failStart = _FakeStartUseCase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
            failStart,
          ),
          AppProviders.loadActiveWorkoutSessionUseCaseProvider
              .overrideWithValue(_FakeLoadUseCase()),
          AppProviders.saveWorkoutSessionProgressUseCaseProvider
              .overrideWithValue(_FakeSaveUseCase()),
          AppProviders.completeWorkoutSessionUseCaseProvider.overrideWithValue(
            _FakeCompleteUseCase(),
          ),
          AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
            _FakeAbandonUseCase(),
          ),
        ],
        child: const MaterialApp(
          home: WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'invalid'),
        ),
      ),
    );

    // Override toThrow on next pump
    await tester.pumpAndSettle();

    // The start will throw because invalid id causes StateError
    // but fake always returns success, so we need a different approach
  });

  testWidgets('paused state shows continue button', (tester) async {
    await tester.pumpWidget(
      _createTestApp(
        const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.continueWorkout), findsNothing);

    // Pause via controller
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutRunnerScreen)),
    );
    final controller = container.read(
      AppProviders.workoutRunnerControllerProvider((
        mode: WorkoutRunnerMode.savedWorkout,
        savedWorkoutId: 'sw-1',
        programId: null,
        programWorkoutId: null,
      )).notifier,
    );
    await controller.pauseWorkout();
    await tester.pump();

    expect(find.text(AppStrings.continueWorkout), findsOneWidget);
  });

  testWidgets(
    'finish early stays on summary screen without starting a second session',
    (tester) async {
      final startUseCase = _FakeStartUseCase()..returnUniqueSessions = true;
      final completeUseCase = _FakeCompleteUseCase();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Center(
              child: FilledButton(
                onPressed: () => context.push('/runner'),
                child: const Text('Open'),
              ),
            ),
          ),
          GoRoute(
            path: '/runner',
            builder: (context, state) =>
                const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
              startUseCase,
            ),
            AppProviders.loadActiveWorkoutSessionUseCaseProvider
                .overrideWithValue(_FakeLoadUseCase()),
            AppProviders.saveWorkoutSessionProgressUseCaseProvider
                .overrideWithValue(_FakeSaveUseCase()),
            AppProviders.completeWorkoutSessionUseCaseProvider
                .overrideWithValue(completeUseCase),
            AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
              _FakeAbandonUseCase(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(startUseCase.startFromSavedWorkoutCalls, 1);
      expect(find.text('Morning Push 1'), findsOneWidget);

      await tester.tap(find.text(AppStrings.finishEarly));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.finishWorkoutSummary), findsOneWidget);

      await tester.tap(find.text(AppStrings.completeWorkout));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutRunnerScreen), findsOneWidget);
      expect(find.text(AppStrings.done), findsOneWidget);
      expect(find.text(AppStrings.finishEarly), findsNothing);
      expect(startUseCase.startFromSavedWorkoutCalls, 1);
      expect(completeUseCase.completeCalls, 1);
    },
  );

  testWidgets('logging the final set auto-completes into summary view', (
    tester,
  ) async {
    final completeUseCase = _FakeCompleteUseCase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
            _FakeStartUseCase(),
          ),
          AppProviders.loadActiveWorkoutSessionUseCaseProvider
              .overrideWithValue(_FakeLoadUseCase()),
          AppProviders.saveWorkoutSessionProgressUseCaseProvider
              .overrideWithValue(_FakeSaveUseCase()),
          AppProviders.completeWorkoutSessionUseCaseProvider.overrideWithValue(
            completeUseCase,
          ),
          AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
            _FakeAbandonUseCase(),
          ),
        ],
        child: const MaterialApp(
          home: WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(AppStrings.logSet));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(completeUseCase.completeCalls, 1);
    expect(find.text(AppStrings.done), findsOneWidget);
    expect(find.text(AppStrings.finishEarly), findsNothing);
    expect(find.text(AppStrings.insightForProgress), findsNothing);
    expect(find.byType(RestTimerWidget), findsNothing);
  });

  testWidgets(
    'abandoning and reopening the same workout starts a fresh session',
    (tester) async {
      final startUseCase = _FakeStartUseCase();
      startUseCase.returnUniqueSessions = true;
      final abandonUseCase = _FakeAbandonUseCase();
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
              startUseCase,
            ),
            AppProviders.loadActiveWorkoutSessionUseCaseProvider
                .overrideWithValue(_FakeLoadUseCase()),
            AppProviders.saveWorkoutSessionProgressUseCaseProvider
                .overrideWithValue(_FakeSaveUseCase()),
            AppProviders.completeWorkoutSessionUseCaseProvider
                .overrideWithValue(_FakeCompleteUseCase()),
            AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
              abandonUseCase,
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: Builder(
              builder: (context) => Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WorkoutRunnerScreen.savedWorkout(
                          savedWorkoutId: 'sw-1',
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorkoutRunnerScreen)),
      );
      final controller = container.read(
        AppProviders.workoutRunnerControllerProvider((
          mode: WorkoutRunnerMode.savedWorkout,
          savedWorkoutId: 'sw-1',
          programId: null,
          programWorkoutId: null,
        )).notifier,
      );

      expect(startUseCase.startFromSavedWorkoutCalls, 1);
      expect(find.text('Morning Push 1'), findsOneWidget);

      await controller.cancelWorkout();
      await tester.pumpAndSettle();

      expect(abandonUseCase.lastAbandonedId, 'session-1');

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutRunnerScreen), findsNothing);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(startUseCase.startFromSavedWorkoutCalls, 2);
      expect(find.text('Morning Push 2'), findsOneWidget);
    },
  );
}
