import 'package:aedify/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/application/workout_history_detail_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class WorkoutHistoryDetailController
    extends AsyncNotifier<WorkoutHistoryDetailState> {
  WorkoutHistoryDetailController(this.sessionId);

  static final _logger = AppLogger(name: 'WorkoutHistoryDetailController');

  final String sessionId;

  @override
  Future<WorkoutHistoryDetailState> build() async {
    _logger.info('build — sessionId: $sessionId');
    return _load();
  }

  Future<WorkoutHistoryDetailState> _load() async {
    try {
      final useCase = ref.read(
        AppProviders.loadWorkoutHistoryDetailUseCaseProvider,
      );
      final item = await useCase.execute(sessionId);
      return WorkoutHistoryDetailState(item: item, isLoading: false);
    } catch (e) {
      _logger.error('build — load failed for sessionId: $sessionId', error: e);
      return WorkoutHistoryDetailState(
        item: null,
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.workoutHistoryDetailLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }
}
