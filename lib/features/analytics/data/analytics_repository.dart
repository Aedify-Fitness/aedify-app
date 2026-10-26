import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';

/// Read-only access to source logs, without derived caches or persistence.
abstract interface class AnalyticsRepository {
  Future<List<AnalyticsSetLog>> loadCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  });

  /// Refreshes after source log, session, membership or catalogue mutations.
  Stream<List<AnalyticsSetLog>> watchCompletedWorkingSets({
    AnalyticsLogQuery query = const AnalyticsLogQuery(),
  });
}
