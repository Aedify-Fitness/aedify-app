import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';

class SaveCustomExerciseUseCase {
  const SaveCustomExerciseUseCase({
    required ExerciseRepository exerciseRepository,
  }) : _exerciseRepository = exerciseRepository;

  final ExerciseRepository _exerciseRepository;

  Future<int> create(CustomExerciseDraft draft) async {
    return _exerciseRepository.createCustomExercise(draft.toSeed());
  }

  Future<void> update({
    required int exerciseId,
    required CustomExerciseDraft draft,
  }) async {
    await _exerciseRepository.updateCustomExercise(
      exerciseId: exerciseId,
      seed: draft.toSeed(),
    );
  }
}
