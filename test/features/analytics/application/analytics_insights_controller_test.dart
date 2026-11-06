import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/application/analytics_insights_providers.dart';
import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'unconfirmed export never reads private evidence or opens the destination',
    () async {
      final container = ProviderContainer(
        overrides: [
          AnalyticsInsightsProviders.repository.overrideWith(
            (_) => throw StateError('must not read data'),
          ),
          AnalyticsInsightsProviders.destination.overrideWith(
            (_) => throw StateError('must not open destination'),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(
        await container
            .read(AnalyticsInsightsProviders.controller.notifier)
            .export(AnalyticsRange.allTime),
        AnalyticsExportResult.cancelled,
      );
    },
  );
  test(
    'confirmed export carries only its DTO and serializes concurrent record/export actions',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final destination = _CapturedDestination();
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AnalyticsInsightsProviders.destination.overrideWithValue(destination),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        AnalyticsInsightsProviders.controller.notifier,
      );
      await controller.record({
        BodyMetric.bodyweightKg: 75,
        BodyMetric.neckCm: 38,
        BodyMetric.bodyFatPercent: 20,
      });
      await db.customStatement(
        "UPDATE body_measurements SET notes = 'PRIVATE_NOTE_SENTINEL'",
      );
      final first = controller.export(AnalyticsRange.allTime, confirmed: true);
      final bytes = await destination.received.future;
      expect(utf8.decode(bytes), contains('"bodyFatPercent","20.0","%"'));
      expect(utf8.decode(bytes), isNot(contains('PRIVATE_NOTE_SENTINEL')));
      expect(
        await controller.export(AnalyticsRange.allTime, confirmed: true),
        AnalyticsExportResult.unavailable,
      );
      await expectLater(
        controller.record({BodyMetric.bodyweightKg: 76}),
        throwsA(AnalyticsQueryFailure.unavailable),
      );
      destination.result.complete(AnalyticsExportResult.saved);
      expect(await first, AnalyticsExportResult.saved);
      expect(await db.select(db.bodyMeasurements).get(), hasLength(1));
      expect(await db.select(db.localFileRecords).get(), isEmpty);
    },
  );
}

class _CapturedDestination implements AnalyticsCsvDestination {
  final received = Completer<Uint8List>();
  final result = Completer<AnalyticsExportResult>();
  @override
  Future<AnalyticsExportResult> save(Uint8List bytes) {
    received.complete(bytes);
    return result.future;
  }

  @override
  Future<void> cancel() async {}
}
