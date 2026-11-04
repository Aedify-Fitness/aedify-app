import 'dart:async';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/analytics/presentation/analytics_exercise_history_screen.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final now = DateTime(2026, 10, 26, 12);
  List<AnalyticsSetLog> logs({int count = 4, bool high = false}) => [
    for (var i = 0; i < count; i++)
      AnalyticsSetLog(
        id: 'set-$i',
        sessionId: 'session-$i',
        sessionExerciseId: 'member-$i',
        exerciseId: 1,
        exerciseName: 'Fixture bench press',
        source: SessionSource.standalone,
        performedAt: now.subtract(Duration(days: count - i - 1)),
        completedAt: now,
        updatedAt: now,
        setIndex: 0,
        modality: ExerciseModality.strength,
        loggingType: ExerciseLoggingType.repsWeight,
        actualWeightKg: i == 0 ? 90 : 100,
        actualReps: high ? 11 : 5,
      ),
  ];
  Future<void> pump(
    WidgetTester tester, {
    List<AnalyticsSetLog>? evidence,
    bool dark = false,
    double scale = 1,
    double width = 390,
    bool detail = false,
    Object? failure,
    bool loading = false,
    PreferredUnit unit = PreferredUnit.metric,
  }) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        AnalyticsViewProviders.unitsProvider.overrideWithValue(AsyncData(unit)),
        PlateauProviders.clockProvider.overrideWithValue(() => now),
        AnalyticsProviders.completedWorkingSetsProvider.overrideWith(
          (ref, query) => loading
              ? const Stream.empty()
              : failure != null
              ? Stream.error(failure)
              : Stream.value(
                  (evidence ?? logs())
                      .where(
                        (log) =>
                            query.exerciseId == null ||
                            query.exerciseId == log.exerciseId,
                      )
                      .toList(),
                ),
        ),
        AnalyticsViewProviders.recentWorkoutsProvider.overrideWith(
          (ref) async => [],
        ),
        AnalyticsViewProviders.historyProvider.overrideWith(
          (ref, id) async => [],
        ),
        PlateauProviders.evaluationsProvider.overrideWith(
          (ref) => Stream.value([]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: detail
          ? '/analytics/exercises/1'
          : AppRoutes.analytics().path,
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
        GoRoute(
          path: AppRoutes.workoutRunnerStandalone().path,
          name: AppRoutes.workoutRunnerStandalone().name,
          builder: (_, _) => const Scaffold(body: Text('Test workout entry')),
        ),
        GoRoute(
          path: AppRoutes.liftLog().path,
          name: AppRoutes.liftLog().name,
          builder: (_, _) => const Scaffold(body: Text('Test history')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          ),
        ),
      ),
    );
    if (loading) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty dashboard guides into local workout entry', (
    tester,
  ) async {
    await pump(tester, evidence: []);
    expect(find.text(AnalyticsStrings.emptyTitle), findsOneWidget);
    await tester.tap(find.text(AppStrings.logWorkout));
    await tester.pumpAndSettle();
    expect(find.text('Test workout entry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('loading and safe retry states never expose raw failure text', (
    tester,
  ) async {
    await pump(tester, loading: true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await pump(tester, failure: StateError('PRIVATE_SOURCE_SENTINEL'));
    expect(find.text(AppErrorStrings.analyticsLoadFailed), findsOneWidget);
    expect(find.textContaining('PRIVATE_SOURCE_SENTINEL'), findsNothing);
    expect(find.text(AppStrings.retry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    testWidgets('dashboard and drilldown fit 320px / 2x text, dark=$dark', (
      tester,
    ) async {
      await pump(tester, dark: dark, scale: 2, width: 320);
      await reveal(tester, find.byKey(const ValueKey('analytics_exercise_1')));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('analytics_exercise_1')));
      await tester.pumpAndSettle();
      expect(find.text('Fixture bench press'), findsOneWidget);
      await reveal(tester, find.text(AnalyticsStrings.loggedSets));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('chart has readable data and uses imperial units', (
    tester,
  ) async {
    await pump(tester, detail: true, unit: PreferredUnit.imperial);
    await reveal(tester, find.text(AnalyticsStrings.viewData).first);
    await tester.tap(find.text(AnalyticsStrings.viewData).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('lb'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'higher rep estimates are flagged rather than drawn as reliable strength',
    (tester) async {
      await pump(tester, detail: true, evidence: logs(high: true));
      expect(find.text(AnalyticsStrings.noStrengthEstimate), findsOneWidget);
      await reveal(tester, find.text(AnalyticsStrings.highRepEstimates));
      expect(find.textContaining(AnalyticsStrings.lowConfidence), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'single-point and dense series render without layout/runtime failures',
    (tester) async {
      await pump(tester, detail: true, evidence: logs(count: 1));
      expect(find.byType(LineChart), findsWidgets);
      expect(find.text(AnalyticsStrings.sparseData), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await pump(tester, detail: true, evidence: logs(count: 250), width: 768);
      await tester.tap(find.byKey(const ValueKey('analytics_range_allTime')));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsWidgets);
      expect(
        tester
            .widget<LineChart>(find.byType(LineChart).first)
            .data
            .lineBarsData
            .single
            .spots,
        hasLength(250),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
