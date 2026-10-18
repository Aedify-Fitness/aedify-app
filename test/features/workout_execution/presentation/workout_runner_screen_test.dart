import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/workout_execution/application/abandon_workout_session_use_case.dart';
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
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _RunnerFixtures {
  _RunnerFixtures._();

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

  @override
  Future<void> save(WorkoutRunnerSessionViewData session) async {
    lastSavedSession = session;
  }
}

class _FakeCompleteUseCase implements CompleteWorkoutSessionUseCase {
  int calls = 0;
  WorkoutRunnerCompletionDraft? lastDraft;

  @override
  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    calls++;
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
}) {
  return _withProviders(
    dependencies: dependencies,
    child: MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
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

  testWidgets('matches the supplied 390×1236 runner hierarchy', (tester) async {
    _setViewport(tester, const Size(390, 1236));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    final header = find.byKey(const ValueKey<String>('workout_runner_header'));
    final media = find.byKey(const ValueKey<String>('workout_runner_media'));
    final mediaGuide = find.byKey(
      const ValueKey<String>('workout_runner_media_guide'),
    );
    final mediaInfo = find.byKey(
      const ValueKey<String>('workout_runner_media_info'),
    );
    final trainingLog = find.byKey(
      const ValueKey<String>('workout_runner_training_log'),
    );
    final insight = find.byKey(
      const ValueKey<String>('workout_runner_insight'),
    );
    final nextExercise = find.byKey(
      const ValueKey<String>('workout_runner_next_exercise'),
    );
    final bottomActions = find.byKey(
      const ValueKey<String>('workout_runner_bottom_actions'),
    );

    expect(header, findsOneWidget);
    expect(
      find.descendant(of: header, matching: find.byType(WorkoutDurationTimer)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: header, matching: find.byType(RestTimerWidget)),
      findsNothing,
    );
    expect(find.byType(RestTimerWidget), findsNothing);
    expect(find.text('PUSH A — UPPER HYPERTROPHY'), findsOneWidget);
    expect(find.text('Flat Bench Press'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('workout_runner_substitute')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.substitute.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.formGuidance.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.insightForProgress), findsOneWidget);
    expect(find.text(AppStrings.upNext.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.superset.toUpperCase()), findsOneWidget);
    expect(find.text('Incline DB Press'), findsOneWidget);
    expect(find.text('Lateral Raises'), findsOneWidget);
    expect(find.text(AppStrings.logSet), findsOneWidget);
    expect(find.text(AppStrings.finish), findsOneWidget);

    expect(tester.getSize(media).width, 350);
    expect(tester.getTopLeft(media).dx, 20);
    expect(
      tester.getSize(mediaGuide).height,
      greaterThanOrEqualTo(AppWorkoutRunnerTokens.mediaControlSize),
    );
    expect(
      tester.getSize(mediaInfo),
      const Size(
        AppWorkoutRunnerTokens.mediaControlSize,
        AppWorkoutRunnerTokens.mediaControlSize,
      ),
    );
    expect(tester.getSize(trainingLog).width, 350);
    expect(
      tester.getSize(media).width / tester.getSize(media).height,
      closeTo(AppWorkoutRunnerTokens.mediaAspectRatio, 0.01),
    );
    expect(
      tester.getTopLeft(trainingLog).dy - tester.getBottomLeft(media).dy,
      AppWorkoutRunnerTokens.sectionGap,
    );
    expect(
      tester.getTopLeft(insight).dy - tester.getBottomLeft(trainingLog).dy,
      AppWorkoutRunnerTokens.sectionGap,
    );
    expect(
      tester.getTopLeft(nextExercise).dy - tester.getBottomLeft(insight).dy,
      AppWorkoutRunnerTokens.sectionGap,
    );

    final logButton = tester.getRect(
      find.byKey(const ValueKey<String>('workout_runner_log_set')),
    );
    final finishButton = tester.getRect(
      find.byKey(const ValueKey<String>('workout_runner_finish')),
    );
    expect(logButton.left, 20);
    expect(finishButton.left - logButton.right, closeTo(16, 0.001));
    expect(logButton.width / finishButton.width, closeTo(2, 0.02));
    expect(tester.getRect(bottomActions).bottom, 1236);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders active superset as a grouped runner block', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 1236));
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
      find.byKey(const ValueKey<String>('workout_runner_superset_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('workout_runner_substitute')),
      findsNothing,
    );
    expect(find.text(AppStrings.superset.toUpperCase()), findsOneWidget);
    expect(find.text('A. Incline DB Press'), findsOneWidget);
    expect(find.text('B. Lateral Raises'), findsOneWidget);
    expect(find.text('S1 (A)'), findsOneWidget);
    expect(find.text('S1 (B)'), findsOneWidget);
    expect(find.text(AppStrings.addSuperset.toUpperCase()), findsOneWidget);
    expect(find.text('Log S1 (Incline DB Press)'), findsOneWidget);
  });

  testWidgets('pairs and connects each warmup and working superset round', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 1450));
    final dependencies = _TestDependencies(
      sessionFactory: _RunnerFixtures.pairedSupersetSession,
    );
    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    for (final prefix in ['W', 'S']) {
      for (var round = 1; round <= 2; round++) {
        final type = prefix == 'W' ? 'warmup' : 'working';
        final group = find.byKey(
          ValueKey<String>(
            'workout_runner_superset_round_${type}_${round - 1}',
          ),
        );
        for (final letter in ['A', 'B']) {
          expect(
            find.descendant(
              of: group,
              matching: find.text('$prefix$round ($letter)'),
            ),
            findsOneWidget,
          );
        }
        expect(
          find.descendant(
            of: group,
            matching: find.byKey(
              ValueKey<String>(
                'workout_runner_superset_connector_incline-session-exercise-$type-${round - 1}',
              ),
            ),
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(find.text('$prefix$round (A)')).dy,
          lessThan(tester.getTopLeft(find.text('$prefix$round (B)')).dy),
        );
      }
    }
    expect(
      tester.getTopLeft(find.text('W1 (B)')).dy,
      lessThan(tester.getTopLeft(find.text('W2 (A)')).dy),
    );
    expect(
      tester.getTopLeft(find.text('W2 (B)')).dy,
      lessThan(tester.getTopLeft(find.text('S1 (A)')).dy),
    );
    expect(
      tester.getTopLeft(find.text('S1 (B)')).dy,
      lessThan(tester.getTopLeft(find.text('S2 (A)')).dy),
    );
    expect(
      find.byKey(
        const ValueKey<String>(
          'workout_runner_active_rail_incline-session-exercise-working-0',
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final warmupsCompleted in [false, true]) {
    final prefix = warmupsCompleted ? 'S' : 'W';
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
        expect(find.text('Log ${prefix}1 (Incline DB Press)'), findsOneWidget);
        await tester.tap(log);
        await tester.pumpAndSettle();
        expect(find.text('Log ${prefix}1 (Lateral Raises)'), findsOneWidget);
        expect(rest, findsNothing);

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
        expect(tester.getRect(rest).bottom, 1450);
        expect(
          find.byKey(const ValueKey<String>('workout_runner_bottom_actions')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('workout_runner_rest_timer_ring')),
          findsOneWidget,
        );
        expect(find.text(AppStrings.restTime.toUpperCase()), findsOneWidget);
        expect(find.text(AppStrings.skipRestAndLogNextSet), findsOneWidget);

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
        expect(find.text('Log ${prefix}2 (Incline DB Press)'), findsOneWidget);
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

  testWidgets('renders completed, active, and upcoming set treatments', (
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

    expect(find.text('W1'), findsOneWidget);
    expect(find.text('S1'), findsOneWidget);
    expect(find.text('S2'), findsOneWidget);
    expect(find.text(AppStrings.setNumberColumn), findsOneWidget);
    expect(find.text(AppStrings.previousColumn), findsOneWidget);
    expect(find.text(AppStrings.targetColumn), findsOneWidget);
    expect(find.text(AppStrings.logColumn), findsOneWidget);
    expect(find.text(AppStrings.unavailableValue), findsNWidgets(3));
    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_active_rail_working-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_weight_input_working-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('workout_runner_weight_input_working-2'),
      ),
      findsNothing,
    );
    expect(
      tester.getSize(
        find.byKey(
          const ValueKey<String>('workout_runner_set_action_warmup-1'),
        ),
      ),
      const Size(40, 40),
    );
    expect(
      tester.getSize(
        find.byKey(
          const ValueKey<String>('workout_runner_set_hit_target_warmup-1'),
        ),
      ),
      const Size(48, 48),
    );
    expect(
      tester.getSize(
        find.byKey(
          const ValueKey<String>('workout_runner_set_action_working-1'),
        ),
      ),
      const Size(48, 48),
    );
    expect(
      tester.getSize(
        find.byKey(
          const ValueKey<String>('workout_runner_set_action_working-2'),
        ),
      ),
      const Size(40, 40),
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
    expect(find.text(AppStrings.restTime.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.restMinus15), findsOneWidget);
    expect(find.text(AppStrings.restPlus15), findsOneWidget);
    expect(find.text(AppStrings.skipRestAndLogNextSet), findsOneWidget);
    final restTimerRect = tester.getRect(
      find.byKey(const ValueKey<String>('workout_runner_rest_timer')),
    );
    expect(restTimerRect.left, 0);
    expect(restTimerRect.right, 390);
    expect(restTimerRect.bottom, 1236);

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

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_add_set')),
    );
    await tester.pump();
    expect(find.text('S3'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('workout_runner_add_note')),
    );
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

  testWidgets('header and actions stay fixed while final content clears them', (
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

    final header = find.byKey(const ValueKey<String>('workout_runner_header'));
    final actions = find.byKey(
      const ValueKey<String>('workout_runner_bottom_actions'),
    );
    final scrollView = find.byKey(
      const ValueKey<String>('workout_runner_scroll_view'),
    );
    final initialHeaderRect = tester.getRect(header);
    final initialActionRect = tester.getRect(actions);

    await tester.drag(scrollView, const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(tester.getRect(header), initialHeaderRect);
    expect(tester.getRect(actions), initialActionRect);
    final nextRect = tester.getRect(
      find.byKey(const ValueKey<String>('workout_runner_next_exercise')),
    );
    expect(
      initialActionRect.top - nextRect.bottom,
      closeTo(AppWorkoutRunnerTokens.contentBreathingSpace, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('dark mode resolves runner cards from the dark theme', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    final dependencies = _TestDependencies();

    await _pumpLoaded(
      tester,
      _testApp(
        dependencies: dependencies,
        theme: AppTheme.darkTheme,
        home: const WorkoutRunnerScreen.savedWorkout(savedWorkoutId: 'sw-1'),
      ),
    );

    final trainingLog = tester.widget<Container>(
      find.byKey(const ValueKey<String>('workout_runner_training_log')),
    );
    final decoration = trainingLog.decoration! as BoxDecoration;
    expect(
      decoration.color,
      AppTheme.darkTheme.colorScheme.surfaceContainerLowest,
    );
    expect(tester.takeException(), isNull);
  });
}
