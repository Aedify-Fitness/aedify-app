import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';

class CompleteWorkoutSessionUseCase {
  const CompleteWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
  }) : _workoutSessionRepository = workoutSessionRepository;

  static final _logger = AppLogger(name: 'CompleteWorkoutSessionUseCase');

  final WorkoutSessionRepository _workoutSessionRepository;

  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    _logger.info('complete — sessionId: ${draft.sessionId}');
    try {
      await _workoutSessionRepository.completeSession(
        id: draft.sessionId,
        completedAt: draft.completedAt,
        durationSeconds: draft.durationSeconds,
      );
      _logger.info('complete — success: ${draft.sessionId}');
    } catch (e) {
      _logger.error('complete — failed: ${draft.sessionId}', error: e);
      rethrow;
    }
  }
}
