import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/core/logging/app_logger.dart';

class SavedWorkoutToTemplateConverter {
  const SavedWorkoutToTemplateConverter();

  static final _logger = AppLogger(name: 'SavedWorkoutToTemplateConverter');

  ProgrammeBuilderTemplateDraft convert(SavedWorkoutAggregate aggregate) {
    _logger.debug(
      'convert — exercises: ${aggregate.exercises.length}, sets: ${aggregate.sets.length}',
    );
    final sw = aggregate.savedWorkout;

    final exercises = <ProgrammeExerciseDraft>[];
    for (final ex in aggregate.exercises) {
      final exSets = aggregate.sets.where(
        (s) => s.savedWorkoutExerciseId == ex.id,
      );
      final sets = exSets
          .map(
            (s) => SetPrescriptionDraft(
              id: const Uuid().v4(),
              setIndex: s.setIndex,
              setType: SetType.fromDb(s.setType),
              setIntent: SetIntent.fromDb(s.setIntent),
              prescribedRepsMin: s.prescribedRepsMin,
              prescribedRepsMax: s.prescribedRepsMax,
              prescribedRepsExact: s.prescribedRepsExact,
              durationSeconds: s.durationSeconds,
              distanceMeters: s.distanceMeters,
              prescribedWeightKg: s.prescribedWeightKg,
              prescribedWeightPct1rm: s.prescribedWeightPct1rm,
              prescribedWeightPctWorking: s.prescribedWeightPctWorking,
              bodyweightMultiplier: s.bodyweightMultiplier,
              prescribedRpeMin: s.prescribedRpeMin,
              prescribedRpeMax: s.prescribedRpeMax,
              prescribedRir: s.prescribedRir,
              restSeconds: s.restSeconds,
              isCalibrationEstimate: s.isCalibrationEstimate,
              derivedFromWorkingSetIndex: s.derivedFromWorkingSetIndex,
              warmupWeightRuleJson: s.warmupWeightRuleJson,
            ),
          )
          .toList();

      exercises.add(
        ProgrammeExerciseDraft(
          id: const Uuid().v4(),
          exerciseId: ex.exerciseId,
          sortOrder: ex.sortOrder,
          sets: sets,
          exerciseRef: ex.exerciseRef,
          exerciseRole: null,
          supersetGroupId: ex.supersetGroupId,
          supersetOrder: ex.supersetOrder,
          notes: ex.notes,
          cuesJson: ex.cuesJson,
        ),
      );
    }

    return ProgrammeBuilderTemplateDraft(
      id: const Uuid().v4(),
      templateKey: const Uuid().v4(),
      name: sw.name,
      description: sw.description,
      estimatedDurationMinutes: sw.estimatedDurationMinutes,
      exercises: exercises,
    );
  }
}
