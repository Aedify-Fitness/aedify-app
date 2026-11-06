import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_insights_providers.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'offline measurements/adherence/CSV review, native destination and activity compatibility',
    (tester) async {
      final previous = HttpOverrides.current;
      final network = _GapNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = previous);
      final root = await (await getTemporaryDirectory()).createTemp(
        'gap_closure_',
      );
      final file = File(p.join(root.path, 'fixture.sqlite'));
      var db = AppDatabase(NativeDatabase(file));
      final now = DateTime.now();
      final destination = _GapDestination();
      ProviderContainer scope() => ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AnalyticsViewProviders.unitsProvider.overrideWithValue(
            const AsyncData(PreferredUnit.imperial),
          ),
          PlateauProviders.clockProvider.overrideWithValue(() => now),
          AnalyticsInsightsProviders.destination.overrideWithValue(destination),
        ],
      );
      var container = scope();
      final router = GoRouter(
        initialLocation: AppRoutes.analytics().path,
        routes: [
          GoRoute(
            path: AppRoutes.analytics().path,
            name: AppRoutes.analytics().name,
            builder: (_, _) => const AnalyticsScreen(),
          ),
        ],
      );
      var dark = false;
      Future<void> mount() async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: _GapUi.captureKey,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      try {
        await container
            .read(AnalyticsInsightsProviders.repository)
            .saveMeasurement(now.subtract(const Duration(days: 7)), {
              BodyMetric.bodyweightKg: 76,
              BodyMetric.waistCm: 82,
              BodyMetric.bodyFatPercent: 22,
              BodyMetric.neckCm: 38,
            }, now: now);
        await db.customStatement(
          "UPDATE body_measurements SET notes='GAP_PRIVATE_NOTE'",
        );
        await db.customStatement(
          "INSERT INTO programs(id,name,source,creation_method,status,active,created_at,updated_at) VALUES('p','Synthetic programme','manual','manual','active',1,1,1)",
        );
        final date = DateTime(
          now.year,
          now.month,
          now.day,
        ).toIso8601String().substring(0, 10);
        for (final id in ['one', 'two']) {
          await db.customStatement(
            "INSERT INTO program_workouts(id,program_id,occurrence_ref,name,scheduled_date_local,status,created_at,updated_at) VALUES(?,'p',?,'Synthetic workout',?,'planned',1,1)",
            [id, id, date],
          );
        }
        await db.customStatement(
          "INSERT INTO workout_sessions(id,source,program_id,program_workout_id,name,started_at,completed_at,status,created_at,updated_at) VALUES('s','program','p','one','Synthetic session',1,1,'completed',1,1)",
        );
        await mount();
        await _GapUi.tap(tester, 'analytics_record_measurement');
        for (final entry in {
          'bodyweightKg': '165.3467',
          'bodyFatPercent': '21',
          'neckCm': '15',
          'waistCm': '32',
        }.entries) {
          final input = find.byKey(ValueKey('measurement_${entry.key}'));
          await tester.ensureVisible(input);
          await tester.enterText(input, entry.value);
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await _GapUi.tap(tester, 'measurement_save');
        expect(find.byKey(const ValueKey('measurement_save')), findsNothing);
        final view = await container
            .read(AnalyticsInsightsProviders.repository)
            .load(now: now);
        expect(view.measurements, hasLength(2));
        expect(
          view.measurements.last.values[BodyMetric.bodyweightKg],
          closeTo(75, 0.001),
        );
        expect(
          view.measurements.last.values[BodyMetric.waistCm],
          closeTo(81.28, 0.001),
        );
        expect(
          view.measurements.last.values[BodyMetric.neckCm],
          closeTo(38.1, 0.001),
        );
        expect(view.measurements.last.values[BodyMetric.bodyFatPercent], 21);
        expect(view.adherence.single.percent, 50);
        await _GapUi.reveal(
          tester,
          find.byKey(const ValueKey('analytics_body_metric')),
        );
        await tester.tap(find.byKey(const ValueKey('analytics_body_metric')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AnalyticsStrings.bodyFat).last);
        await tester.pumpAndSettle();
        await _GapUi.capture(tester, 'measurements_light');
        dark = true;
        await mount();
        await _GapUi.capture(tester, 'measurements_dark');
        await _GapUi.reveal(tester, find.text('Synthetic programme'));
        expect(find.textContaining('1 of 2 completed'), findsOneWidget);
        await _GapUi.capture(tester, 'adherence_dark');
        await _GapUi.tap(tester, 'analytics_export_csv');
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(destination.calls, 0);
        await _GapUi.tap(tester, 'analytics_export_csv');
        await tester.tap(find.text(AppStrings.continueLabel));
        await tester.pumpAndSettle();
        expect(find.text(AnalyticsStrings.exportSaved), findsOneWidget);
        final payload = destination.bytes!;
        final csv = utf8.decode(payload);
        expect(csv, contains('bodyFatPercent'));
        expect(csv, contains('programme_adherence'));
        for (final forbidden in [
          'GAP_PRIVATE_NOTE',
          'notes',
          'media',
          'prompt',
          'api_key',
        ]) {
          expect(csv, isNot(contains(forbidden)));
        }
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await tester.pumpAndSettle();
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        container = scope();
        await mount();
        expect(
          (await container
                  .read(AnalyticsInsightsProviders.repository)
                  .load(now: now))
              .measurements,
          hasLength(2),
        );
        if (Platform.isAndroid) {
          final health = await const MethodChannel(
            'flutter_health',
          ).invokeMethod<int>('getHealthConnectSdkStatus');
          expect(health, isA<int>());
        }

        // Real system-picker presentation/cancellation; Android is driven by the
        // companion host script, iOS cancellation calls the native lifecycle seam.
        final documents = await getApplicationDocumentsDirectory();
        final stage = File(
          p.join(documents.path, 'aedify_gap_export_stage.json'),
        );
        await stage.writeAsString(
          jsonEncode({'stage': 'csv_picker', 'pid': pid}),
        );
        final native = NativeAnalyticsCsvDestination();
        final pending = native.save(payload);
        if (Platform.isIOS) {
          await Future<void>.delayed(const Duration(seconds: 5));
          await native.cancel();
        }
        expect(
          await pending.timeout(const Duration(seconds: 45)),
          AnalyticsExportResult.cancelled,
        );
        if (Platform.isAndroid) {
          await stage.writeAsString(
            jsonEncode({'stage': 'csv_save', 'pid': pid}),
          );
          expect(
            await native.save(payload).timeout(const Duration(seconds: 45)),
            AnalyticsExportResult.saved,
          );
        }
        await stage.delete();
        if (Platform.isIOS) {
          final temporary = Directory(p.join(documents.parent.path, 'tmp'));
          expect(
            (await temporary.list().toList()).where(
              (entry) => p.basename(entry.path).startsWith('aedify_export_'),
            ),
            isEmpty,
          );
        }
        expect(await db.select(db.localFileRecords).get(), isEmpty);
        expect(network.attempts, 0);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        router.dispose();
        await db.close();
        await root.delete(recursive: true);
      }
    },
  );
}

abstract final class _GapUi {
  static final captureKey = GlobalKey();
  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 50,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(captureKey))
        .toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      p.join(
        (await getApplicationDocumentsDirectory()).path,
        'aedify_gap_$name.png',
      ),
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  }
}

class _GapDestination implements AnalyticsCsvDestination {
  Uint8List? bytes;
  int calls = 0;
  @override
  Future<AnalyticsExportResult> save(Uint8List value) async {
    calls++;
    bytes = value;
    return AnalyticsExportResult.saved;
  }

  @override
  Future<void> cancel() async {}
}

class _GapNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Offline fixture');
  }
}
