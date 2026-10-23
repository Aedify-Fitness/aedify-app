import 'package:aedify/app/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists local exercise preferences and exposes recoverable save failures.
class ExerciseDetailActionsController extends Notifier<AsyncValue<void>> {
  ExerciseDetailActionsController(this._exerciseId);

  final int _exerciseId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> setFavorite(bool isFavorite) => _save(
    () => ref
        .read(AppProviders.exerciseRepositoryProvider)
        .setFavorite(exerciseId: _exerciseId, isFavorite: isFavorite),
  );

  Future<void> setAvoided(bool isAvoided) => _save(
    () => ref
        .read(AppProviders.exerciseRepositoryProvider)
        .setSubstitutedOut(
          exerciseId: _exerciseId,
          isSubstitutedOut: isAvoided,
        ),
  );

  Future<void> _save(Future<void> Function() save) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(save);
    if (!ref.mounted) return;
    state = result;
    if (!result.hasError) {
      ref.invalidate(
        AppProviders.exerciseDetailControllerProvider(_exerciseId),
      );
    }
  }
}
