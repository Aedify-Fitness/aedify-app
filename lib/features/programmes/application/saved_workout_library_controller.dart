import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/saved_workout_library_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/core/logging/app_logger.dart';

class SavedWorkoutLibraryController
    extends AsyncNotifier<SavedWorkoutLibraryState> {
  static final _logger = AppLogger(name: 'SavedWorkoutLibraryController');

  @override
  Future<SavedWorkoutLibraryState> build() async {
    _logger.info('build');
    return _load();
  }

  Future<SavedWorkoutLibraryState> _load() async {
    try {
      final useCase = ref.read(AppProviders.listSavedWorkoutsUseCaseProvider);
      final items = await useCase.execute();
      return SavedWorkoutLibraryState(items: items, isLoading: false);
    } catch (e) {
      _logger.error('_load — failure', error: e);
      return SavedWorkoutLibraryState(
        items: [],
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.workoutLibraryLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    _logger.info('reload');
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> archiveWorkout(String id) async {
    _logger.info('archiveWorkout — id: $id');
    try {
      final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
      await repo.archiveSavedWorkout(id);
      await reload();
    } catch (e) {
      _logger.error('archiveWorkout — failure', error: e);
    }
  }

  Future<void> deleteWorkout(String id) async {
    _logger.info('deleteWorkout — id: $id');
    try {
      final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
      await repo.deleteSavedWorkout(id);
      await reload();
    } catch (e) {
      _logger.error('deleteWorkout — failure', error: e);
    }
  }
}
