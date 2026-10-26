import 'package:aedify/features/workout_builder/application/workout_builder_superset_service.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutBuilderSupersetService', () {
    final service = const WorkoutBuilderSupersetService();

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

    test('createSuperset assigns groupId and sequential orders', () {
      final exercises = [
        ex('e1', null, null),
        ex('e2', null, null),
        ex('e3', null, null),
      ];
      final result = service.createSuperset(
        exercises: exercises,
        selectedExerciseIds: ['e1', 'e3'],
        groupId: 'g1',
      );

      final e1 = result.firstWhere((e) => e.id == 'e1');
      final e2 = result.firstWhere((e) => e.id == 'e2');
      final e3 = result.firstWhere((e) => e.id == 'e3');

      expect(e1.supersetGroupId, 'g1');
      expect(e1.supersetOrder, 0);
      expect(e2.supersetGroupId, isNull);
      expect(e2.supersetOrder, isNull);
      expect(e3.supersetGroupId, 'g1');
      expect(e3.supersetOrder, 1);
    });

    test('createSuperset returns unchanged for fewer than 2 selections', () {
      final exercises = [ex('e1', null, null), ex('e2', null, null)];
      final result = service.createSuperset(
        exercises: exercises,
        selectedExerciseIds: ['e1'],
        groupId: 'g1',
      );
      expect(result, equals(exercises));
    });

    test('removeExerciseFromSuperset clears group fields and renumbers', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', 'g1', 2),
      ];
      final result = service.removeExerciseFromSuperset(
        exercises: exercises,
        exerciseId: 'e2',
      );

      final e1 = result.firstWhere((e) => e.id == 'e1');
      final e2 = result.firstWhere((e) => e.id == 'e2');
      final e3 = result.firstWhere((e) => e.id == 'e3');

      expect(e1.supersetGroupId, 'g1');
      expect(e1.supersetOrder, 0);
      expect(e2.supersetGroupId, isNull);
      expect(e2.supersetOrder, isNull);
      expect(e3.supersetGroupId, 'g1');
      expect(e3.supersetOrder, 1);
    });

    test(
      'removeExerciseFromSuperset dissolves group if fewer than 2 remain',
      () {
        final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 1)];
        final result = service.removeExerciseFromSuperset(
          exercises: exercises,
          exerciseId: 'e1',
        );

        final e1 = result.firstWhere((e) => e.id == 'e1');
        final e2 = result.firstWhere((e) => e.id == 'e2');

        expect(e1.supersetGroupId, isNull);
        expect(e1.supersetOrder, isNull);
        expect(e2.supersetGroupId, isNull);
        expect(e2.supersetOrder, isNull);
      },
    );

    test('deleteSupersetGroup clears all group fields', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', null, null),
      ];
      final result = service.deleteSupersetGroup(
        exercises: exercises,
        groupId: 'g1',
      );

      final e1 = result.firstWhere((e) => e.id == 'e1');
      final e2 = result.firstWhere((e) => e.id == 'e2');
      final e3 = result.firstWhere((e) => e.id == 'e3');

      expect(e1.supersetGroupId, isNull);
      expect(e1.supersetOrder, isNull);
      expect(e2.supersetGroupId, isNull);
      expect(e2.supersetOrder, isNull);
      expect(e3.supersetGroupId, isNull);
    });

    test('reorderWithinSuperset updates order and renumbers others', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', 'g1', 2),
      ];
      final result = service.reorderWithinSuperset(
        exercises: exercises,
        groupId: 'g1',
        exerciseId: 'e1',
        newOrder: 2,
      );

      final e1 = result.firstWhere((e) => e.id == 'e1');
      final e2 = result.firstWhere((e) => e.id == 'e2');
      final e3 = result.firstWhere((e) => e.id == 'e3');

      expect(e1.supersetOrder, 2);
      expect(e2.supersetOrder, 0);
      expect(e3.supersetOrder, 1);
    });

    test('reorderWithinSuperset no-ops on non-member', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 1)];
      final result = service.reorderWithinSuperset(
        exercises: exercises,
        groupId: 'g1',
        exerciseId: 'e99',
        newOrder: 0,
      );
      expect(result, equals(exercises));
    });
  });
}
