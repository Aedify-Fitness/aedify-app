import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';

class CustomExerciseValidator {
  static final _logger = AppLogger(name: 'CustomExerciseValidator');

  const CustomExerciseValidator();

  List<CustomExerciseValidationError> validate(CustomExerciseDraft draft) {
    final errors = <CustomExerciseValidationError>[];

    if (draft.name.trim().isEmpty) {
      errors.add(
        CustomExerciseValidationError(
          scope: CustomExerciseValidationScope.name,
          code: AppErrorCodes.customExerciseNameRequired,
          message: 'Name is required.',
        ),
      );
    }

    if (draft.muscleGroups.isEmpty) {
      errors.add(
        CustomExerciseValidationError(
          scope: CustomExerciseValidationScope.muscleGroups,
          code: AppErrorCodes.customExerciseMuscleGroupsRequired,
          message: 'At least one muscle group is required.',
        ),
      );
    }

    for (var i = 0; i < draft.steps.length; i++) {
      if (draft.steps[i].trim().isEmpty) {
        errors.add(
          CustomExerciseValidationError(
            scope: CustomExerciseValidationScope.steps,
            code: AppErrorCodes.customExerciseStepEmpty,
            message: 'Step ${i + 1} cannot be empty.',
            stepIndex: i,
          ),
        );
      }
    }

    _logger.debug('validate — issues: ${errors.length}');
    return errors;
  }
}
