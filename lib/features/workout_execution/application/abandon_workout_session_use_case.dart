import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';

class AbandonWorkoutSessionUseCase {
  const AbandonWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
  }) : _workoutSessionRepository = workoutSessionRepository;

  static final _logger = AppLogger(name: 'AbandonWorkoutSessionUseCase');

  final WorkoutSessionRepository _workoutSessionRepository;

  Future<void> abandon(String sessionId) async {
    _logger.info('abandon — sessionId: $sessionId');
    await _workoutSessionRepository.abandonSession(sessionId);
  }
}
