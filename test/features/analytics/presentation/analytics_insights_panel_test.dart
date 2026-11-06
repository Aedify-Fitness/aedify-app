import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_insights_providers.dart';
import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_insights_panel.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late _InsightsController controller;
  Future<void> pump(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1,
  }) async {
    controller = _InsightsController();
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    final router = GoRouter(
      initialLocation: AppRoutes.analytics().path,
      routes: [
        GoRoute(
          path: AppRoutes.analytics().path,
          name: AppRoutes.analytics().name,
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsInsightsPanel(
                range: AnalyticsRange.allTime,
                unit: PreferredUnit.imperial,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AnalyticsInsightsProviders.controller.overrideWith(() => controller),
          AnalyticsInsightsProviders.data.overrideWith(
            (_, _) async => AnalyticsInsights(
              measurements: [
                BodyMeasurementEntry(
                  id: 'm',
                  measuredAt: DateTime(2026, 11, 6),
                  values: {BodyMetric.bodyweightKg: 75, BodyMetric.waistCm: 81},
                ),
              ],
              adherence: [
                const ProgrammeAdherence(
                  name: 'Fixture plan',
                  due: 4,
                  completed: 3,
                  unscheduled: 1,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'recording validates numeric data and converts saved imperial weight/length to canonical units',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pump(tester);
      await tester.tap(
        find.byKey(const ValueKey('analytics_record_measurement')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('measurement_save')));
      await tester.pumpAndSettle();
      expect(
        find.text(AppErrorStrings.analyticsMeasurementInvalid),
        findsOneWidget,
      );
      expect(controller.recorded, isNull);
      await tester.enterText(
        find.byKey(const ValueKey('measurement_bodyweightKg')),
        '165.3467',
      );
      await tester.enterText(
        find.byKey(const ValueKey('measurement_waistCm')),
        '32',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('measurement_save')));
      await tester.pumpAndSettle();
      expect(controller.recorded![BodyMetric.bodyweightKg], closeTo(75, 0.001));
      expect(controller.recorded![BodyMetric.waistCm], closeTo(81.28, 0.001));
      expect(find.byKey(const ValueKey('measurement_save')), findsNothing);
      expect(
        find.text(AppErrorStrings.analyticsMeasurementFailed),
        findsNothing,
      );
    },
  );
  testWidgets(
    'export requires review; cancelling sends nothing and native cancellation stays recoverable',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pump(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('analytics_export_csv')),
      );
      await tester.tap(find.byKey(const ValueKey('analytics_export_csv')));
      await tester.pumpAndSettle();
      expect(find.text(AnalyticsStrings.exportReview), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(controller.exports, 0);
      await tester.tap(find.byKey(const ValueKey('analytics_export_csv')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pumpAndSettle();
      expect(controller.exports, 1);
      expect(find.text(AnalyticsStrings.exportCancelled), findsOneWidget);
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'insights and measurement dialog adapt to 320px/2x text in ${dark ? 'dark' : 'light'}',
      (tester) async {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pump(tester, dark: dark, scale: 2);
        await tester.ensureVisible(find.text('Fixture plan'));
        await tester.pumpAndSettle();
        expect(find.textContaining('3 of 4 completed'), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('analytics_record_measurement')),
        );
        await tester.tap(
          find.byKey(const ValueKey('analytics_record_measurement')),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('measurement_rightThighCm')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
      },
    );
  }
}

class _InsightsController extends AnalyticsInsightsController {
  Map<BodyMetric, double>? recorded;
  int exports = 0;
  @override
  Future<void> record(Map<BodyMetric, double> values) async {
    recorded = values;
  }

  @override
  Future<AnalyticsExportResult> export(
    AnalyticsRange range, {
    bool confirmed = false,
  }) async {
    expect(confirmed, isTrue);
    exports++;
    return AnalyticsExportResult.cancelled;
  }
}
