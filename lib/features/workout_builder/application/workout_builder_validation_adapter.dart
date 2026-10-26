import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';
import 'package:aedify/core/validation/validated_exercise_draft.dart';
import 'package:aedify/core/validation/validated_set_draft.dart';
import 'package:aedify/core/validation/validated_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/core/logging/app_logger.dart';

class WorkoutBuilderValidationAdapter {
  const WorkoutBuilderValidationAdapter();

  static final _logger = AppLogger(name: 'WorkoutBuilderValidationAdapter');

  ValidatedWorkoutDraft toValidatedDraft(WorkoutBuilderDraft draft) {
    _logger.debug('toValidatedDraft — exercises: ${draft.exercises.length}');
    return ValidatedWorkoutDraft(
      name: draft.name,
      exercises: draft.exercises
          .map<ValidatedExerciseDraft>(_toValidatedExercise)
          .toList(),
    );
  }

  ValidatedExerciseDraft _toValidatedExercise(
    WorkoutBuilderExerciseDraft exercise,
  ) {
    return ValidatedExerciseDraft(
      id: exercise.id,
      modality: exercise.exercise.modality,
      sets: exercise.sets.map((s) {
        return ValidatedSetDraft(
          id: s.id,
          setType: s.setType,
          prescribedRepsMin: s.prescribedRepsMin,
          prescribedRepsMax: s.prescribedRepsMax,
          prescribedRepsExact: s.prescribedRepsExact,
          prescribedWeightKg: s.prescribedWeightKg,
          prescribedRpeMin: s.prescribedRpeMin,
          prescribedRpeMax: s.prescribedRpeMax,
          prescribedRir: s.prescribedRir,
          restSeconds: s.restSeconds,
        );
      }).toList(),
      supersetGroupId: exercise.supersetGroupId,
      supersetOrder: exercise.supersetOrder,
      exerciseReferenceId: exercise.exercise.exerciseId,
    );
  }

  List<WorkoutBuilderValidationError> toFeatureErrors(
    DraftValidationResult result,
  ) {
    return result.issues.map((issue) {
      return WorkoutBuilderValidationError(
        scope: _mapScope(issue.scope),
        code: issue.code,
        message: issue.message,
        exerciseId: issue.path.exerciseId,
        setId: issue.path.setId,
      );
    }).toList();
  }

  WorkoutBuilderValidationScope _mapScope(DraftValidationScope scope) {
    return switch (scope) {
      DraftValidationScope.root => WorkoutBuilderValidationScope.workout,
      DraftValidationScope.exercise => WorkoutBuilderValidationScope.exercise,
      DraftValidationScope.exerciseSet => WorkoutBuilderValidationScope.set,
      _ => WorkoutBuilderValidationScope.workout,
    };
  }
}
