import 'package:aedify/features/programmes/application/programme_builder_superset_validator.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgrammeBuilderSupersetValidator', () {
    final validator = const ProgrammeBuilderSupersetValidator();

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

    test('isValidGroup returns true for valid group', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 1)];
      expect(validator.isValidGroup(exercises, 'g1'), isTrue);
    });

    test('isValidGroup returns false for single member', () {
      final exercises = [ex('e1', 'g1', 0)];
      expect(validator.isValidGroup(exercises, 'g1'), isFalse);
    });

    test('hasSequentialOrders returns true for consecutive orders', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', 'g1', 2),
      ];
      expect(validator.hasSequentialOrders(exercises, 'g1'), isTrue);
    });

    test('hasSequentialOrders returns false for non-consecutive', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 2)];
      expect(validator.hasSequentialOrders(exercises, 'g1'), isFalse);
    });
  });
}
