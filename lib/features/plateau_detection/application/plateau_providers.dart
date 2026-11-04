import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/analytics/application/analytics_providers.dart';
import 'package:aedify/features/plateau_detection/data/drift_plateau_repository.dart';
import 'package:aedify/features/plateau_detection/data/plateau_repository.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature-owned detection, clock injection and explicit dismissal workflows.
abstract final class PlateauProviders {
  static final clockProvider = Provider<DateTime Function()>(
    (ref) => DateTime.now,
  );
  static final repositoryProvider = Provider<PlateauRepository>(
    (ref) => DriftPlateauRepository(
      ref.watch(AppProviders.appDatabaseProvider),
      ref.watch(AnalyticsProviders.repositoryProvider),
    ),
  );
  static final evaluationsProvider =
      StreamProvider.autoDispose<List<PlateauEvaluation>>(
        (ref) => ref
            .watch(repositoryProvider)
            .watchEvaluations(now: ref.watch(clockProvider)),
        retry: (_, _) => null,
      );
  static final dismissalProvider = AsyncNotifierProvider.autoDispose
      .family<PlateauDismissalController, void, int>(
        (id) => PlateauDismissalController(id),
      );
}

/// Exposes safe errors while preserving a flag on failed dismissal.
class PlateauDismissalController extends AsyncNotifier<void> {
  PlateauDismissalController(this.exerciseId);
  final int exerciseId;
  @override
  void build() {}

  Future<bool> dismiss() async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await ref
          .read(PlateauProviders.repositoryProvider)
          .dismiss(exerciseId, now: ref.read(PlateauProviders.clockProvider)());
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error) {
      if (ref.mounted) {
        state = AsyncError(
          error is PlateauFailure ? error : PlateauFailure.unavailable,
          StackTrace.current,
        );
      }
      return false;
    }
  }
}
