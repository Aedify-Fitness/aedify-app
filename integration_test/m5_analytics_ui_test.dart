import 'dart:io';
import 'dart:ui' as ui;
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/analytics/presentation/analytics_exercise_history_screen.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
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
}

abstract final class _AnalyticsDevice {
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
