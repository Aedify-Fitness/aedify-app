import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_validator.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomExerciseValidator', () {
    const validator = CustomExerciseValidator();

    CustomExerciseDraft validDraft() {
      return const CustomExerciseDraft(
        name: 'Bulgarian Split Squat',
        muscleGroups: {BodymapBucket.quads, BodymapBucket.glutes},
        modality: ExerciseModality.strength,
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
      expect(
        errors.any((e) => e.code == AppErrorCodes.customExerciseNameRequired),
        isTrue,
      );
      expect(
        errors.any((e) => e.scope == CustomExerciseValidationScope.name),
        isTrue,
      );
    });

    test('returns error when name is whitespace only', () {
      final draft = validDraft().copyWith(name: '   ');
      final errors = validator.validate(draft);
      expect(
        errors.any((e) => e.code == AppErrorCodes.customExerciseNameRequired),
        isTrue,
      );
    });

    test('returns error when no muscle groups selected', () {
      final draft = validDraft().copyWith(muscleGroups: <BodymapBucket>{});
      final errors = validator.validate(draft);
      expect(
        errors.any(
          (e) => e.code == AppErrorCodes.customExerciseMuscleGroupsRequired,
        ),
        isTrue,
      );
      expect(
        errors.any(
          (e) => e.scope == CustomExerciseValidationScope.muscleGroups,
        ),
        isTrue,
      );
    });

    test('returns error when a step is empty', () {
      final draft = validDraft().copyWith(steps: ['Set up stance', '']);
      final errors = validator.validate(draft);
      expect(
        errors.any(
          (e) =>
              e.code == AppErrorCodes.customExerciseStepEmpty &&
              e.stepIndex == 1,
        ),
        isTrue,
      );
      expect(
        errors.any((e) => e.scope == CustomExerciseValidationScope.steps),
        isTrue,
      );
    });

    test('returns no error when steps are all non-empty', () {
      final draft = validDraft().copyWith(
        steps: ['Set up', 'Lower down', 'Drive up'],
      );
      final errors = validator.validate(draft);
      expect(
        errors.any((e) => e.code == AppErrorCodes.customExerciseStepEmpty),
        isFalse,
      );
    });

    test('returns multiple errors for a completely invalid draft', () {
      final draft = const CustomExerciseDraft(
        name: '',
        muscleGroups: {},
        modality: ExerciseModality.strength,
        steps: ['', ''],
      );
      final errors = validator.validate(draft);
      expect(
        errors.any((e) => e.code == AppErrorCodes.customExerciseNameRequired),
        isTrue,
      );
      expect(
        errors.any(
          (e) => e.code == AppErrorCodes.customExerciseMuscleGroupsRequired,
        ),
        isTrue,
      );
      expect(
        errors.where((e) => e.code == AppErrorCodes.customExerciseStepEmpty),
        hasLength(2),
      );
    });

    test('passes when draft has optional fields populated', () {
      final draft = const CustomExerciseDraft(
        name: 'Band Pull-Apart',
        muscleGroups: {BodymapBucket.shoulders, BodymapBucket.back},
        modality: ExerciseModality.strength,
        steps: ['Grip band', 'Pull apart'],
      );
      final errors = validator.validate(draft);
      expect(errors, isEmpty);
    });
  });
}
