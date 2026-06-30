import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';

class LoadActiveWorkoutSessionUseCase {
  const LoadActiveWorkoutSessionUseCase({
    required WorkoutSessionRepository workoutSessionRepository,
    required WorkoutRunnerMapper mapper,
  }) : _workoutSessionRepository = workoutSessionRepository,
       _mapper = mapper;

  final WorkoutSessionRepository _workoutSessionRepository;
  final WorkoutRunnerMapper _mapper;

  Future<WorkoutRunnerSessionViewData?> load() async {
    final aggregate = await _workoutSessionRepository.getActiveSession();
    if (aggregate == null) return null;
    return _mapper.toViewData(aggregate);
  }
}
