import 'package:aedify/core/validation/draft_validation_code.dart';
import 'package:aedify/core/validation/draft_validation_issue.dart';
import 'package:aedify/core/validation/draft_validation_path.dart';
import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_validation_adapter.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final adapter = const WorkoutBuilderValidationAdapter();

  group('WorkoutBuilderValidationAdapter — toValidatedDraft', () {
    test('maps builder draft name and exercises', () {
      final draft = WorkoutBuilderDraft(
        id: 'w1',
        name: 'Push Day',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          WorkoutBuilderExerciseDraft(
            id: 'e1',
            exercise: const ExerciseReference(
              exerciseId: 1,
              name: 'Bench Press',
              modality: 'strength',
            ),
            sortOrder: 0,
            sets: [
              SetPrescriptionDraft(
                id: 's1',
                setIndex: 0,
                setType: SetType.working,
                prescribedRepsMin: 8,
                prescribedRepsMax: 12,
                prescribedWeightKg: 60.0,
                restSeconds: 90,
              ),
            ],
          ),
        ],
      );

      final validated = adapter.toValidatedDraft(draft);

      expect(validated.name, 'Push Day');
      expect(validated.exercises.length, 1);
      expect(validated.exercises[0].id, 'e1');
      expect(validated.exercises[0].modality, 'strength');
      expect(validated.exercises[0].sets.length, 1);
      expect(validated.exercises[0].sets[0].setType, SetType.working);
      expect(validated.exercises[0].sets[0].prescribedRepsMin, 8);
      expect(validated.exercises[0].sets[0].prescribedRepsMax, 12);
      expect(validated.exercises[0].sets[0].prescribedWeightKg, 60.0);
      expect(validated.exercises[0].sets[0].restSeconds, 90);
    });

    test('preserves superset fields', () {
      final draft = WorkoutBuilderDraft(
        id: 'w1',
        name: 'Superset',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          WorkoutBuilderExerciseDraft(
            id: 'e1',
            exercise: const ExerciseReference(
              exerciseId: 1,
              name: 'Bench',
              modality: 'strength',
            ),
            sortOrder: 0,
            sets: [
              SetPrescriptionDraft(
                id: 's1',
                setIndex: 0,
                setType: SetType.working,
              ),
            ],
            supersetGroupId: 'g1',
            supersetOrder: 0,
          ),
        ],
      );

      final validated = adapter.toValidatedDraft(draft);

      expect(validated.exercises[0].supersetGroupId, 'g1');
      expect(validated.exercises[0].supersetOrder, 0);
    });

    test('maps exercise reference id', () {
      final draft = WorkoutBuilderDraft(
        id: 'w1',
        name: 'Test',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          WorkoutBuilderExerciseDraft(
            id: 'e1',
            exercise: const ExerciseReference(
              exerciseId: 42,
              name: 'Squat',
              modality: 'strength',
            ),
            sortOrder: 0,
            sets: [
              SetPrescriptionDraft(
                id: 's1',
                setIndex: 0,
                setType: SetType.working,
              ),
            ],
          ),
        ],
      );

      final validated = adapter.toValidatedDraft(draft);
      expect(validated.exercises[0].exerciseReferenceId, 42);
    });
  });

  group('WorkoutBuilderValidationAdapter — toFeatureErrors', () {
    test('maps shared issue to feature error', () {
      final result = DraftValidationResult(
        issues: [
          DraftValidationIssue(
            scope: DraftValidationScope.exerciseSet,
            code: DraftValidationCode.invalidWeight,
            message: 'Enter a valid weight.',
            path: DraftValidationPath(exerciseId: 'e1', setId: 's1'),
          ),
          DraftValidationIssue(
            scope: DraftValidationScope.root,
            code: DraftValidationCode.missingName,
            message: 'Workout name is required.',
          ),
        ],
      );

      final errors = adapter.toFeatureErrors(result);

      expect(errors.length, 2);
      expect(errors[0].scope, WorkoutBuilderValidationScope.set);
      expect(errors[0].code, DraftValidationCode.invalidWeight);
      expect(errors[0].message, 'Enter a valid weight.');
      expect(errors[0].exerciseId, 'e1');
      expect(errors[0].setId, 's1');
      expect(errors[1].scope, WorkoutBuilderValidationScope.workout);
      expect(errors[1].code, DraftValidationCode.missingName);
    });

    test('maps exercise scope correctly', () {
      final result = DraftValidationResult(
        issues: [
          DraftValidationIssue(
            scope: DraftValidationScope.exercise,
            code: DraftValidationCode.noSets,
            message: 'Test',
            path: DraftValidationPath(exerciseId: 'e2'),
          ),
        ],
      );

      final errors = adapter.toFeatureErrors(result);
      expect(errors[0].scope, WorkoutBuilderValidationScope.exercise);
    });
  });
}
