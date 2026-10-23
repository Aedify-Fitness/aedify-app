import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart'
    as workout;
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';

/// Maps editor fields without dropping programme-only prescription metadata.
abstract final class ProgrammeExerciseConfigAdapter {
  static WorkoutBuilderExerciseDraft toEditor(
    ProgrammeExerciseDraft exercise,
    ExerciseDetailViewData? details,
  ) => WorkoutBuilderExerciseDraft(
    id: exercise.id,
    exercise: ExerciseReference(
      exerciseId: exercise.exerciseId,
      name:
          details?.name ??
          exercise.exerciseRef ??
          AppStrings.exerciseNumberLabel(exercise.exerciseId),
      modality: details?.modality.dbValue ?? '',
      loggingType:
          (details?.loggingType ??
                  (exercise.sets.any((set) => set.durationSeconds != null) &&
                          exercise.sets.every(
                            (set) =>
                                set.prescribedRepsExact == null &&
                                set.prescribedRepsMin == null,
                          )
                      ? ExerciseLoggingType.duration
                      : ExerciseLoggingType.repsWeight))
              .dbValue,
    ),
    sortOrder: exercise.sortOrder,
    supersetGroupId: exercise.supersetGroupId,
    supersetOrder: exercise.supersetOrder,
    notes: exercise.notes,
    sets: [
      for (final set in exercise.sets)
        workout.SetPrescriptionDraft(
          id: set.id,
          setIndex: set.setIndex,
          setType: set.setType,
          setIntent: set.setIntent,
          prescribedRepsMin: set.prescribedRepsMin,
          prescribedRepsMax: set.prescribedRepsMax,
          prescribedRepsExact: set.prescribedRepsExact,
          durationSeconds: set.durationSeconds,
          distanceMeters: set.distanceMeters,
          weightPrescriptionType: set.weightPrescriptionType,
          prescribedWeightKg: set.prescribedWeightKg,
          prescribedRpeMin: set.prescribedRpeMin,
          prescribedRpeMax: set.prescribedRpeMax,
          prescribedRir: set.prescribedRir,
          restSeconds: set.restSeconds,
        ),
    ],
  );

  static SetPrescriptionDraft applyEdit(
    SetPrescriptionDraft original,
    workout.SetPrescriptionDraft edited,
  ) => original.copyWith(
    setType: edited.setType,
    prescribedRepsMin: edited.prescribedRepsMin,
    prescribedRepsMax: edited.prescribedRepsMax,
    prescribedRepsExact: edited.prescribedRepsExact,
    durationSeconds: edited.durationSeconds,
    prescribedWeightKg: edited.prescribedWeightKg,
    prescribedRpeMin: edited.prescribedRpeMin,
    prescribedRpeMax: edited.prescribedRpeMax,
    prescribedRir: edited.prescribedRir,
    restSeconds: edited.restSeconds,
  );
}
