import 'package:aedify/features/workout_builder/application/workout_builder_validator.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_validation_adapter.dart';
import 'package:aedify/core/validation/default_draft_validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutBuilderValidator', () {
    late WorkoutBuilderValidator validator;

    setUp(() {
      validator = WorkoutBuilderValidator(
        validationService: const DefaultDraftValidationService(),
        adapter: const WorkoutBuilderValidationAdapter(),
      );
    });

    WorkoutBuilderExerciseDraft exercise({
      String id = 'ex1',
      int sortOrder = 0,
      List<SetPrescriptionDraft> sets = const [],
    }) {
      return WorkoutBuilderExerciseDraft(
        id: id,
        exercise: const ExerciseReference(
          exerciseId: 1,
          name: 'Bench Press',
          modality: 'strength',
        ),
        sortOrder: sortOrder,
        sets: sets,
      );
    }

    SetPrescriptionDraft set({
      String id = 's1',
      int setIndex = 0,
      SetType setType = SetType.working,
      int? prescribedRepsMin,
      int? prescribedRepsMax,
      int? prescribedRepsExact,
      double? prescribedWeightKg,
      double? prescribedRpeMin,
      double? prescribedRpeMax,
      int? prescribedRir,
      int? restSeconds,
    }) {
      return SetPrescriptionDraft(
        id: id,
        setIndex: setIndex,
        setType: setType,
        prescribedRepsMin: prescribedRepsMin,
        prescribedRepsMax: prescribedRepsMax,
        prescribedRepsExact: prescribedRepsExact,
        prescribedWeightKg: prescribedWeightKg,
        prescribedRpeMin: prescribedRpeMin,
        prescribedRpeMax: prescribedRpeMax,
        prescribedRir: prescribedRir,
        restSeconds: restSeconds,
      );
    }

    WorkoutBuilderDraft validDraft() {
      return WorkoutBuilderDraft(
        id: 'w1',
        name: 'My Workout',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0)]),
        ],
      );
    }

    test('returns no errors for a valid draft', () {
      final draft = validDraft();
      final errors = validator.validate(draft);
      expect(errors, isEmpty);
    });

    test('returns error when name is empty', () {
      final draft = validDraft().copyWith(name: '');
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'missing_name'), isTrue);
    });

    test('returns error when name is whitespace only', () {
      final draft = validDraft().copyWith(name: '   ');
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'missing_name'), isTrue);
    });

    test('returns error when no exercises added', () {
      final draft = validDraft().copyWith(exercises: []);
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'no_exercises'), isTrue);
    });

    test('returns error when an exercise has no sets', () {
      final draft = validDraft().copyWith(exercises: [exercise(sets: [])]);
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'no_sets'), isTrue);
    });

    test('returns error when min reps < 1', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRepsMin: 0)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_reps_min'), isTrue);
    });

    test('passes when min reps is 1', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRepsMin: 1)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_reps_min'), isFalse);
    });

    test('returns error when max reps < 1', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRepsMax: 0)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_reps_max'), isTrue);
    });

    test('returns error when exact reps < 1', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(
            sets: [set(prescribedWeightKg: 50.0, prescribedRepsExact: 0)],
          ),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_reps_exact'), isTrue);
    });

    test(
      'allows missing weight for working sets when weight is not prescribed',
      () {
        final draft = validDraft().copyWith(
          exercises: [
            exercise(
              sets: [set(setType: SetType.working, prescribedWeightKg: null)],
            ),
          ],
        );
        final errors = validator.validate(draft);
        expect(errors.any((e) => e.code == 'invalid_weight'), isFalse);
      },
    );

    test('skips weight validation for bodyweight modality', () {
      final draft = WorkoutBuilderDraft(
        id: 'w1',
        name: 'BW Workout',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          WorkoutBuilderExerciseDraft(
            id: 'ex1',
            exercise: const ExerciseReference(
              exerciseId: 2,
              name: 'Push-up',
              modality: 'bodyweight',
            ),
            sortOrder: 0,
            sets: [set(setType: SetType.working, prescribedWeightKg: null)],
          ),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_weight'), isFalse);
    });

    test('returns error when RPE min < 1', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRpeMin: 0)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_rpe_min'), isTrue);
    });

    test('returns error when RPE max > 10', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRpeMax: 11)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_rpe_max'), isTrue);
    });

    test('returns error when RPE min > RPE max', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(
            sets: [
              set(
                prescribedWeightKg: 50.0,
                prescribedRpeMin: 8,
                prescribedRpeMax: 5,
              ),
            ],
          ),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'rpe_range'), isTrue);
    });

    test('returns error when RIR is negative', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, prescribedRir: -1)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_rir'), isTrue);
    });

    test('returns error when rest is negative', () {
      final draft = validDraft().copyWith(
        exercises: [
          exercise(sets: [set(prescribedWeightKg: 50.0, restSeconds: -1)]),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'invalid_rest'), isTrue);
    });

    test('returns multiple errors for a completely invalid draft', () {
      final draft = WorkoutBuilderDraft(
        id: 'w1',
        name: '',
        source: WorkoutSource.manual,
        creationMethod: CreationMethod.manual,
        status: SavedWorkoutStatus.active,
        goalTags: [],
        equipment: [],
        exercises: [
          exercise(
            sets: [
              set(
                prescribedRepsMin: 0,
                prescribedRpeMin: 0,
                prescribedWeightKg: -1,
              ),
            ],
          ),
        ],
      );
      final errors = validator.validate(draft);
      expect(errors.any((e) => e.code == 'missing_name'), isTrue);
      expect(errors.any((e) => e.code == 'invalid_reps_min'), isTrue);
      expect(errors.any((e) => e.code == 'invalid_weight'), isTrue);
    });
  });
}
