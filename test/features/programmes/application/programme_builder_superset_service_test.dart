import 'package:aedify/features/programmes/application/programme_builder_superset_service.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgrammeBuilderSupersetService', () {
    final service = const ProgrammeBuilderSupersetService();

    ProgrammeExerciseDraft ex(String id, String? gid, int? order) {
      return ProgrammeExerciseDraft(
        id: id,
        exerciseId: 1,
        sortOrder: 0,
        sets: [
          SetPrescriptionDraft(id: 's1', setIndex: 0, setType: SetType.working),
        ],
        supersetGroupId: gid,
        supersetOrder: order,
      );
    }

    test('createSuperset assigns groupId and orders', () {
      final exercises = [ex('e1', null, null), ex('e2', null, null)];
      final result = service.createSuperset(
        exercises: exercises,
        selectedExerciseIds: ['e1', 'e2'],
        groupId: 'g1',
      );

      expect(result.firstWhere((e) => e.id == 'e1').supersetGroupId, 'g1');
      expect(result.firstWhere((e) => e.id == 'e1').supersetOrder, 0);
      expect(result.firstWhere((e) => e.id == 'e2').supersetGroupId, 'g1');
      expect(result.firstWhere((e) => e.id == 'e2').supersetOrder, 1);
    });

    test('deleteSupersetGroup clears group fields', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 1)];
      final result = service.deleteSupersetGroup(
        exercises: exercises,
        groupId: 'g1',
      );

      for (final e in result) {
        expect(e.supersetGroupId, isNull);
        expect(e.supersetOrder, isNull);
      }
    });
  });
}
