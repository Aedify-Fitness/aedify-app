import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/workout_execution/application/abandon_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';
import 'package:aedify/features/workout_execution/application/complete_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/load_active_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/save_workout_session_progress_use_case.dart';
import 'package:aedify/features/workout_execution/application/start_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/finish_early_session_complete_screen.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/exit_workout_sheet.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_duration_timer.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _RunnerFixtures {
  _RunnerFixtures._();

  static WorkoutRunnerSessionViewData currentSession(WidgetTester tester) =>
      ProviderScope.containerOf(
            tester.element(find.byType(WorkoutRunnerScreen)),
          )
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue
          .session!;

  static WorkoutRunnerSessionViewData referenceSession() {
    final now = DateTime.now().subtract(const Duration(minutes: 12));
    return WorkoutRunnerSessionViewData(
      sessionId: 'session-reference',
      name: 'Push A — Upper Hypertrophy',
      source: SessionSource.savedWorkout,
      status: WorkoutSessionStatus.inProgress,
      startedAt: now,
      exercises: [
        WorkoutRunnerExerciseItem(
          id: 'flat-bench-session-exercise',
          exerciseId: 1,
          exerciseName: 'Flat Bench Press',
          sortOrder: 0,
          sets: [
            WorkoutRunnerSetItem(
              id: 'warmup-1',
              exerciseId: 1,
              setIndex: 0,
              setType: SetType.warmup,
              performedAt: now,
              completed: true,
              skipped: false,
              prescribedRepsExact: 12,
              prescribedWeightKg: 40,
              actualReps: 12,
              actualWeightKg: 40,
              restSeconds: 60,
            ),
            WorkoutRunnerSetItem(
              id: 'working-1',
              exerciseId: 1,
              setIndex: 1,
              setType: SetType.working,
              performedAt: now,
              completed: false,
              skipped: false,
              prescribedRepsMin: 8,
              prescribedRepsMax: 10,
              prescribedWeightKg: 82.5,
              actualReps: 8,
              actualWeightKg: 82.5,
              restSeconds: 90,
            ),
            WorkoutRunnerSetItem(
              id: 'working-2',
              exerciseId: 1,
              setIndex: 2,
              setType: SetType.working,
              performedAt: now,
              completed: false,
              skipped: false,
              prescribedRepsMin: 8,
              prescribedRepsMax: 10,
              prescribedWeightKg: 82.5,
              restSeconds: 90,
            ),
          ],
        ),
        WorkoutRunnerExerciseItem(
          id: 'incline-session-exercise',
          exerciseId: 2,
          exerciseName: 'Incline DB Press',
          sortOrder: 1,
          supersetGroupId: 'superset-a',
          supersetOrder: 0,
          sets: [
            WorkoutRunnerSetItem(
              id: 'incline-1',
              exerciseId: 2,
              setIndex: 0,
              setType: SetType.working,
              performedAt: now,
              completed: false,
              skipped: false,
              prescribedRepsExact: 10,
              prescribedWeightKg: 30,
            ),
          ],
        ),
        WorkoutRunnerExerciseItem(
          id: 'lateral-session-exercise',
          exerciseId: 3,
          exerciseName: 'Lateral Raises',
          sortOrder: 2,
          supersetGroupId: 'superset-a',
          supersetOrder: 1,
          sets: [
            WorkoutRunnerSetItem(
              id: 'lateral-1',
              exerciseId: 3,
              setIndex: 0,
              setType: SetType.working,
              performedAt: now,
              completed: false,
              skipped: false,
              prescribedRepsExact: 12,
              prescribedWeightKg: 10,
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutRunnerSessionViewData activeSupersetSession() {
    final session = referenceSession();
    final completedLead = session.exercises.first.copyWith(
      sets: session.exercises.first.sets
          .map((set) => set.copyWith(completed: true))
          .toList(),
    );
    return session.copyWith(
      exercises: [completedLead, ...session.exercises.skip(1)],
    );
  }

  static WorkoutRunnerSessionViewData pairedSupersetSession({
    bool warmupsCompleted = true,
  }) {
    final session = activeSupersetSession();
    return session.copyWith(
      exercises: [
        session.exercises.first,
        for (final member in session.exercises.skip(1))
          member.copyWith(
            sets: [
              for (var round = 0; round < 2; round++)
                member.sets.first.copyWith(
                  id: '${member.id}-warmup-$round',
                  setIndex: round,
                  setType: SetType.warmup,
                  completed: warmupsCompleted,
                  prescribedWeightKg: 5,
                  prescribedRepsExact: 12,
                  restSeconds: 60,
                ),
              for (var round = 0; round < 2; round++)
                member.sets.first.copyWith(
                  id: '${member.id}-working-$round',
                  setIndex: round + 2,
                  restSeconds: 90,
                ),
            ],
          ),
      ],
    );
  }

  static WorkoutRunnerSessionViewData finalSetSession() {
    final now = DateTime.now().subtract(const Duration(minutes: 5));
    return WorkoutRunnerSessionViewData(
      sessionId: 'session-final',
      name: 'Final Set Session',
      source: SessionSource.savedWorkout,
      status: WorkoutSessionStatus.inProgress,
      startedAt: now,
      exercises: [
        WorkoutRunnerExerciseItem(
          id: 'final-exercise',
          exerciseId: 1,
          exerciseName: 'Flat Bench Press',
          sortOrder: 0,
          sets: [
            WorkoutRunnerSetItem(
              id: 'final-set',
              exerciseId: 1,
              setIndex: 0,
              setType: SetType.working,
              performedAt: now,
              completed: false,
              skipped: false,
              prescribedRepsExact: 8,
              prescribedWeightKg: 80,
              actualReps: 8,
              actualWeightKg: 80,
            ),
          ],
        ),
      ],
    );
  }

  static ExerciseDetailViewData exerciseDetail(int id) {
    return ExerciseDetailViewData(
      id: id,
      name: id == 1 ? 'Flat Bench Press' : 'Exercise $id',
      difficulty: null,
      primaryMuscles: const ['Chest'],
      muscleGroups: const {},
      category: 'Strength',
      modality: ExerciseModality.strength,
      equipment: null,
      force: null,
      mechanic: null,
      grips: const [],
      steps: const ['Control the eccentric.', 'Press with stable shoulders.'],
      videos: const [
        ExerciseDetailVideoViewData(
          url: 'https://example.com/exercise.mp4',
          angle: ExerciseVideoAngle.front,
          gender: ExerciseVideoGender.unknown,
          ogImageUrl: null,
        ),
      ],
      isFavorite: false,
      isSubstitutedOut: false,
    );
  }
}

class _FakeStartUseCase implements StartWorkoutSessionUseCase {
  _FakeStartUseCase(this.sessionFactory);

  final WorkoutRunnerSessionViewData Function() sessionFactory;
  bool shouldThrow = false;
  bool returnUniqueSessions = false;
  int calls = 0;

  @override
  Future<WorkoutRunnerSessionViewData> startStandalone() =>
      startFromSavedWorkout('standalone');

  @override
  Future<WorkoutRunnerSessionViewData> repeatCompleted(String sessionId) =>
      startFromSavedWorkout(sessionId);

  @override
  Future<WorkoutRunnerSessionViewData> startFromSavedWorkout(
    String savedWorkoutId,
  ) async {
    calls++;
    if (shouldThrow) throw Exception('start failed');
    final session = sessionFactory();
    return returnUniqueSessions
        ? session.copyWith(
            sessionId: '${session.sessionId}-$calls',
            name: '${session.name} $calls',
          )
        : session;
  }

  @override
  Future<WorkoutRunnerSessionViewData> startFromProgramWorkout({
    required String programId,
    required String programWorkoutId,
  }) => startFromSavedWorkout(programWorkoutId);
}

class _FakeLoadUseCase implements LoadActiveWorkoutSessionUseCase {
  WorkoutRunnerSessionViewData? sessionToReturn;
  bool shouldThrow = false;

  @override
  Future<WorkoutRunnerSessionViewData?> load() async {
    if (shouldThrow) throw Exception('load failed');
    return sessionToReturn;
  }
}

class _FakeSaveUseCase implements SaveWorkoutSessionProgressUseCase {
  WorkoutRunnerSessionViewData? lastSavedSession;
  bool shouldThrow = false;

  @override
  Future<void> save(WorkoutRunnerSessionViewData session) async {
    lastSavedSession = session;
    if (shouldThrow) throw StateError('private save failure');
  }
}

class _FakeCompleteUseCase implements CompleteWorkoutSessionUseCase {
  int calls = 0;
  WorkoutRunnerCompletionDraft? lastDraft;
  Completer<void>? pending;

  @override
  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    calls++;
    lastDraft = draft;
    if (pending != null) await pending!.future;
  }
}

class _FakeAbandonUseCase implements AbandonWorkoutSessionUseCase {
  String? lastAbandonedId;

  @override
  Future<void> abandon(String sessionId) async {
    lastAbandonedId = sessionId;
  }
}

class _StubExerciseSearchController extends Notifier<ExerciseSearchState>
    implements ExerciseSearchController {
  @override
  ExerciseSearchState build() {
    return const ExerciseSearchState(
      filters: ExerciseFilterState(),
      items: [
        ExerciseListItem(
          id: 42,
          name: 'Dumbbell Bench Press',
          difficulty: null,
          muscleGroups: {},
          modality: ExerciseModality.strength,
          equipment: null,
          isFavorite: false,
          isSubstitutedOut: false,
        ),
      ],
      isLoading: false,
    );
  }

  @override
  Future<void> updateSearchQuery(String query) async {}

  @override
  Future<void> updateFilters(ExerciseFilterState filters) async {}

  @override
  Future<void> clearFilters() async {}

  @override
  Future<void> reload() async {}
}

class _TestDependencies {
  _TestDependencies({WorkoutRunnerSessionViewData Function()? sessionFactory})
    : start = _FakeStartUseCase(
        sessionFactory ?? _RunnerFixtures.referenceSession,
      );

  final _FakeStartUseCase start;
  final _FakeLoadUseCase load = _FakeLoadUseCase();
  final _FakeSaveUseCase save = _FakeSaveUseCase();
  final _FakeCompleteUseCase complete = _FakeCompleteUseCase();
  final _FakeAbandonUseCase abandon = _FakeAbandonUseCase();
}

Widget _withProviders({
  required _TestDependencies dependencies,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
        dependencies.start,
      ),
      AppProviders.loadActiveWorkoutSessionUseCaseProvider.overrideWithValue(
        dependencies.load,
      ),
      AppProviders.saveWorkoutSessionProgressUseCaseProvider.overrideWithValue(
        dependencies.save,
      ),
      AppProviders.completeWorkoutSessionUseCaseProvider.overrideWithValue(
        dependencies.complete,
      ),
      AppProviders.abandonWorkoutSessionUseCaseProvider.overrideWithValue(
        dependencies.abandon,
      ),
      AppProviders.exerciseDetailControllerProvider.overrideWith(
        (_, id) async => _RunnerFixtures.exerciseDetail(id),
      ),
      AppProviders.exerciseSearchControllerProvider.overrideWith(
        _StubExerciseSearchController.new,
      ),
    ],
    child: child,
  );
}

Widget _testApp({
  required _TestDependencies dependencies,
  required Widget home,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
  bool accessible = false,
}) {
  return _withProviders(
    dependencies: dependencies,
    child: MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: textScaler,
          highContrast: accessible,
          disableAnimations: accessible,
          accessibleNavigation: accessible,
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

Widget _routerApp({
  required _TestDependencies dependencies,
  required GoRouter router,
  ThemeData? theme,
}) {
  return _withProviders(
    dependencies: dependencies,
    child: MaterialApp.router(
      theme: theme ?? AppTheme.lightTheme,
      routerConfig: router,
    ),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
}

Future<void> _pumpLoaded(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Finder _fieldFor(String key) => find.descendant(
  of: find.byKey(ValueKey<String>(key)),
  matching: find.byType(TextField),
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('loading state renders a progress indicator', (tester) async {
    final dependencies = _TestDependencies();

    await tester.pumpWidget(
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.resume(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('no active workout state renders its message', (tester) async {
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.resume(),
      ),
    );

    expect(find.text(AppStrings.noActiveWorkout), findsOneWidget);
  });

  testWidgets('workout duration timer counts up and freezes while paused', (
    tester,
  ) async {
    var now = DateTime(2026, 8, 6, 10, 12, 34);
    final startedAt = DateTime(2026, 8, 6, 10);

    Widget timer({
      required DateTime sessionStartedAt,
      required bool isPaused,
      int? pausedDurationSeconds,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: WorkoutDurationTimer(
            startedAt: sessionStartedAt,
            isPaused: isPaused,
            pausedDurationSeconds: pausedDurationSeconds,
            now: () => now,
          ),
        ),
      );
    }

    await tester.pumpWidget(
      timer(sessionStartedAt: startedAt, isPaused: false),
    );
    expect(find.text('12:34'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('12:35'), findsOneWidget);

    await tester.pumpWidget(
      timer(
        sessionStartedAt: startedAt,
        isPaused: true,
        pausedDurationSeconds: 755,
      ),
    );
    await tester.pump();
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(find.text('12:35'), findsOneWidget);

    final resumedAt = now.subtract(const Duration(seconds: 755));
    await tester.pumpWidget(
      timer(sessionStartedAt: resumedAt, isPaused: false),
    );
    await tester.pump();
    expect(find.text('12:35'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('12:36'), findsOneWidget);
  });

  testWidgets('workout duration timer formats hours and clamps future starts', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 6, 12, 2, 3);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: WorkoutDurationTimer(
            startedAt: DateTime(2026, 8, 6, 11),
            isPaused: false,
            now: () => now,
          ),
        ),
      ),
    );
    expect(find.text('01:02:03'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: WorkoutDurationTimer(
            startedAt: now.add(const Duration(minutes: 1)),
            isPaused: false,
            now: () => now,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('rest timer survives rebuilds and retains added time', (
    tester,
  ) async {
    var dismissCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: RestTimerWidget(seconds: 90, onDismiss: () => dismissCalls++),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('01:29'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: RestTimerWidget(seconds: 90, onDismiss: () => dismissCalls++),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('01:29'), findsOneWidget);

    await tester.tap(find.text(AppStrings.restPlus15));
    await tester.pump();
    expect(find.text('01:44'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('01:43'), findsOneWidget);
    expect(dismissCalls, 0);
  });

  testWidgets(
    'short large-text viewport keeps bounded rest controls reachable',
    (tester) async {
      _setViewport(tester, const Size(320, 568));
      final dependencies = _TestDependencies();
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: dependencies,
          textScaler: const TextScaler.linear(2),
          home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      );
      final log = find.byKey(const Key('workout_runner_log_set'));
      await tester.tap(log);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('workout_runner_rest_timer_ring')),
        findsOneWidget,
      );
      final skip = find.byKey(const Key('workout_runner_rest_skip'));
      final restScrollable = find
          .ancestor(of: skip, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(restScrollable).position;
      expect(tester.getSize(restScrollable).height, lessThanOrEqualTo(568 / 2));
      expect(position.maxScrollExtent, greaterThan(0));
      await tester.scrollUntilVisible(skip, 96, scrollable: restScrollable);
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(0));
      expect(skip.hitTestable(), findsOneWidget);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(find.byType(RestTimerWidget), findsNothing);
      expect(log.hitTestable(), findsOneWidget);
      expect(
        find.byKey(const Key('workout_runner_finish')).hitTestable(),
        findsOneWidget,
      );
      expect(dependencies.complete.calls, 0);
      expect(dependencies.abandon.lastAbandonedId, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'prioritizes the current exercise, session duration and logging action',
    (tester) async {
      _setViewport(tester, const Size(390, 844));
      final dependencies = _TestDependencies();
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: dependencies,
          home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      );
      final header = find.byKey(const Key('workout_runner_header'));
      expect(header, findsOneWidget);
      expect(find.text('Flat Bench Press'), findsWidgets);
      expect(
        find.descendant(of: header, matching: find.text('Flat Bench Press')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: header,
          matching: find.byType(WorkoutDurationTimer),
        ),
        findsOneWidget,
      );
      expect(find.byType(RestTimerWidget), findsNothing);
      expect(
        find.byKey(const Key('workout_runner_training_log')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('workout_runner_log_set')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('workout_runner_finish')).hitTestable(),
        findsOneWidget,
      );
      expect(find.byKey(const Key('workout_runner_insight')), findsNothing);
      final media = find.byKey(const Key('workout_runner_media'));
      final guide = find.byKey(const Key('workout_runner_media_guide'));
      await tester.ensureVisible(media);
      await tester.pumpAndSettle();
      final mediaSize = tester.getSize(media);
      expect(mediaSize.width / mediaSize.height, closeTo(16 / 9, 0.01));
      expect(
        tester.getTopLeft(media).dy,
        greaterThanOrEqualTo(tester.getBottomRight(header).dy),
      );
      expect(guide.hitTestable(), findsOneWidget);
      final log = tester.getRect(
        find.byKey(const Key('workout_runner_log_set')),
      );
      final finish = tester.getRect(
        find.byKey(const Key('workout_runner_finish')),
      );
      expect(log.center.dy, closeTo(finish.center.dy, 0.01));
      expect(log.width, greaterThan(finish.width));
      expect(log.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders each active superset member and its actual set rows', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies(
      sessionFactory: _RunnerFixtures.activeSupersetSession,
    );
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    expect(find.text('Superset Block 1'), findsOneWidget);
    expect(
      find.byKey(const Key('workout_runner_superset_block')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('workout_runner_substitute')), findsNothing);
    expect(find.text('A. Incline DB Press'), findsWidgets);
    expect(find.text('B. Lateral Raises'), findsWidgets);
    expect(
      find.byKey(const Key('workout_runner_set_row_incline-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_set_row_lateral-1')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.logSet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'groups warm-ups before working rounds without losing superset order',
    (tester) async {
      _setViewport(tester, const Size(390, 844));
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: _TestDependencies(
            sessionFactory: _RunnerFixtures.pairedSupersetSession,
          ),
          home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      );
      double? previousRoundBottom;
      for (final type in ['warmup', 'working']) {
        for (var round = 0; round < 2; round++) {
          final group = find.byKey(
            ValueKey('workout_runner_superset_round_${type}_$round'),
          );
          final first = find.byKey(
            ValueKey(
              'workout_runner_set_row_incline-session-exercise-$type-$round',
            ),
          );
          final second = find.byKey(
            ValueKey(
              'workout_runner_set_row_lateral-session-exercise-$type-$round',
            ),
          );
          expect(group, findsOneWidget);
          expect(first, findsOneWidget);
          expect(second, findsOneWidget);
          final headingTop = tester.getTopLeft(group).dy;
          if (previousRoundBottom != null) {
            expect(headingTop, greaterThanOrEqualTo(previousRoundBottom));
          }
          expect(headingTop, lessThan(tester.getTopLeft(first).dy));
          expect(
            tester.getTopLeft(first).dy,
            lessThan(tester.getTopLeft(second).dy),
          );
          previousRoundBottom = tester.getBottomLeft(second).dy;
        }
      }
      final warmup = find.byKey(
        const Key('workout_runner_superset_round_warmup_1'),
      );
      final working = find.byKey(
        const Key('workout_runner_superset_round_working_0'),
      );
      expect(
        tester.getTopLeft(warmup).dy,
        lessThan(tester.getTopLeft(working).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final warmupsCompleted in [false, true]) {
    final prefix = warmupsCompleted ? 'S' : 'W';
    final type = warmupsCompleted ? 'working' : 'warmup';
    testWidgets(
      'superset $prefix rounds rest below the independent duration clock',
      (tester) async {
        _setViewport(tester, const Size(390, 1450));
        final dependencies = _TestDependencies(
          sessionFactory: () => _RunnerFixtures.pairedSupersetSession(
            warmupsCompleted: warmupsCompleted,
          ),
        );
        await _pumpLoaded(
          tester,
          _testApp(
            dependencies: dependencies,
            home: const WorkoutRunnerScreen.savedWorkout(
              savedWorkoutId: 'sw-1',
            ),
          ),
        );
        final log = find.byKey(
          const ValueKey<String>('workout_runner_log_set'),
        );
        final rest = find.byKey(
          const ValueKey<String>('workout_runner_rest_timer'),
        );
        final header = find.byKey(
          const ValueKey<String>('workout_runner_header'),
        );
        final duration = find.descendant(
          of: header,
          matching: find.byType(WorkoutDurationTimer),
        );
        final startedAt = tester
            .widget<WorkoutDurationTimer>(duration)
            .startedAt;
        final headerRect = tester.getRect(header);
        expect(
          find.byKey(
            ValueKey(
              'workout_runner_active_rail_incline-session-exercise-$type-0',
            ),
          ),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('active_weight_field')),
          warmupsCompleted ? '30' : '5',
        );
        await tester.enterText(
          find.byKey(const Key('active_reps_field')),
          warmupsCompleted ? '10' : '12',
        );
        await tester.pump();
        await tester.tap(log);
        await tester.pumpAndSettle();
        expect(
          find.byKey(
            ValueKey(
              'workout_runner_active_rail_lateral-session-exercise-$type-0',
            ),
          ),
          findsOneWidget,
        );
        expect(rest, findsNothing);

        await tester.enterText(
          find.byKey(const Key('active_weight_field')),
          warmupsCompleted ? '10' : '5',
        );
        await tester.enterText(
          find.byKey(const Key('active_reps_field')),
          '12',
        );
        await tester.pump();
        await tester.tap(log);
        await tester.pumpAndSettle();
        expect(rest, findsOneWidget);
        expect(duration, findsOneWidget);
        expect(
          tester.widget<WorkoutDurationTimer>(duration).startedAt,
          startedAt,
        );
        expect(tester.getRect(header), headerRect);
        expect(
          find.descendant(of: header, matching: find.byType(RestTimerWidget)),
          findsNothing,
        );
        expect(tester.getRect(rest).bottom, lessThanOrEqualTo(1450));
        expect(
          find.byKey(const ValueKey<String>('workout_runner_bottom_actions')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('workout_runner_rest_timer_ring')),
          findsOneWidget,
        );
        expect(find.text(AppStrings.restTime), findsOneWidget);
        expect(find.text(AppStrings.skipRest), findsOneWidget);

        await tester.tap(find.text(AppStrings.restPlus15));
        await tester.pump();
        expect(find.text(warmupsCompleted ? '01:45' : '01:15'), findsOneWidget);
        await tester.tap(find.text(AppStrings.restMinus15));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text(warmupsCompleted ? '01:29' : '00:59'), findsOneWidget);
        expect(
          tester.widget<WorkoutDurationTimer>(duration).startedAt,
          startedAt,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('workout_runner_rest_skip')),
        );
        await tester.pumpAndSettle();
        expect(rest, findsNothing);
        expect(
          find.byKey(
            ValueKey(
              'workout_runner_active_rail_incline-session-exercise-$type-1',
            ),
          ),
          findsOneWidget,
        );
        expect(duration, findsOneWidget);
        expect(dependencies.complete.calls, 0);
        expect(dependencies.abandon.lastAbandonedId, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    testWidgets(
      'superset pairs fit a small phone with large text in ${theme.brightness.name}',
      (tester) async {
        _setViewport(tester, const Size(320, 760));
        await _pumpLoaded(
          tester,
          _testApp(
            dependencies: _TestDependencies(
              sessionFactory: _RunnerFixtures.pairedSupersetSession,
            ),
            home: const WorkoutRunnerScreen.savedWorkout(
              savedWorkoutId: 'sw-1',
            ),
            theme: theme,
            textScaler: const TextScaler.linear(2),
          ),
        );
        expect(
          tester
              .getTopLeft(
                find.byKey(
                  const ValueKey<String>('workout_runner_superset_block'),
                ),
              )
              .dy,
          greaterThanOrEqualTo(
            tester
                .getBottomLeft(
                  find.byKey(const ValueKey<String>('workout_runner_header')),
                )
                .dy,
          ),
        );
        await tester.drag(
          find.byKey(const ValueKey<String>('workout_runner_scroll_view')),
          const Offset(0, -1400),
        );
        await tester.pumpAndSettle();
        expect(find.text('S2 (B)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('keeps resolved sets readable and edits only the active set', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: _TestDependencies(),
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    expect(
      find.byKey(const Key('workout_runner_set_row_warmup-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_set_row_working-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_set_row_working-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_weight_input_working-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_weight_input_working-2')),
      findsNothing,
    );
    expect(find.text(AppStrings.kilogramsAbbreviation), findsOneWidget);
    expect(find.text(AppStrings.repsColumn), findsOneWidget);
    expect(find.text(AppStrings.runnerLive), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(const Key('workout_runner_set_hit_target_warmup-1')),
          )
          .shortestSide,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('logging advances the active set and starts separate rest', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 1236));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_log_set')),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_active_rail_working-1'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_active_rail_working-2'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_weight_input_working-2'),
      ),
      findsOneWidget,
    );
    expect(find.byType(RestTimerWidget), findsOneWidget);
    expect(find.text('01:30'), findsOneWidget);
    final header = find.byKey(const ValueKey<String>('workout_runner_header'));
    expect(
      find.descendant(of: header, matching: find.byType(WorkoutDurationTimer)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: header, matching: find.byType(RestTimerWidget)),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('workout_runner_bottom_actions')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('workout_runner_rest_timer_ring')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.restTime), findsOneWidget);
    expect(find.text(AppStrings.restMinus15), findsOneWidget);
    expect(find.text(AppStrings.restPlus15), findsOneWidget);
    expect(find.text(AppStrings.skipRest), findsOneWidget);
    final restTimerRect = tester.getRect(
      find.byKey(const ValueKey<String>('workout_runner_rest_timer')),
    );
    expect(restTimerRect.left, 0);
    expect(restTimerRect.right, 390);
    expect(restTimerRect.bottom, lessThanOrEqualTo(1236));

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_rest_skip')),
    );
    await tester.pump();
    expect(find.byType(RestTimerWidget), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('workout_runner_bottom_actions')),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutRunnerScreen)),
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
    expect(state.session!.exercises.first.sets[1].completed, isTrue);
  });

  testWidgets(
    'substitute pill opens the picker and swaps the current exercise',
    (tester) async {
      _setViewport(tester, const Size(390, 1236));
      final dependencies = _TestDependencies();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
          ),
        ],
      );

      await _pumpLoaded(
        tester,
        _routerApp(dependencies: dependencies, router: router),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('workout_runner_substitute')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dumbbell Bench Press'), findsOneWidget);

      await tester.tap(find.text('Dumbbell Bench Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.filterConfirmSelection(1)));
      await tester.pumpAndSettle();

      expect(find.text('Dumbbell Bench Press'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorkoutRunnerScreen)),
      );
      final exercise = container
          .read(
            AppProviders.workoutRunnerControllerProvider((
              mode: WorkoutRunnerMode.savedWorkout,
              savedWorkoutId: 'sw-1',
              programId: null,
              programWorkoutId: null,
            )),
          )
          .requireValue
          .session!
          .exercises
          .first;
      expect(exercise.exerciseId, 42);
      expect(exercise.exerciseName, 'Dumbbell Bench Press');
      expect(exercise.sets.first.completed, isTrue);
      expect(exercise.sets.first.exerciseId, 1);
      expect(exercise.sets[1].exerciseId, 42);
      expect(exercise.sets[1].actualWeightKg, isNull);
    },
  );

  testWidgets('Add Set and Add Note update the active session', (tester) async {
    _setViewport(tester, const Size(390, 1236));
    final dependencies = _TestDependencies();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      ],
    );

    await _pumpLoaded(
      tester,
      _routerApp(dependencies: dependencies, router: router),
    );

    final addSet = find.byKey(const ValueKey<String>('workout_runner_add_set'));
    await tester.ensureVisible(addSet);
    await tester.pumpAndSettle();
    await tester.tap(addSet);
    await tester.pump();
    expect(find.text('S3'), findsOneWidget);

    final addNote = find.byKey(
      const ValueKey<String>('workout_runner_add_note'),
    );
    await tester.ensureVisible(addNote);
    await tester.pumpAndSettle();
    await tester.tap(addNote);
    await tester.pumpAndSettle();
    await tester.enterText(
      _fieldFor('workout_runner_note_field'),
      'Keep shoulders pinned',
    );
    await tester.tap(find.text(AppStrings.saveNote));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutRunnerScreen)),
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
    expect(state.session!.exercises.first.sets.length, 4);
    expect(
      state.session!.exercises.first.sets[1].notes,
      'Keep shoulders pinned',
    );
  });

  testWidgets(
    'header and actions stay fixed while the final controls remain reachable',
    (tester) async {
      _setViewport(tester, const Size(390, 844));
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: _TestDependencies(),
          home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      );
      final header = find.byKey(const Key('workout_runner_header'));
      final actions = find.byKey(const Key('workout_runner_bottom_actions'));
      final headerRect = tester.getRect(header);
      final actionsRect = tester.getRect(actions);
      await tester.drag(
        find.byKey(const Key('workout_runner_scroll_view')),
        const Offset(0, -1600),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(header), headerRect);
      expect(tester.getRect(actions), actionsRect);
      final addNote = find.byKey(const Key('workout_runner_add_note'));
      await tester.ensureVisible(addNote);
      await tester.pumpAndSettle();
      expect(addNote.hitTestable(), findsOneWidget);
      expect(
        tester.getBottomRight(addNote).dy,
        lessThanOrEqualTo(actionsRect.top),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('close opens guarded exit and Finish opens completion flow', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_close_button')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ExitWorkoutSheet), findsOneWidget);
    expect(find.text(AppStrings.exitWorkoutTitle), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byType(ExitWorkoutSheet), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_finish')),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.finishWorkoutEarly), findsOneWidget);
  });

  testWidgets('paused state retains runner and exposes Continue', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

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
    expect(
      find.byKey(const ValueKey<String>('workout_runner_training_log')),
      findsOneWidget,
    );
  });

  testWidgets('provider error offers Retry and can recover', (tester) async {
    final dependencies = _TestDependencies();
    dependencies.load.shouldThrow = true;

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.resume(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.workoutRunnerLoadFailed), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    dependencies.load.shouldThrow = false;
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noActiveWorkout), findsOneWidget);
  });

  testWidgets('standalone logging stays open to add sets and exercises', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 1236));
    final dependencies = _TestDependencies(
      sessionFactory: () => _RunnerFixtures.finalSetSession().copyWith(
        source: SessionSource.standalone,
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await _pumpLoaded(
      tester,
      _routerApp(dependencies: dependencies, router: router),
    );

    await tester.tap(find.byKey(const Key('workout_runner_log_set')));
    await tester.pumpAndSettle();

    expect(dependencies.complete.calls, 0);
    expect(find.byType(WorkoutRunnerScreen), findsOneWidget);
    expect(
      _RunnerFixtures.currentSession(
        tester,
      ).exercises.single.sets.single.completed,
      isTrue,
    );
    final addSet = find.byKey(const Key('workout_runner_add_set'));
    await tester.ensureVisible(addSet);
    await tester.tap(addSet);
    await tester.pumpAndSettle();
    final sets = _RunnerFixtures.currentSession(tester).exercises.single.sets;
    expect(sets, hasLength(2));
    expect(sets.first.completed, isTrue);
    expect(sets.last.completed, isFalse);
    expect(sets.last.actualReps, isNull);
    expect(sets.last.actualWeightKg, isNull);
    expect(find.byKey(const Key('active_reps_field')), findsOneWidget);

    final addExercise = find.byKey(const Key('workout_runner_add_exercise'));
    await tester.ensureVisible(addExercise);
    await tester.tap(addExercise);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dumbbell Bench Press'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.filterConfirmSelection(1)));
    await tester.pumpAndSettle();

    final session = _RunnerFixtures.currentSession(tester);
    expect(session.status, WorkoutSessionStatus.inProgress);
    expect(session.exercises.map((exercise) => exercise.exerciseId), [1, 42]);
    expect(session.exercises.last.sets.single.completed, isFalse);
    expect(dependencies.start.calls, 1);
    expect(dependencies.complete.calls, 0);
    expect(
      find.byKey(const Key('workout_runner_finish')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('skipping the final set keeps Restore actionable', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 1236));
    final dependencies = _TestDependencies(
      sessionFactory: _RunnerFixtures.finalSetSession,
    );
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    final skip = find.byKey(const Key('workout_runner_skip_set_final-set'));
    await tester.ensureVisible(skip);
    await tester.tap(skip);
    await tester.pumpAndSettle();

    expect(dependencies.complete.calls, 0);
    expect(
      _RunnerFixtures.currentSession(
        tester,
      ).exercises.single.sets.single.skipped,
      isTrue,
    );
    final restore = find.byTooltip(AppStrings.runnerRestoreSet);
    await tester.ensureVisible(restore);
    expect(restore.hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('workout_runner_add_set')), findsOneWidget);
    await tester.tap(restore);
    await tester.pumpAndSettle();

    final restored = _RunnerFixtures.currentSession(
      tester,
    ).exercises.single.sets.single;
    expect(restored.skipped, isFalse);
    expect(restored.completed, isFalse);
    expect(restored.actualReps, 8);
    expect(restored.actualWeightKg, 80);
    expect(find.byKey(const Key('active_reps_field')), findsOneWidget);
    expect(dependencies.complete.calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'legacy completed set without actuals can be undone and corrected',
    (tester) async {
      _setViewport(tester, const Size(390, 1236));
      final dependencies = _TestDependencies(
        sessionFactory: () {
          final session = _RunnerFixtures.finalSetSession();
          final exercise = session.exercises.single;
          return session.copyWith(
            exercises: [
              exercise.copyWith(
                sets: [
                  WorkoutRunnerSetItem(
                    id: 'final-set',
                    exerciseId: 1,
                    setIndex: 0,
                    setType: SetType.working,
                    performedAt: session.startedAt,
                    completed: true,
                    skipped: false,
                    prescribedRepsExact: 8,
                    prescribedWeightKg: 80,
                  ),
                ],
              ),
            ],
          );
        },
      );
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: dependencies,
          home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
      );

      expect(dependencies.complete.calls, 0);
      expect(find.byKey(const Key('active_reps_field')), findsNothing);
      final undo = find.byTooltip(AppStrings.runnerUndoSet);
      await tester.ensureVisible(undo);
      await tester.tap(undo);
      await tester.pumpAndSettle();

      final weight = find.byKey(const Key('active_weight_field'));
      final reps = find.byKey(const Key('active_reps_field'));
      expect(tester.widget<TextField>(weight).controller!.text, isEmpty);
      expect(tester.widget<TextField>(reps).controller!.text, isEmpty);
      final action = find.byKey(
        const Key('workout_runner_set_action_final-set'),
      );
      expect(tester.widget<IconButton>(action).onPressed, isNull);
      await tester.enterText(weight, '82.5');
      await tester.enterText(reps, '8');
      await tester.pumpAndSettle();

      expect(tester.widget<IconButton>(action).onPressed, isNotNull);
      final session = _RunnerFixtures.currentSession(tester);
      expect(session.status, WorkoutSessionStatus.inProgress);
      expect(session.exercises.single.sets.single.completed, isFalse);
      expect(session.exercises.single.sets.single.actualWeightKg, 82.5);
      expect(session.exercises.single.sets.single.actualReps, 8);
      expect(dependencies.complete.calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('final Log Set completes once without starting another session', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies(
      sessionFactory: _RunnerFixtures.finalSetSession,
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const WorkoutRunnerScreen.savedWorkout(
            savedWorkoutId: 'sw-final',
          ),
        ),
        GoRoute(
          path: AppRoutes.sessionComplete().path,
          name: AppRoutes.sessionComplete().name,
          builder: (_, state) => FinishEarlySessionCompleteScreen(
            session: state.extra! as WorkoutRunnerSessionViewData,
          ),
        ),
      ],
    );

    await _pumpLoaded(
      tester,
      _routerApp(dependencies: dependencies, router: router),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_log_set')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(dependencies.start.calls, 1);
    expect(dependencies.complete.calls, 1);
    expect(find.text(AppStrings.sessionComplete), findsOneWidget);
    expect(find.byType(RestTimerWidget), findsNothing);
  });

  testWidgets('Finish saves early and navigates without a second session', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
        ),
        GoRoute(
          path: AppRoutes.finishEarlySummary().path,
          name: AppRoutes.finishEarlySummary().name,
          builder: (_, state) => FinishEarlySessionCompleteScreen(
            session: state.extra! as WorkoutRunnerSessionViewData,
          ),
        ),
      ],
    );

    await _pumpLoaded(
      tester,
      _routerApp(dependencies: dependencies, router: router),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_finish')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.finishAndSaveSession));
    await tester.pumpAndSettle();

    expect(dependencies.start.calls, 1);
    expect(dependencies.complete.calls, 1);
    expect(find.text(AppStrings.sessionComplete), findsOneWidget);
  });

  for (final recovered in [true, false]) {
    testWidgets(
      recovered
          ? 'iOS edge swipe leaves recovered session without a header or persistence changes'
          : 'iOS edge swipe keeps the active runner behind its guarded exit sheet',
      (tester) async {
        _setViewport(tester, const Size(390, 844));
        final dependencies = _TestDependencies();
        final recoveredSession = _RunnerFixtures.referenceSession().copyWith(
          durationSeconds: 120,
        );
        if (recovered) dependencies.load.sessionToReturn = recoveredSession;
        final route = recovered
            ? AppRoutes.workoutRunnerActive()
            : AppRoutes.workoutRunnerSavedWorkout();
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => Scaffold(
                key: const Key('runner_gesture_host'),
                body: Center(
                  child: FilledButton(
                    key: const Key('runner_gesture_open'),
                    onPressed: () => context.pushNamed(
                      route.name,
                      pathParameters: recovered ? {} : {'id': 'sw-1'},
                    ),
                    child: const Text(AppStrings.resumeWorkout),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: route.path,
              name: route.name,
              builder: (_, _) => recovered
                  ? const WorkoutRunnerScreen.resume()
                  : const WorkoutRunnerScreen.savedWorkout(
                      savedWorkoutId: 'sw-1',
                    ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await _pumpLoaded(
          tester,
          _routerApp(
            dependencies: dependencies,
            router: router,
            theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
          ),
        );
        await tester.tap(find.byKey(const Key('runner_gesture_open')));
        await tester.pumpAndSettle();
        expect(find.byType(WorkoutRunnerScreen), findsOneWidget);
        if (recovered) {
          expect(find.byType(AppBar), findsNothing);
          expect(find.byKey(const Key('workout_runner_header')), findsNothing);
          expect(find.byTooltip(AppStrings.exitWorkout), findsNothing);
          expect(find.text(AppStrings.sessionInProgress), findsOneWidget);
          expect(find.text(AppStrings.resumeSessionSubtitle), findsOneWidget);
        }
        await tester.flingFrom(
          const Offset(1, 420),
          const Offset(350, 0),
          1200,
        );
        await tester.pumpAndSettle();
        if (recovered) {
          expect(
            find.byKey(const Key('runner_gesture_host')).hitTestable(),
            findsOneWidget,
          );
          expect(find.byType(WorkoutRunnerScreen), findsNothing);
          expect(find.byType(ExitWorkoutSheet), findsNothing);
          expect(dependencies.load.sessionToReturn, same(recoveredSession));
          expect(dependencies.load.sessionToReturn!.durationSeconds, 120);
          expect(
            dependencies.load.sessionToReturn!.status,
            WorkoutSessionStatus.inProgress,
          );
          expect(dependencies.start.calls, 0);
        } else {
          expect(find.byType(WorkoutRunnerScreen), findsOneWidget);
          expect(find.byType(ExitWorkoutSheet), findsOneWidget);
          expect(dependencies.start.calls, 1);
        }
        expect(dependencies.save.lastSavedSession, isNull);
        expect(dependencies.complete.calls, 0);
        expect(dependencies.abandon.lastAbandonedId, isNull);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'recovering a session resumes its duration without starting another session',
    (tester) async {
      _setViewport(tester, const Size(390, 844));
      final dependencies = _TestDependencies();
      dependencies.load.sessionToReturn = _RunnerFixtures.referenceSession()
          .copyWith(durationSeconds: 120);
      await _pumpLoaded(
        tester,
        _testApp(
          dependencies: dependencies,
          home: const WorkoutRunnerScreen.resume(),
        ),
      );
      expect(find.text(AppStrings.sessionInProgress), findsOneWidget);
      expect(find.text(AppStrings.resumeSessionSubtitle), findsOneWidget);
      final resume = find.widgetWithText(
        FilledButton,
        AppStrings.resumeWorkout,
      );
      await tester.ensureVisible(resume);
      await tester.pumpAndSettle();
      await tester.tap(resume);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('workout_runner_training_log')),
        findsOneWidget,
      );
      expect(dependencies.start.calls, 0);
      expect(dependencies.save.lastSavedSession!.durationSeconds, isNull);
      expect(
        dependencies.save.lastSavedSession!.startedAt,
        isNot(dependencies.load.sessionToReturn!.startedAt),
      );
    },
  );

  testWidgets('progress-save failure preserves the log and retries safely', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies();
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutRunnerScreen)),
    );
    final provider = AppProviders.workoutRunnerControllerProvider((
      mode: WorkoutRunnerMode.savedWorkout,
      savedWorkoutId: 'sw-1',
      programId: null,
      programWorkoutId: null,
    ));
    dependencies.save.shouldThrow = true;
    await container.read(provider.notifier).saveProgress();
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.workoutRunnerSaveFailed), findsOneWidget);
    expect(find.textContaining('private save failure'), findsNothing);
    expect(
      find.byKey(const Key('workout_runner_training_log')),
      findsOneWidget,
    );
    dependencies.save.shouldThrow = false;
    final retry = find.text(AppStrings.retry);
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(
      container.read(provider).requireValue.phase,
      WorkoutRunnerPhase.ready,
    );
    expect(dependencies.complete.calls, 0);
    expect(dependencies.start.calls, 1);
  });

  for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
    testWidgets(
      'keyboard and 2x text keep active inputs clear of the footer in ${theme.brightness.name}',
      (tester) async {
        _setViewport(tester, const Size(320, 844));
        await _pumpLoaded(
          tester,
          _testApp(
            dependencies: _TestDependencies(),
            theme: theme,
            textScaler: const TextScaler.linear(2),
            accessible: true,
            home: const WorkoutRunnerScreen.savedWorkout(
              savedWorkoutId: 'sw-1',
            ),
          ),
        );
        final field = _fieldFor('workout_runner_weight_input_working-1');
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.tap(field);
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(tester.element(field), alignment: 0.5);
        await tester.pumpAndSettle();
        final actions = find.byKey(const Key('workout_runner_bottom_actions'));
        final header = find.byKey(const Key('workout_runner_header'));
        expect(
          tester.getBottomRight(field).dy,
          lessThanOrEqualTo(tester.getTopLeft(actions).dy),
        );
        expect(
          tester.getTopLeft(field).dy,
          greaterThanOrEqualTo(tester.getBottomRight(header).dy),
        );
        expect(
          find.byKey(const Key('workout_runner_log_set')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.getBottomRight(actions).dy, lessThanOrEqualTo(844 - 280));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('compact and 2× text layouts keep essential controls usable', (
    tester,
  ) async {
    _setViewport(tester, const Size(320, 844));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        textScaler: const TextScaler.linear(2),
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('workout_runner_close_button')),
          )
          .shortestSide,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.byKey(const ValueKey<String>('workout_runner_log_set')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('workout_runner_finish')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode keeps the session and primary action readable', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: _TestDependencies(),
        theme: AppTheme.darkTheme,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('workout_runner_header')),
        matching: find.text('Flat Bench Press'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_runner_log_set')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
