import 'package:aedify/features/analytics/domain/analytics_csv.dart';
import 'package:flutter/services.dart';

enum AnalyticsExportResult { saved, cancelled, unavailable, tooLarge }

abstract interface class AnalyticsCsvDestination {
  Future<AnalyticsExportResult> save(Uint8List bytes);
  Future<void> cancel();
}

/// Sends only the explicitly reviewed CSV bytes to the system file picker.
class NativeAnalyticsCsvDestination implements AnalyticsCsvDestination {
  static const channel = MethodChannel('aedify/analytics_export');
  @override
  Future<AnalyticsExportResult> save(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > AnalyticsCsv.maxBytes) {
      return AnalyticsExportResult.tooLarge;
    }
    try {
      final saved = await channel.invokeMethod<bool>('save', {'bytes': bytes});
      return saved == true
          ? AnalyticsExportResult.saved
          : AnalyticsExportResult.cancelled;
    } catch (_) {
      return AnalyticsExportResult.unavailable;
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await channel.invokeMethod<void>('cancel');
    } catch (_) {
      /* Nothing private is retained by Dart. */
    }
  }
}
