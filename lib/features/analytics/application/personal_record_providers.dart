import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/domain/personal_record_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local record state derived from the complete source history on every update.
abstract final class PersonalRecordProviders {
  static final serviceProvider = Provider<PersonalRecordService>(
    (ref) => const PersonalRecordService(),
  );

  /// The loading/error/empty/data state for all exercises or one exercise ID.
  ///
  /// Display date and session filters belong after detection so earlier records
  /// remain part of each comparison. Corrections/deletions update automatically.
  /// Invalidate the corresponding analytics query provider to retry a failure.
  static final recordsProvider = Provider.autoDispose
      .family<AsyncValue<PersonalRecordSummary>, int?>((ref, exerciseId) {
        final evidence = ref.watch(
          AnalyticsProviders.completedWorkingSetsProvider(
            AnalyticsLogQuery(exerciseId: exerciseId),
          ),
        );
        return evidence.whenData(ref.watch(serviceProvider).detect);
      });
}
