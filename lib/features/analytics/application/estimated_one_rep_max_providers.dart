import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max.dart';
import 'package:aedify/features/analytics/domain/estimated_one_rep_max_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read-only e1RM state refreshed from the same source stream as PR detection.
abstract final class EstimatedOneRepMaxProviders {
  static final serviceProvider = Provider<EstimatedOneRepMaxService>(
    (ref) => const EstimatedOneRepMaxService(),
  );

  /// The loading/error/insufficient-data/estimate state for an exercise or all IDs.
  ///
  /// Retry failures by invalidating the matching completed-working-set query.
  static final estimatesProvider = Provider.autoDispose
      .family<AsyncValue<EstimatedOneRepMaxSummary>, int?>((ref, exerciseId) {
        final evidence = ref.watch(
          AnalyticsProviders.completedWorkingSetsProvider(
            AnalyticsLogQuery(exerciseId: exerciseId),
          ),
        );
        return evidence.whenData(ref.watch(serviceProvider).summarize);
      });
}
