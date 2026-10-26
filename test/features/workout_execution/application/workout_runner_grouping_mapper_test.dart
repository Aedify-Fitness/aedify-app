import 'package:aedify/features/workout_execution/application/workout_runner_grouping_mapper.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutRunnerGroupingMapper', () {
    final mapper = const WorkoutRunnerGroupingMapper();

    WorkoutRunnerExerciseItem ex(String id, String? gid, int? order) {
      return WorkoutRunnerExerciseItem(
        id: id,
        exerciseId: 1,
        exerciseName: 'Test $id',
        sortOrder: 0,
        sets: [],
        supersetGroupId: gid,
        supersetOrder: order,
      );
    }

    test('buildGroups returns empty when no groups exist', () {
      final exercises = [ex('e1', null, null), ex('e2', null, null)];
      expect(mapper.buildGroups(exercises), isEmpty);
    });

    test('buildGroups detects single group with two members', () {
      final exercises = [
        ex('e1', 'g1', 0),
        ex('e2', 'g1', 1),
        ex('e3', null, null),
      ];

      final groups = mapper.buildGroups(exercises);
      expect(groups.length, 1);
      expect(groups.first.groupId, 'g1');
      expect(groups.first.memberCount, 2);
      expect(groups.first.memberIds, ['e1', 'e2']);
    });

    test('buildGroups sorts members by supersetOrder', () {
      final exercises = [
        ex('e1', 'g1', 2),
        ex('e2', 'g1', 0),
        ex('e3', 'g1', 1),
      ];

      final groups = mapper.buildGroups(exercises);
      expect(groups.first.memberIds, ['e2', 'e3', 'e1']);
    });

    test('orderedForDisplay keeps groups together', () {
      final exercises = [
        ex('e1', null, null),
        ex('e2', 'g1', 0),
        ex('e3', 'g1', 1),
        ex('e4', null, null),
      ];

      final ordered = mapper.orderedForDisplay(exercises);
      final ids = ordered.map((e) => e.id).toList();

      expect(ids[0], 'e1');
      expect(ids[1], 'e2');
      expect(ids[2], 'e3');
      expect(ids[3], 'e4');
    });
  });
}
