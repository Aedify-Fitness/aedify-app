import 'package:aedify/features/programmes/application/workout_draft_to_programme_template_converter.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/exercise_role.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/weight_prescription_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'keeps workout, exercise, superset and prescription data in the programme template',
    () {
      const draft = WorkoutBuilderDraft(
        id: 'template',
        name: 'Programme Push',
        description: 'Weekly template',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: ['Strength', 'Hypertrophy'],
        equipment: [],
        estimatedDurationMinutes: 45,
        restBetweenExercisesSeconds: 90,
        exercises: [
          WorkoutBuilderExerciseDraft(
            id: 'exercise',
            exercise: ExerciseReference(
              exerciseId: 42,
              name: 'Bench Press',
              modality: 'strength',
            ),
            sortOrder: 0,
            exerciseRole: ExerciseRole.primary,
            supersetGroupId: 'superset',
            supersetOrder: 1,
            notes: 'Controlled tempo',
            restBetweenExercisesSeconds: 60,
            sets: [
              SetPrescriptionDraft(
                id: 'set',
                setIndex: 0,
                setType: SetType.working,
                setIntent: SetIntent.working,
                prescribedRepsMin: 8,
                prescribedRepsMax: 12,
                prescribedRepsExact: 10,
                durationSeconds: 30,
                distanceMeters: 25,
                weightPrescriptionType: WeightPrescriptionType.absolute,
                prescribedWeightKg: 40,
                prescribedRpeMin: 7.5,
                prescribedRpeMax: 8.5,
                prescribedRir: 2,
                restSeconds: 75,
              ),
            ],
          ),
        ],
      );
      final template = const WorkoutDraftToProgrammeTemplateConverter().convert(
        draft,
      );
      expect(template.id, draft.id);
      expect(template.templateKey, draft.id);
      expect(template.name, draft.name);
      expect(template.goalTags, draft.goalTags);
      expect(template.description, draft.description);
      expect(template.estimatedDurationMinutes, 45);
      expect(template.restBetweenExercisesSeconds, 90);
      final exercise = template.exercises.single;
      expect(exercise.id, 'exercise');
      expect(exercise.exerciseId, 42);
      expect(exercise.exerciseRef, 'Bench Press');
      expect(exercise.exerciseRole, ExerciseRole.primary);
      expect(exercise.supersetGroupId, 'superset');
      expect(exercise.supersetOrder, 1);
      expect(exercise.notes, 'Controlled tempo');
      expect(exercise.restBetweenExercisesSeconds, 60);
      final set = exercise.sets.single;
      expect(set.id, 'set');
      expect(set.setIndex, 0);
      expect(set.setType, SetType.working);
      expect(set.setIntent, SetIntent.working);
      expect(set.prescribedRepsMin, 8);
      expect(set.prescribedRepsMax, 12);
      expect(set.prescribedRepsExact, 10);
      expect(set.durationSeconds, 30);
      expect(set.distanceMeters, 25);
      expect(set.weightPrescriptionType, WeightPrescriptionType.absolute);
      expect(set.prescribedWeightKg, 40);
      expect(set.prescribedRpeMin, 7.5);
      expect(set.prescribedRpeMax, 8.5);
      expect(set.prescribedRir, 2);
      expect(set.restSeconds, 75);
    },
  );
}
