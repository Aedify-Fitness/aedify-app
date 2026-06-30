import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/application/workout_history_detail_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class WorkoutHistoryDetailController
    extends AsyncNotifier<WorkoutHistoryDetailState> {
  WorkoutHistoryDetailController(this.sessionId);

  final String sessionId;

  @override
  Future<WorkoutHistoryDetailState> build() async {
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
