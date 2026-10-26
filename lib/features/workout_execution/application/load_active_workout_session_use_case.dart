import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';

class LoadActiveWorkoutSessionUseCase {
  const LoadActiveWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
    required WorkoutRunnerMapper mapper,
  }) : _workoutSessionRepository = workoutSessionRepository,
       _mapper = mapper;

  static final _logger = AppLogger(name: 'LoadActiveWorkoutSessionUseCase');

  final WorkoutSessionRepository _workoutSessionRepository;
  final WorkoutRunnerMapper _mapper;

  Future<WorkoutRunnerSessionViewData?> load() async {
    _logger.info('load');
    try {
      final aggregate = await _workoutSessionRepository.getActiveSession();
      if (aggregate == null) {
        _logger.info('load — not found');
        return null;
      }
      _logger.info('load — found session: ${aggregate.session.id}');
      return _mapper.toViewData(aggregate);
    } catch (e) {
      _logger.error('load — failed', error: e);
      rethrow;
    }
  }
}
