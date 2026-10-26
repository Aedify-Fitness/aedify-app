import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

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
          message: AppStrings.customExerciseNameRequired,
        ),
      );
    }

    if (draft.muscleGroups.isEmpty) {
      errors.add(
        CustomExerciseValidationError(
          scope: CustomExerciseValidationScope.muscleGroups,
          code: AppErrorCodes.customExerciseMuscleGroupsRequired,
          message: AppStrings.customExerciseMuscleGroupRequired,
        ),
      );
    }

    for (var i = 0; i < draft.steps.length; i++) {
      if (draft.steps[i].trim().isEmpty) {
        errors.add(
          CustomExerciseValidationError(
            scope: CustomExerciseValidationScope.steps,
            code: AppErrorCodes.customExerciseStepEmpty,
            message: AppStrings.customExerciseStepEmpty(i + 1),
            stepIndex: i,
          ),
        );
      }
    }

    _logger.debug('validate — issues: ${errors.length}');
    return errors;
  }
}
