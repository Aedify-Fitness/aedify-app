import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';

class DeleteCustomExerciseUseCase {
  static final _logger = AppLogger(name: 'DeleteCustomExerciseUseCase');

  const DeleteCustomExerciseUseCase({
    required ExerciseRepository exerciseRepository,
  }) : _exerciseRepository = exerciseRepository;

  final ExerciseRepository _exerciseRepository;

  Future<void> delete(int exerciseId) async {
    _logger.info('delete — exerciseId: $exerciseId');
    try {
      await _exerciseRepository.deleteCustomExercise(exerciseId);
    } catch (e) {
      _logger.error('delete — failure', error: e);
      rethrow;
    }
  }
}
