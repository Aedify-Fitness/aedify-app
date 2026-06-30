import 'package:aedify/features/exercise_library/data/exercise_repository.dart';

class DeleteCustomExerciseUseCase {
  const DeleteCustomExerciseUseCase({
    required ExerciseRepository exerciseRepository,
  }) : _exerciseRepository = exerciseRepository;

  final ExerciseRepository _exerciseRepository;

  Future<void> delete(int exerciseId) async {
    await _exerciseRepository.deleteCustomExercise(exerciseId);
  }
}
