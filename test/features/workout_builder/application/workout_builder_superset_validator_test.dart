import 'package:aedify/features/workout_builder/application/workout_builder_superset_validator.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutBuilderSupersetValidator', () {
    final validator = const WorkoutBuilderSupersetValidator();

    WorkoutBuilderExerciseDraft ex(String id, String? gid, int? order) {
      return WorkoutBuilderExerciseDraft(
        id: id,
        exercise: const ExerciseReference(
          exerciseId: 1,
          name: 'Test',
          modality: 'strength',
        ),
        sortOrder: 0,
        sets: [
          SetPrescriptionDraft(id: 's1', setIndex: 0, setType: SetType.working),
        ],
        supersetGroupId: gid,
        supersetOrder: order,
      );
    }

    test(
      'isValidGroup returns true for valid group with sequential orders',
      () {
        final exercises = [
          ex('e1', 'g1', 0),
          ex('e2', 'g1', 1),
          ex('e3', null, null),
        ];
        expect(validator.isValidGroup(exercises, 'g1'), isTrue);
      },
    );

    test('isValidGroup returns false for fewer than 2 members', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', null, null)];
      expect(validator.isValidGroup(exercises, 'g1'), isFalse);
    });

    test('isValidGroup returns false for non-sequential orders', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 5)];
      expect(validator.isValidGroup(exercises, 'g1'), isFalse);
    });

    test('hasSequentialOrders returns true for 0,1,2', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', 'g1', 2),
      ];
      expect(validator.hasSequentialOrders(exercises, 'g1'), isTrue);
    });

    test('hasSequentialOrders returns false for gaps', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 3)];
      expect(validator.hasSequentialOrders(exercises, 'g1'), isFalse);
    });

    test('isValidGroup returns false for empty group', () {
      final exercises = [ex('e1', null, null), ex('e2', null, null)];
      expect(validator.isValidGroup(exercises, 'g1'), isFalse);
    });
  });
}
