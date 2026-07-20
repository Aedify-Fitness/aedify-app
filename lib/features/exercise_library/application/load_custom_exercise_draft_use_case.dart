import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class LoadCustomExerciseDraftUseCase {
  static final _logger = AppLogger(name: 'LoadCustomExerciseDraftUseCase');

  const LoadCustomExerciseDraftUseCase({
    required ExerciseRepository exerciseRepository,
  }) : _exerciseRepository = exerciseRepository;

  final ExerciseRepository _exerciseRepository;

  Future<CustomExerciseDraft> createEmptyDraft() async {
    _logger.debug('createEmpty');
    return const CustomExerciseDraft(
      name: '',
      muscleGroups: {},
      modality: ExerciseModality.strength,
      loggingType: ExerciseLoggingType.repsWeight,
    );
  }

  Future<CustomExerciseDraft> loadForEdit(int exerciseId) async {
    _logger.debug('loadForEdit — id: $exerciseId');
    final detail = await _exerciseRepository.getCustomExerciseDetail(
      exerciseId,
    );
    if (detail == null) {
      throw Exception('Custom exercise not found: $exerciseId');
    }
    return CustomExerciseDraft(
      name: detail.name,
      muscleGroups: detail.muscleGroups,
      modality: detail.modality,
      loggingType: detail.loggingType,
      equipment: detail.equipment,
      difficulty: detail.difficulty,
      steps: detail.steps,
    );
  }
}
