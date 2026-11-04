import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/analytics/data/analytics_repository.dart';
import 'package:aedify/features/analytics/data/drift_analytics_repository.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_set_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature-owned injection and async loading/error/empty/data states for M5.
abstract final class AnalyticsProviders {
  static final repositoryProvider = Provider<AnalyticsRepository>(
    (ref) =>
        DriftAnalyticsRepository(ref.watch(AppProviders.appDatabaseProvider)),
  );

  static final completedWorkingSetsProvider = StreamProvider.autoDispose
      .family<List<AnalyticsSetLog>, AnalyticsLogQuery>(
        (ref, query) => ref
            .watch(repositoryProvider)
            .watchCompletedWorkingSets(query: query),
        // Surface local failures immediately; callers retry by invalidating.
        retry: (_, _) => null,
      );
}
