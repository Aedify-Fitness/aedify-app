import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';

class SaveWorkoutSessionProgressUseCase {
  const SaveWorkoutSessionProgressUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
    required WorkoutRunnerMapper mapper,
  }) : _workoutSessionRepository = workoutSessionRepository,
       _mapper = mapper;

  static final _logger = AppLogger(name: 'SaveWorkoutSessionProgressUseCase');

  final WorkoutSessionRepository _workoutSessionRepository;
  final WorkoutRunnerMapper _mapper;

  Future<void> save(WorkoutRunnerSessionViewData session) async {
    _logger.debug(
      'save — sessionId: ${session.sessionId}, exercises: ${session.exercises.length}',
    );
    final draft = _mapper.toDraft(session);
    await _workoutSessionRepository.saveSessionProgress(draft);
  }
}
