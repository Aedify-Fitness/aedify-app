import 'package:aedify/features/lift_log/application/workout_history_grouping_mapper.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutHistoryGroupingMapper', () {
    final mapper = const WorkoutHistoryGroupingMapper();

    WorkoutHistoryExerciseItem ex(String id, String? gid, int? order) {
      return WorkoutHistoryExerciseItem(
        id: id,
        exerciseId: 1,
        exerciseName: 'Test $id',
        sortOrder: 0,
        sets: [],
        supersetGroupId: gid,
        supersetOrder: order,
      );
    }

    test('buildGroups returns empty when no groups', () {
      final exercises = [ex('e1', null, null), ex('e2', null, null)];
      expect(mapper.buildGroups(exercises), isEmpty);
    });

    test('buildGroups detects groups correctly', () {
      final exercises = [ex('e1', 'g1', 0), ex('e2', 'g1', 1)];

      final groups = mapper.buildGroups(exercises);
      expect(groups.length, 1);
      expect(groups.first.groupId, 'g1');
      expect(groups.first.memberIds, ['e1', 'e2']);
    });

    test('orderedForDisplay preserves grouping context', () {
      final exercises = [
        ex('e1', null, null),
        ex('e2', 'g1', 0),
        ex('e3', 'g1', 1),
      ];

      final ordered = mapper.orderedForDisplay(exercises);
      final ids = ordered.map((e) => e.id).toList();

      expect(ids[0], 'e1');
      expect(ids[1], 'e2');
      expect(ids[2], 'e3');
    });
  });
}
