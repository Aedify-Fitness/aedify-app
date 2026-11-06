import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/analytics/application/analytics_view_mapper.dart';
import 'package:aedify/features/analytics/data/analytics_insights_repository.dart';
import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AnalyticsInsightsProviders {
  static final repository = Provider(
    (ref) => AnalyticsInsightsRepository(
      ref.watch(AppProviders.appDatabaseProvider),
    ),
  );
  static final changes = StreamProvider(
    (ref) => ref.watch(repository).watchChanges(),
    retry: (_, _) => null,
  );
  static final data = FutureProvider.autoDispose
      .family<AnalyticsInsights, AnalyticsRange>((ref, range) {
        ref.watch(changes);
        final now = ref.watch(PlateauProviders.clockProvider)();
        return ref
            .watch(repository)
            .load(now: now, from: AnalyticsViewMapper.rangeStart(range, now));
      }, retry: (_, _) => null);
  static final destination = Provider<AnalyticsCsvDestination>(
    (_) => NativeAnalyticsCsvDestination(),
  );
  static final controller =
      AsyncNotifierProvider<AnalyticsInsightsController, void>(
        AnalyticsInsightsController.new,
        retry: (_, _) => null,
      );
}

class AnalyticsInsightsController extends AsyncNotifier<void> {
  bool _busy = false;
  @override
  void build() {}

  Future<void> record(Map<BodyMetric, double> values) async {
    if (_busy) throw AnalyticsQueryFailure.unavailable;
    _busy = true;
    try {
      final now = ref.read(PlateauProviders.clockProvider)();
      await ref
          .read(AnalyticsInsightsProviders.repository)
          .saveMeasurement(now, values, now: now);
      ref.invalidate(AnalyticsInsightsProviders.data);
    } finally {
      _busy = false;
    }
  }

  Future<AnalyticsExportResult> export(
    AnalyticsRange range, {
    bool confirmed = false,
  }) async {
    if (!confirmed) return AnalyticsExportResult.cancelled;
    if (_busy) return AnalyticsExportResult.unavailable;
    _busy = true;
    try {
      final now = ref.read(PlateauProviders.clockProvider)();
      final bytes = await ref
          .read(AnalyticsInsightsProviders.repository)
          .export(now: now, from: AnalyticsViewMapper.rangeStart(range, now));
      return await ref.read(AnalyticsInsightsProviders.destination).save(bytes);
    } on FormatException {
      return AnalyticsExportResult.tooLarge;
    } catch (_) {
      return AnalyticsExportResult.unavailable;
    } finally {
      _busy = false;
    }
  }
}
