import 'dart:async';

import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';

import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature-owned access to exercise history and deliberate corrections.
class WorkoutHistoryProviders {
  WorkoutHistoryProviders._();

  static final completedSessionProvider = FutureProvider.autoDispose
      .family<WorkoutRunnerSessionViewData?, String>((ref, id) async {
        final aggregate = await ref
            .watch(AppProviders.workoutSessionRepositoryProvider)
            .getSession(id);
        if (aggregate == null || aggregate.session.status != 'completed') {
          return null;
        }
        return const WorkoutRunnerMapper().toViewData(aggregate);
      });

  static final exerciseHistoryProvider = FutureProvider.autoDispose
      .family<List<ExerciseHistorySession>, int>((ref, id) {
        ref.watch(AppProviders.homeRefreshTriggerProvider);
        return ref
            .watch(AppProviders.workoutHistoryRepositoryProvider)
            .listExerciseHistory(id);
      });

  static final correctionControllerProvider = AsyncNotifierProvider.autoDispose
      .family<WorkoutHistoryCorrectionController, String?, String>(
        (id) => WorkoutHistoryCorrectionController(id),
      );
}

/// Preserves the editor on failure and refreshes dependent local views on save.
class WorkoutHistoryCorrectionController extends AsyncNotifier<String?> {
  WorkoutHistoryCorrectionController(this.sessionId);

  final String sessionId;

  @override
  FutureOr<String?> build() => null;

  Future<bool> save(WorkoutHistorySetCorrection correction) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await ref
          .read(AppProviders.workoutHistoryRepositoryProvider)
          .correctSession(sessionId: sessionId, corrections: [correction]);
      if (!ref.mounted) return true;
      ref.invalidate(
        AppProviders.workoutHistoryDetailControllerProvider(sessionId),
      );
      ref.invalidate(AppProviders.workoutHistoryControllerProvider);
      ref.invalidate(WorkoutHistoryProviders.exerciseHistoryProvider);
      ref.invalidate(
        WorkoutHistoryProviders.completedSessionProvider(sessionId),
      );
      state = const AsyncData(null);
      return true;
    } on WorkoutHistoryCorrectionFailure catch (failure) {
      if (ref.mounted) {
        state = AsyncData(switch (failure) {
          WorkoutHistoryCorrectionFailure.invalid =>
            AppErrorStrings.workoutHistoryCorrectionInvalid,
          WorkoutHistoryCorrectionFailure.missing =>
            AppErrorStrings.workoutHistoryCorrectionMissing,
          WorkoutHistoryCorrectionFailure.conflict =>
            AppErrorStrings.workoutHistoryCorrectionConflict,
        });
      }
    } catch (_) {
      if (ref.mounted) {
        state = const AsyncData(AppErrorStrings.workoutHistoryCorrectionFailed);
      }
    }
    return false;
  }
}
