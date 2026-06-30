import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';

class AbandonWorkoutSessionUseCase {
  const AbandonWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
  }) : _workoutSessionRepository = workoutSessionRepository;

  final WorkoutSessionRepository _workoutSessionRepository;

  Future<void> abandon(String sessionId) async {
    await _workoutSessionRepository.abandonSession(sessionId);
  }
}
