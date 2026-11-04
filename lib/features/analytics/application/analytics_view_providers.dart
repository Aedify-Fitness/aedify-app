import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/analytics/application/analytics_view_mapper.dart';
import 'package:aedify/features/analytics/domain/analytics_log_query.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/plateau_detection/application/plateau_providers.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prepared screen state and metadata reads, behind feature-owned boundaries.
abstract final class AnalyticsViewProviders {
  static final unitsProvider = Provider<AsyncValue<PreferredUnit>>((ref) {
    final profile = ref.watch(AppProviders.profileControllerProvider);
    return profile.when(
      loading: () => const AsyncLoading(),
      error: (_, _) =>
          AsyncError(AnalyticsQueryFailure.unavailable, StackTrace.current),
      data: (state) {
        if (state.isLoading) return const AsyncLoading();
        if (state.hasError && state.profile == null) {
          return AsyncError(
            AnalyticsQueryFailure.unavailable,
            StackTrace.current,
          );
        }
        return AsyncData(state.profile?.preferredUnits ?? PreferredUnit.metric);
      },
    );
  });
  static final dataProvider = Provider.autoDispose
      .family<
        AsyncValue<AnalyticsViewData>,
        ({AnalyticsRange range, int? exerciseId})
      >((ref, request) {
        final logs = ref.watch(
          AnalyticsProviders.completedWorkingSetsProvider(
            AnalyticsLogQuery(exerciseId: request.exerciseId),
          ),
        );
        final now = ref.watch(PlateauProviders.clockProvider)();
        return logs.whenData(
          (logs) => const AnalyticsViewMapper().map(
            logs,
            range: request.range,
            now: now,
            exerciseId: request.exerciseId,
          ),
        );
      });
  static final recentWorkoutsProvider =
      FutureProvider.autoDispose<List<WorkoutHistoryListItem>>((ref) async {
        ref.watch(
          AnalyticsProviders.completedWorkingSetsProvider(
            const AnalyticsLogQuery(),
          ),
        );
        try {
          return await ref
              .watch(AppProviders.workoutHistoryRepositoryProvider)
              .listCompletedSessions();
        } catch (_) {
          throw AnalyticsQueryFailure.unavailable;
        }
      }, retry: (_, _) => null);
  static final historyProvider = FutureProvider.autoDispose
      .family<List<ExerciseHistorySession>, int>((ref, id) async {
        ref.watch(
          AnalyticsProviders.completedWorkingSetsProvider(
            AnalyticsLogQuery(exerciseId: id),
          ),
        );
        try {
          return await ref
              .watch(AppProviders.workoutHistoryRepositoryProvider)
              .listExerciseHistory(id);
        } catch (_) {
          throw AnalyticsQueryFailure.unavailable;
        }
      }, retry: (_, _) => null);

  /// Refreshes only this feature's current read state and recoverable failures.
  static void refresh(WidgetRef ref, {int? exerciseId}) {
    ref.invalidate(
      AnalyticsProviders.completedWorkingSetsProvider(
        AnalyticsLogQuery(exerciseId: exerciseId),
      ),
    );
    ref.invalidate(dataProvider);
    ref.invalidate(recentWorkoutsProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(PlateauProviders.evaluationsProvider);
    if (ref.read(unitsProvider).hasError) {
      ref.invalidate(AppProviders.profileControllerProvider);
    }
  }
}
