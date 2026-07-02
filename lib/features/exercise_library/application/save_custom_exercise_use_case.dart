import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';

class SaveCustomExerciseUseCase {
  static final _logger = AppLogger(name: 'SaveCustomExerciseUseCase');

  const SaveCustomExerciseUseCase({
    required ExerciseRepository exerciseRepository,
  }) : _exerciseRepository = exerciseRepository;

  final ExerciseRepository _exerciseRepository;

  Future<int> create(CustomExerciseDraft draft) async {
    _logger.info('save — name: ${draft.name}');
    try {
      return _exerciseRepository.createCustomExercise(draft.toSeed());
    } catch (e) {
      _logger.error('save — failure', error: e);
      rethrow;
    }
  }

  Future<void> update({
    required int exerciseId,
    required CustomExerciseDraft draft,
  }) async {
    _logger.info('save — name: ${draft.name} (update)');
    try {
      await _exerciseRepository.updateCustomExercise(
        exerciseId: exerciseId,
        seed: draft.toSeed(),
      );
    } catch (e) {
      _logger.error('save — failure (update)', error: e);
      rethrow;
    }
  }
}
