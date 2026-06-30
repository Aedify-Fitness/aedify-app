import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/saved_workout_library_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class SavedWorkoutLibraryController
    extends AsyncNotifier<SavedWorkoutLibraryState> {
  @override
  Future<SavedWorkoutLibraryState> build() async {
    return _load();
  }

  Future<SavedWorkoutLibraryState> _load() async {
    try {
      final useCase = ref.read(AppProviders.listSavedWorkoutsUseCaseProvider);
      final items = await useCase.execute();
      return SavedWorkoutLibraryState(items: items, isLoading: false);
    } catch (e) {
      return SavedWorkoutLibraryState(
        items: [],
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.workoutLibraryLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> archiveWorkout(String id) async {
    try {
      final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
      await repo.archiveSavedWorkout(id);
      await reload();
    } catch (e) {
      // silently fail; user can retry
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
      await repo.deleteSavedWorkout(id);
      await reload();
    } catch (e) {
      // silently fail; user can retry
    }
  }
}
