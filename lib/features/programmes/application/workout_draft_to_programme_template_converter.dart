import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';

/// Converts a newly authored workout into an owned programme template.
class WorkoutDraftToProgrammeTemplateConverter {
  const WorkoutDraftToProgrammeTemplateConverter();

  ProgrammeBuilderTemplateDraft convert(WorkoutBuilderDraft draft) =>
      ProgrammeBuilderTemplateDraft(
        id: draft.id,
        templateKey: draft.id,
        name: draft.name,
        goalTags: draft.goalTags,
        description: draft.description,
        estimatedDurationMinutes: draft.estimatedDurationMinutes,
        restBetweenExercisesSeconds: draft.restBetweenExercisesSeconds,
        exercises: [
          for (final exercise in draft.exercises)
            ProgrammeExerciseDraft(
              id: exercise.id,
              exerciseId: exercise.exercise.exerciseId,
              exerciseRef: exercise.exercise.name,
              exerciseRole: exercise.exerciseRole,
              sortOrder: exercise.sortOrder,
              supersetGroupId: exercise.supersetGroupId,
              supersetOrder: exercise.supersetOrder,
              notes: exercise.notes,
              restBetweenExercisesSeconds: exercise.restBetweenExercisesSeconds,
              sets: [
                for (final set in exercise.sets)
                  SetPrescriptionDraft(
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
            ),
        ],
      );
}
