import 'dart:io';
import 'dart:ui' as ui;
import 'package:aedify/app/app.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/router/app_router.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/analytics/presentation/analytics_exercise_history_screen.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'offline analytics drilldown, warmup history, themes and durable dismissal',
    (tester) async {
      final oldHttp = HttpOverrides.current;
      final network = _AnalyticsBlockedNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = oldHttp);
      final root = await (await getTemporaryDirectory()).createTemp(
        'analytics_ui_',
      );
      final db = AppDatabase(
        NativeDatabase(File(p.join(root.path, 'fixture.sqlite'))),
      );
      final now = DateTime(2026, 10, 26, 12);
      await _AnalyticsDevice.seed(db, now);
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          PlateauProviders.clockProvider.overrideWithValue(() => now),
        ],
      );
      for (final dark in [false, true]) {
        final router = GoRouter(
          initialLocation: AppRoutes.analytics().path,
          routes: [
            GoRoute(
              path: AppRoutes.analytics().path,
              name: AppRoutes.analytics().name,
              builder: (_, _) => const AnalyticsScreen(),
            ),
            GoRoute(
              path: AppRoutes.analyticsExerciseHistory().path,
              name: AppRoutes.analyticsExerciseHistory().name,
              builder: (_, state) => AnalyticsExerciseHistoryScreen(
                exerciseId: int.tryParse(state.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: const Key('analytics_capture'),
              child: MaterialApp.router(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final mode = dark ? 'dark' : 'light';
        await _AnalyticsDevice.capture(tester, 'aedify_m5_dashboard_$mode.png');
        await _AnalyticsDevice.reveal(
          tester,
          find.text(AnalyticsStrings.weeklyVolume),
        );
        await _AnalyticsDevice.capture(tester, 'aedify_m5_chart_$mode.png');
        await _AnalyticsDevice.reveal(
          tester,
          find.byKey(const ValueKey('analytics_exercise_-1')),
        );
        await tester.tap(find.byKey(const ValueKey('analytics_exercise_-1')));
        await tester.pumpAndSettle();
        expect(find.text('Device bench press'), findsWidgets);
        await _AnalyticsDevice.capture(tester, 'aedify_m5_exercise_$mode.png');
        await _AnalyticsDevice.reveal(
          tester,
          find.text(AnalyticsStrings.loggedSets),
        );
        await _AnalyticsDevice.reveal(
          tester,
          find.byKey(const ValueKey('history_exercise_member-3')),
        );
        expect(find.text(AppStrings.warmupSet), findsWidgets);
        await _AnalyticsDevice.capture(tester, 'aedify_m5_sets_$mode.png');
        router.pop();
        await tester.pumpAndSettle();
        if (dark) {
          await _AnalyticsDevice.reveal(
            tester,
            find.byKey(const ValueKey('plateau_dismiss_-1')),
          );
          await tester.tap(find.byKey(const ValueKey('plateau_dismiss_-1')));
          await tester.pumpAndSettle();
          expect(
            (await db.select(db.plateauFlags).get()).single.status,
            'dismissed',
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        router.dispose();
      }
      expect(network.attempts, 0);
      container.dispose();
      await db.close();
      await root.delete(recursive: true);
    },
  );

  testWidgets(
    'offline app job, correction, disk reopen and deletion update analytics',
    (tester) async {
      final oldHttp = HttpOverrides.current;
      final network = _AnalyticsBlockedNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = oldHttp);
      final root = await (await getTemporaryDirectory()).createTemp(
        'analytics_gate_',
      );
      final file = File(p.join(root.path, 'acceptance.sqlite'));
      var db = AppDatabase(NativeDatabase(file));
      final now = DateTime(2026, 11, 4, 12);
      await _AnalyticsDevice.seed(db, now);
      await db
          .update(db.userProfile)
          .write(const UserProfileCompanion(preferredUnits: Value('imperial')));
      late ProviderContainer container;
      late GoRouter router;
      final dataProvider = AnalyticsViewProviders.dataProvider((
        range: AnalyticsRange.fourWeeks,
        exerciseId: null,
      ));

      Future<void> mount() async {
        router = GoRouter(
          initialLocation: AppRoutes.home().path,
          routes: [
            GoRoute(
              path: AppRoutes.home().path,
              name: AppRoutes.home().name,
              builder: (_, _) => const Scaffold(),
            ),
            GoRoute(
              path: AppRoutes.analytics().path,
              name: AppRoutes.analytics().name,
              builder: (_, _) => const AnalyticsScreen(),
            ),
          ],
        );
        container = ProviderContainer(
          overrides: [
            AppProviders.appDatabaseProvider.overrideWithValue(db),
            AppBootstrap.controllerProvider.overrideWith(
              _AnalyticsReadyBootstrap.new,
            ),
            AppRouter.appRouterProvider.overrideWithValue(router),
            PlateauProviders.clockProvider.overrideWithValue(() => now),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AedifyApp(),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> unmount() async {
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        router.dispose();
        await db.close();
      }

      Future<void> flagIs(String status) => _AnalyticsDevice.until(
        () async =>
            (await db.select(db.plateauFlags).get()).singleOrNull?.status ==
            status,
      );
      Future<void> volumeIs(double volume) => _AnalyticsDevice.until(() async {
        await tester.pump();
        return container.read(dataProvider).asData?.value.volumeKgReps ==
            volume;
      });
      Future<void> correct(double weight, int reps) async {
        final history = container.read(
          AppProviders.workoutHistoryRepositoryProvider,
        );
        final detail = (await history.getSessionDetail('session-3'))!;
        await history.correctSession(
          sessionId: 'session-3',
          corrections: [
            WorkoutHistorySetCorrection(
              expected: detail.exercises.single.sets.singleWhere(
                (set) => set.setType.dbValue == 'working',
              ),
              actualWeightKg: weight,
              actualReps: reps,
            ),
          ],
        );
      }

      try {
        await mount();
        await flagIs('open');
        expect(
          container.exists(dataProvider),
          isFalse,
          reason: 'App detection must run before Stats is visited',
        );
        router.goNamed(AppRoutes.analytics().name);
        await tester.pumpAndSettle();
        await volumeIs(1950);
        expect(
          container.read(AnalyticsViewProviders.unitsProvider).requireValue,
          PreferredUnit.imperial,
        );
        expect(find.textContaining('lbs'), findsWidgets);
        await correct(120, 6);
        await volumeIs(2170);
        await flagIs('resolved');
        expect(
          container.read(dataProvider).requireValue.strengthTrend.last.value,
          closeTo(144, 1e-8),
        );
        await correct(100, 5);
        await volumeIs(1950);
        await flagIs('open');
        await _AnalyticsDevice.reveal(
          tester,
          find.byKey(const ValueKey('plateau_dismiss_-1')),
        );
        await tester.tap(find.byKey(const ValueKey('plateau_dismiss_-1')));
        await tester.pumpAndSettle();
        await flagIs('dismissed');
        final dismissedAt =
            (await db.select(db.plateauFlags).get()).single.dismissedAt;
        await unmount();
        db = AppDatabase(NativeDatabase(file));
        await mount();
        await flagIs('dismissed');
        expect(
          (await db.select(db.plateauFlags).get()).single.dismissedAt,
          dismissedAt,
        );
        router.goNamed(AppRoutes.analytics().name);
        await tester.pumpAndSettle();
        await volumeIs(1950);
        await container
            .read(AppProviders.workoutSessionDaoProvider)
            .deleteSession('session-3');
        await volumeIs(1450);
        await flagIs('resolved');
        expect(container.read(dataProvider).requireValue.sessions, 3);
        await db.transaction(() async {
          await db.delete(db.setLogs).go();
          await db.delete(db.workoutSessionExercises).go();
          await db.delete(db.workoutSessions).go();
        });
        await _AnalyticsDevice.until(() async {
          await tester.pump();
          return container.read(dataProvider).asData?.value.hasAnyHistory ==
              false;
        });
        await tester.pumpAndSettle();
        expect(find.text(AnalyticsStrings.emptyTitle), findsOneWidget);
        await _AnalyticsDevice.until(
          () async =>
              (await db.select(db.plateauFlags).get()).single.basisJson == '{}',
        );
        expect(network.attempts, 0);
        expect(tester.takeException(), isNull);
      } finally {
        await unmount();
        await root.delete(recursive: true);
      }
    },
  );
}

abstract final class _AnalyticsDevice {
  static Future<void> until(Future<bool> Function() predicate) async {
    for (var i = 0; i < 1000; i++) {
      if (await predicate()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Native M5 reconciliation did not reach its expected state');
  }

  static Future<void> seed(AppDatabase db, DateTime now) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: const Value(-1),
            isCustom: const Value(true),
            source: 'custom',
            name: 'Device bench press',
            nameNormalized: 'device bench press',
            primaryMusclesJson: '[]',
            muscleGroupsJson: '[]',
            modality: 'strength',
            loggingType: const Value('repsWeight'),
            gripsJson: '[]',
            stepsJson: '[]',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.userProfile)
        .insert(
          UserProfileCompanion.insert(
            experienceLevel: 'intermediate',
            preferredUnits: const Value('metric'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (var i = 0; i < 4; i++) {
      final at = now.subtract(Duration(days: 3 - i));
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'session-$i',
              source: 'standalone',
              name: 'Synthetic training',
              startedAt: at,
              completedAt: Value(at),
              status: 'completed',
              createdAt: at,
              updatedAt: at,
            ),
          );
      await db
          .into(db.workoutSessionExercises)
          .insert(
            WorkoutSessionExercisesCompanion.insert(
              id: 'member-$i',
              workoutSessionId: 'session-$i',
              exerciseId: -1,
              exerciseNameSnapshot: 'Device bench press',
              sortOrder: 0,
              loggingType: const Value('repsWeight'),
            ),
          );
      for (final warmup in [true, false]) {
        await db
            .into(db.setLogs)
            .insert(
              SetLogsCompanion.insert(
                id: 'set-$i-$warmup',
                workoutSessionExerciseId: 'member-$i',
                exerciseId: -1,
                performedAt: at,
                setIndex: warmup ? 0 : 1,
                setType: Value(warmup ? 'warmup' : 'working'),
                actualWeightKg: Value(
                  warmup
                      ? 999
                      : i == 0
                      ? 90
                      : 100,
                ),
                actualReps: const Value(5),
                completed: const Value(true),
                createdAt: at,
                updatedAt: at,
              ),
            );
      }
    }
  }

  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pump();
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
      find.byKey(const Key('analytics_capture')),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await File(
      p.join((await getTemporaryDirectory()).path, name),
    ).writeAsBytes(bytes!.buffer.asUint8List());
  }
}

class _AnalyticsBlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Network blocked for offline fixture');
  }
}

class _AnalyticsReadyBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.success(isOffline: true);
}
