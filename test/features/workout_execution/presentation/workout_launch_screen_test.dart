import 'package:aedify/shared/constants/app_error_strings.dart';
import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_execution/application/start_workout_session_use_case.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_launch_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/features/workout_execution/presentation/workout_launch_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Sessions extends Fake implements WorkoutSessionRepository {
  WorkoutSessionAggregate? active;
  final saved = <WorkoutSessionDraft>[];

  @override
  Future<WorkoutSessionAggregate?> getActiveSession() async => active;

  @override
  Future<void> saveSessionProgress(WorkoutSessionDraft draft) async {
    saved.add(draft);
  }

  void create(String id) {
    final now = DateTime(2026, 10, 24, 10);
    active = WorkoutSessionAggregate(
      session: WorkoutSession(
        id: id,
        source: SessionSource.standalone.dbValue,
        name: WorkoutLaunchStrings.standaloneName,
        startedAt: now,
        status: WorkoutSessionStatus.inProgress.dbValue,
        createdAt: now,
        updatedAt: now,
      ),
      exercises: const [],
      setLogs: const [],
    );
  }
}

class _Start extends Fake implements StartWorkoutSessionUseCase {
  _Start(this.sessions);

  final _Sessions sessions;
  int standaloneCalls = 0;
  final repeated = <String>[];
  bool fail = false;
  Completer<void>? pending;

  Future<WorkoutRunnerSessionViewData> _create(String id) async {
    if (fail) throw StateError('private launch fixture error');
    await pending?.future;
    sessions.create(id);
    return const WorkoutRunnerMapper().toViewData(sessions.active!);
  }

  @override
  Future<WorkoutRunnerSessionViewData> startStandalone() {
    standaloneCalls++;
    return _create('new-session');
  }

  @override
  Future<WorkoutRunnerSessionViewData> repeatCompleted(String sessionId) {
    repeated.add(sessionId);
    return _create('repeated-session');
  }
}

class _LaunchHarness {
  _LaunchHarness({this.sourceSessionId, this.realRunner = false});

  final String? sourceSessionId;
  final bool realRunner;
  final sessions = _Sessions();
  late final start = _Start(sessions);
  final opened = <String>{};
  late final router = GoRouter(
    initialLocation: sourceSessionId == null
        ? AppRoutes.workoutRunnerStandalone().path
        : AppRoutes.workoutRunnerRepeat().path.replaceFirst(
            ':sessionId',
            sourceSessionId!,
          ),
    routes: [
      GoRoute(
        path: AppRoutes.workoutRunnerStandalone().path,
        name: AppRoutes.workoutRunnerStandalone().name,
        builder: (_, _) => const WorkoutLaunchScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutRunnerRepeat().path,
        name: AppRoutes.workoutRunnerRepeat().name,
        builder: (_, state) => WorkoutLaunchScreen(
          sourceSessionId: state.pathParameters['sessionId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutRunnerActive().path,
        name: AppRoutes.workoutRunnerActive().name,
        builder: (_, state) {
          final id = state.extra! as String;
          opened.add(id);
          return realRunner
              ? WorkoutRunnerScreen.resume(launchedSessionId: id)
              : const Scaffold(body: Text('Session destination'));
        },
      ),
    ],
  );

  Future<void> pump(WidgetTester tester) async {
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.workoutSessionRepositoryProvider.overrideWithValue(
            sessions,
          ),
          AppProviders.startWorkoutSessionUseCaseProvider.overrideWithValue(
            start,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'standalone launch enters the empty runner without a resume step',
    (tester) async {
      final harness = _LaunchHarness(realRunner: true);

      await harness.pump(tester);

      expect(find.text(WorkoutLaunchStrings.emptyTitle), findsOneWidget);
      expect(find.text(WorkoutLaunchStrings.addExercises), findsOneWidget);
      expect(find.text(AppStrings.resumeWorkout), findsNothing);
      expect(harness.start.standaloneCalls, 1);
      expect(harness.start.repeated, isEmpty);
      expect(harness.opened, {'new-session'});
      expect(harness.sessions.saved.single.id, 'new-session');
      expect(harness.sessions.saved.single.exercises, isEmpty);
      expect(harness.router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'active conflict resumes once without starting a second session',
    (tester) async {
      final harness = _LaunchHarness()..sessions.create('existing-session');

      await harness.pump(tester);

      expect(find.text(WorkoutLaunchStrings.activeConflict), findsOneWidget);
      expect(harness.opened, isEmpty);
      expect(harness.start.standaloneCalls, 0);
      final resume = find.widgetWithText(
        FilledButton,
        AppStrings.resumeWorkout,
      );
      await tester.tap(resume);
      await tester.tap(resume);
      await tester.pumpAndSettle();

      expect(harness.opened, {'existing-session'});
      expect(harness.sessions.active!.session.id, 'existing-session');
      expect(harness.start.standaloneCalls, 0);
      expect(harness.start.repeated, isEmpty);
      expect(harness.router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('retry shows progress and repeated taps start only one retry', (
    tester,
  ) async {
    final harness = _LaunchHarness();
    harness.start.fail = true;
    await harness.pump(tester);

    expect(find.text(AppErrorStrings.workoutStartFailed), findsOneWidget);
    expect(find.textContaining('private launch fixture error'), findsNothing);
    expect(harness.sessions.active, isNull);
    expect(harness.start.standaloneCalls, 1);
    harness.start.fail = false;
    final pending = Completer<void>();
    harness.start.pending = pending;
    final retry = find.widgetWithText(FilledButton, AppStrings.retry);
    await tester.tap(retry);
    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(WorkoutLaunchStrings.starting), findsOneWidget);
    expect(retry, findsNothing);
    expect(harness.start.standaloneCalls, 2);
    expect(harness.opened, isEmpty);
    pending.complete();
    await tester.pumpAndSettle();

    expect(harness.opened, {'new-session'});
    expect(harness.start.standaloneCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'repeat passes the source ID and opens the newly created session',
    (tester) async {
      final harness = _LaunchHarness(sourceSessionId: 'completed-source');

      await harness.pump(tester);

      expect(harness.start.repeated, ['completed-source']);
      expect(harness.start.standaloneCalls, 0);
      expect(harness.opened, {'repeated-session'});
      expect(
        harness.router.routeInformationProvider.value.uri.path,
        AppRoutes.workoutRunnerActive().path,
      );
      expect(find.byType(WorkoutLaunchScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
