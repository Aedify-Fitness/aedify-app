import 'package:aedify/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/application/workout_history_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class WorkoutHistoryController extends AsyncNotifier<WorkoutHistoryState> {
  static final _logger = AppLogger(name: 'WorkoutHistoryController');

  @override
  Future<WorkoutHistoryState> build() async {
    _logger.info('build');
    return _load();
  }

  Future<WorkoutHistoryState> _load() async {
    try {
      final useCase = ref.read(AppProviders.listWorkoutHistoryUseCaseProvider);
      final items = await useCase.execute();
      return WorkoutHistoryState(items: items, isLoading: false);
    } catch (e) {
      _logger.error('build — load failed', error: e);
      return WorkoutHistoryState(
        items: [],
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.workoutHistoryLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }
}
