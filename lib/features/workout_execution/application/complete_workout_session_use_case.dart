import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';

class CompleteWorkoutSessionUseCase {
  const CompleteWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
  }) : _workoutSessionRepository = workoutSessionRepository;

  final WorkoutSessionRepository _workoutSessionRepository;

  Future<void> complete(WorkoutRunnerCompletionDraft draft) async {
    await _workoutSessionRepository.completeSession(
      id: draft.sessionId,
      completedAt: draft.completedAt,
      durationSeconds: draft.durationSeconds,
    );
  }
}
