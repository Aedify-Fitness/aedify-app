import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';

class WorkoutBuilderValidator {
  const WorkoutBuilderValidator();

  static const _modalitiesWithoutWeight = {
    'bodyweight',
    'cardio',
    'mobility',
    'stretching',
  };

  List<WorkoutBuilderValidationError> validate(WorkoutBuilderDraft draft) {
    final errors = <WorkoutBuilderValidationError>[];

    if (draft.name.trim().isEmpty) {
      errors.add(
        const WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.workout,
          code: 'missing_name',
          message: AppStrings.workoutNameRequired,
        ),
      );
    }

    if (draft.exercises.isEmpty) {
      errors.add(
        const WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.workout,
          code: 'no_exercises',
          message: AppStrings.addAtLeastOneExercise,
        ),
      );
    }

    for (final exercise in draft.exercises) {
      errors.addAll(_validateExercise(exercise));
    }

    return errors;
  }

  List<WorkoutBuilderValidationError> _validateExercise(
    WorkoutBuilderExerciseDraft exercise,
  ) {
    final errors = <WorkoutBuilderValidationError>[];

    if (exercise.sets.isEmpty) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.exercise,
          code: 'no_sets',
          message: AppStrings.addAtLeastOneSet,
          exerciseId: exercise.id,
        ),
      );
    }

    for (final prescription in exercise.sets) {
      errors.addAll(_validateSet(exercise, prescription));
    }

    return errors;
  }

  List<WorkoutBuilderValidationError> _validateSet(
    WorkoutBuilderExerciseDraft exercise,
    SetPrescriptionDraft prescription,
  ) {
    final errors = <WorkoutBuilderValidationError>[];

    final repsMin = prescription.prescribedRepsMin;
    final repsMax = prescription.prescribedRepsMax;
    final repsExact = prescription.prescribedRepsExact;

    if (repsMin != null && repsMin < 1) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_reps_min',
          message: AppStrings.minRepsAtLeast1,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    if (repsMax != null && repsMax < 1) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_reps_max',
          message: AppStrings.maxRepsAtLeast1,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    if (repsExact != null && repsExact < 1) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_reps_exact',
          message: AppStrings.repsAtLeast1,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    if (_requiresWeight(exercise.exercise.modality, prescription)) {
      if (prescription.prescribedWeightKg == null ||
          prescription.prescribedWeightKg! < 0) {
        errors.add(
          WorkoutBuilderValidationError(
            scope: WorkoutBuilderValidationScope.set,
            code: 'invalid_weight',
            message: AppStrings.enterValidWeight,
            exerciseId: exercise.id,
            setId: prescription.id,
          ),
        );
      }
    }

    final rpeMin = prescription.prescribedRpeMin;
    final rpeMax = prescription.prescribedRpeMax;

    if (rpeMin != null && (rpeMin < 1 || rpeMin > 10)) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_rpe_min',
          message: AppStrings.rpeMinBetween1And10,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    if (rpeMax != null && (rpeMax < 1 || rpeMax > 10)) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_rpe_max',
          message: AppStrings.rpeMaxBetween1And10,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    if (rpeMin != null && rpeMax != null && rpeMin > rpeMax) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'rpe_range',
          message: AppStrings.rpeMinCannotExceedMax,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    final rir = prescription.prescribedRir;

    if (rir != null && rir < 0) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_rir',
          message: AppStrings.rirCannotBeNegative,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    final rest = prescription.restSeconds;

    if (rest != null && rest < 0) {
      errors.add(
        WorkoutBuilderValidationError(
          scope: WorkoutBuilderValidationScope.set,
          code: 'invalid_rest',
          message: AppStrings.restCannotBeNegative,
          exerciseId: exercise.id,
          setId: prescription.id,
        ),
      );
    }

    return errors;
  }

  bool _requiresWeight(String modality, SetPrescriptionDraft prescription) {
    if (_modalitiesWithoutWeight.contains(modality.toLowerCase())) {
      return false;
    }
    return prescription.setType == SetType.working ||
        prescription.setType == SetType.warmup;
  }
}
