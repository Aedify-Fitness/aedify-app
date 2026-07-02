import 'package:aedify/core/validation/default_draft_validation_service.dart';
import 'package:aedify/core/validation/draft_validation_code.dart';
import 'package:aedify/core/validation/validated_exercise_draft.dart';
import 'package:aedify/core/validation/validated_set_draft.dart';
import 'package:aedify/core/validation/validated_workout_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = const DefaultDraftValidationService();

  ValidatedSetDraft defaultSet({
    String id = 's1',
    SetType setType = SetType.working,
    int? repsMin,
    int? repsMax,
    double? weightKg,
    double? rpeMin,
    double? rpeMax,
    int? rir,
    int? rest,
  }) {
    return ValidatedSetDraft(
      id: id,
      setType: setType,
      prescribedRepsMin: repsMin,
      prescribedRepsMax: repsMax,
      prescribedWeightKg: weightKg,
      prescribedRpeMin: rpeMin,
      prescribedRpeMax: rpeMax,
      prescribedRir: rir,
      restSeconds: rest,
    );
  }

  ValidatedExerciseDraft exercise({
    String id = 'e1',
    String modality = 'strength',
    List<ValidatedSetDraft> sets = const [],
    String? supersetGroupId,
    int? supersetOrder,
  }) {
    return ValidatedExerciseDraft(
      id: id,
      modality: modality,
      sets: sets,
      supersetGroupId: supersetGroupId,
      supersetOrder: supersetOrder,
    );
  }

  group('DefaultDraftValidationService — workout', () {
    test('valid workout passes', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(
            sets: [
              defaultSet(repsMin: 8, repsMax: 12, weightKg: 60.0, rest: 90),
            ],
          ),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isTrue);
    });

    test('empty name invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: '',
        exercises: [
          exercise(sets: [defaultSet(repsMin: 8, weightKg: 60.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isFalse);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingName),
        isTrue,
      );
    });

    test('whitespace-only name invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: '   ',
        exercises: [
          exercise(sets: [defaultSet(repsMin: 8, weightKg: 60.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingName),
        isTrue,
      );
    });

    test('no exercises invalid', () {
      final draft = ValidatedWorkoutDraft(name: 'Push Day', exercises: []);
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isFalse);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.noExercises),
        isTrue,
      );
    });

    test('no sets invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [exercise(sets: [])],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isFalse);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.noSets),
        isTrue,
      );
    });

    test('invalid reps min < 1', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(repsMin: 0, weightKg: 60.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRepsMin),
        isTrue,
      );
    });

    test('invalid reps max < 1', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(repsMax: -1, weightKg: 60.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRepsMax),
        isTrue,
      );
    });

    test('invalid reps exact < 1', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(
            sets: [
              ValidatedSetDraft(
                id: 's1',
                setType: SetType.working,
                prescribedRepsExact: 0,
                prescribedWeightKg: 60.0,
              ),
            ],
          ),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any(
          (i) => i.code == DraftValidationCode.invalidRepsExact,
        ),
        isTrue,
      );
    });

    test(
      'missing weight on strength working set is valid when not prescribed',
      () {
        final draft = ValidatedWorkoutDraft(
          name: 'Push Day',
          exercises: [
            exercise(sets: [defaultSet(weightKg: null)]),
          ],
        );
        final result = service.validateWorkoutDraft(draft);
        expect(
          result.issues.any((i) => i.code == DraftValidationCode.invalidWeight),
          isFalse,
        );
      },
    );

    test('negative weight invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: -5.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidWeight),
        isTrue,
      );
    });

    test('bodyweight set without weight passes', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Bodyweight Day',
        exercises: [
          exercise(modality: 'bodyweight', sets: [defaultSet(weightKg: null)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isTrue);
    });

    test('cardio set without weight passes', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Cardio Day',
        exercises: [
          exercise(modality: 'cardio', sets: [defaultSet(weightKg: null)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isTrue);
    });

    test('invalid RPE min < 1', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: 60.0, rpeMin: 0.5)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRpeMin),
        isTrue,
      );
    });

    test('invalid RPE max > 10', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: 60.0, rpeMax: 11)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRpeMax),
        isTrue,
      );
    });

    test('RPE min > RPE max invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: 60.0, rpeMin: 9, rpeMax: 7)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.rpeRange),
        isTrue,
      );
    });

    test('valid RPE range passes', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(
            sets: [
              defaultSet(weightKg: 60.0, rpeMin: 7, rpeMax: 9, repsMin: 8),
            ],
          ),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.rpeRange),
        isFalse,
      );
    });

    test('negative RIR invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: 60.0, rir: -1)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRir),
        isTrue,
      );
    });

    test('negative rest invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Push Day',
        exercises: [
          exercise(sets: [defaultSet(weightKg: 60.0, rest: -30)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidRest),
        isTrue,
      );
    });

    test('superset with single member invalid', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Superset Day',
        exercises: [
          exercise(
            id: 'e1',
            supersetGroupId: 'g1',
            supersetOrder: 0,
            sets: [defaultSet(weightKg: 60.0)],
          ),
          exercise(id: 'e2', sets: [defaultSet(weightKg: 30.0)]),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidSuperset),
        isTrue,
      );
    });

    test('warm-up structure passes validation', () {
      final draft = ValidatedWorkoutDraft(
        name: 'Warmup Day',
        exercises: [
          exercise(
            sets: [
              defaultSet(
                id: 'w1',
                setType: SetType.warmup,
                weightKg: 40.0,
                repsMin: 10,
              ),
              defaultSet(
                id: 's1',
                setType: SetType.working,
                weightKg: 60.0,
                repsMin: 8,
              ),
            ],
          ),
        ],
      );
      final result = service.validateWorkoutDraft(draft);
      expect(result.isValid, isTrue);
    });
  });
}
