import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutRunnerBlockResolver', () {
    const resolver = WorkoutRunnerBlockResolver();
    final now = DateTime(2026, 8, 22, 10);

    WorkoutRunnerSetItem set(
      String id, {
      required int exerciseId,
      required int index,
      SetType setType = SetType.working,
      bool completed = false,
      bool skipped = false,
    }) {
      return WorkoutRunnerSetItem(
        id: id,
        exerciseId: exerciseId,
        setIndex: index,
        setType: setType,
        performedAt: now,
        completed: completed,
        skipped: skipped,
        prescribedRepsExact: 8,
        prescribedWeightKg: 80,
      );
    }

    WorkoutRunnerExerciseItem exercise(
      String id, {
      required int exerciseId,
      required int order,
      required List<WorkoutRunnerSetItem> sets,
    }) {
      return WorkoutRunnerExerciseItem(
        id: id,
        exerciseId: exerciseId,
        exerciseName: id,
        sortOrder: order,
        supersetGroupId: 'group-1',
        supersetOrder: order,
        sets: sets,
      );
    }

    test('pairs warmup and working rounds in member order', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set('bench-w1', exerciseId: 1, index: 0, setType: SetType.warmup),
          set('bench-w2', exerciseId: 1, index: 1, setType: SetType.warmup),
          set('bench-s1', exerciseId: 1, index: 2),
          set('bench-s2', exerciseId: 1, index: 3),
        ],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [
          set('fly-w1', exerciseId: 2, index: 0, setType: SetType.warmup),
          set('fly-w2', exerciseId: 2, index: 1, setType: SetType.warmup),
          set('fly-s1', exerciseId: 2, index: 2),
          set('fly-s2', exerciseId: 2, index: 3),
        ],
      );

      final block = resolver.blockFor([first, second], first);
      final rows = resolver.orderedSets(block);

      expect(rows.map((row) => row.set.id), [
        'bench-w1',
        'fly-w1',
        'bench-w2',
        'fly-w2',
        'bench-s1',
        'fly-s1',
        'bench-s2',
        'fly-s2',
      ]);
      expect(
        rows.map((row) => resolver.setLabel(block, row.exercise, row.set)),
        [
          'W1 (A)',
          'W1 (B)',
          'W2 (A)',
          'W2 (B)',
          'S1 (A)',
          'S1 (B)',
          'S2 (A)',
          'S2 (B)',
        ],
      );
      expect(resolver.maxWarmupRounds(block), 2);
      expect(resolver.maxWorkingRounds(block), 2);
    });

    test('preserves unequal warmup and working counts without adding sets', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set('bench-w1', exerciseId: 1, index: 0, setType: SetType.warmup),
          set('bench-w2', exerciseId: 1, index: 1, setType: SetType.warmup),
          set('bench-s1', exerciseId: 1, index: 2),
        ],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [
          set('fly-w1', exerciseId: 2, index: 0, setType: SetType.warmup),
          set('fly-s1', exerciseId: 2, index: 1),
          set('fly-s2', exerciseId: 2, index: 2),
        ],
      );
      final block = resolver.blockFor([second, first], second);

      expect(resolver.orderedSets(block).map((row) => row.set.id), [
        'bench-w1',
        'fly-w1',
        'bench-w2',
        'bench-s1',
        'fly-s1',
        'fly-s2',
      ]);
      expect(resolver.warmupRoundSets(block, 1).single.set.id, 'bench-w2');
      expect(resolver.workingRoundSets(block, 1).single.set.id, 'fly-s2');
      expect(resolver.warmupRoundSets(block, 2), isEmpty);
      expect(resolver.workingRoundSets(block, -1), isEmpty);
    });

    test('selects the next unresolved member before the next warmup round', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set(
            'bench-w1',
            exerciseId: 1,
            index: 0,
            setType: SetType.warmup,
            completed: true,
          ),
          set('bench-w2', exerciseId: 1, index: 1, setType: SetType.warmup),
          set('bench-s1', exerciseId: 1, index: 2),
        ],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [
          set('fly-w1', exerciseId: 2, index: 0, setType: SetType.warmup),
          set('fly-s1', exerciseId: 2, index: 1),
        ],
      );
      final block = resolver.blockFor([first, second], first);

      expect(resolver.firstIncompleteSet(block)?.set.id, 'fly-w1');

      final skippedSecond = second.copyWith(
        sets: [second.sets.first.copyWith(skipped: true), second.sets.last],
      );
      final skippedBlock = resolver.blockFor([first, skippedSecond], first);
      expect(resolver.firstIncompleteSet(skippedBlock)?.set.id, 'bench-w2');

      final warmedUpFirst = first.copyWith(
        sets: [
          first.sets[0],
          first.sets[1].copyWith(completed: true),
          first.sets[2],
        ],
      );
      final workingBlock = resolver.blockFor([
        warmedUpFirst,
        skippedSecond,
      ], warmedUpFirst);
      expect(resolver.firstIncompleteSet(workingBlock)?.set.id, 'bench-s1');
    });

    test('rests only after the current superset round is resolved', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [set('bench-s1', exerciseId: 1, index: 0)],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [set('fly-s1', exerciseId: 2, index: 0)],
      );
      final block = resolver.blockFor([first, second], first);

      expect(resolver.restAfterLog(block, first, first.sets.single), isFalse);

      final completedFirst = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [set('bench-s1', exerciseId: 1, index: 0, completed: true)],
      );
      final updatedBlock = resolver.blockFor([completedFirst, second], second);

      expect(
        resolver.restAfterLog(updatedBlock, second, second.sets.single),
        isTrue,
      );
    });

    test('rests after each warmup pair without waiting for later rounds', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set('bench-w1', exerciseId: 1, index: 0, setType: SetType.warmup),
          set('bench-w2', exerciseId: 1, index: 1, setType: SetType.warmup),
          set('bench-s1', exerciseId: 1, index: 2),
        ],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [
          set('fly-w1', exerciseId: 2, index: 0, setType: SetType.warmup),
          set('fly-s1', exerciseId: 2, index: 1),
        ],
      );
      final block = resolver.blockFor([first, second], first);

      expect(resolver.restAfterLog(block, first, first.sets.first), isFalse);
      final completedFirst = first.copyWith(
        sets: [
          first.sets.first.copyWith(completed: true),
          ...first.sets.skip(1),
        ],
      );
      final updatedBlock = resolver.blockFor([completedFirst, second], second);

      expect(
        resolver.restAfterLog(updatedBlock, second, second.sets.first),
        isTrue,
      );
      expect(
        resolver.restAfterLog(updatedBlock, completedFirst, first.sets[1]),
        isTrue,
      );
    });

    test('skipped members resolve a warmup round and all sets can resolve', () {
      final first = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set(
            'bench-w1',
            exerciseId: 1,
            index: 0,
            setType: SetType.warmup,
            skipped: true,
          ),
        ],
      );
      final second = exercise(
        'fly',
        exerciseId: 2,
        order: 1,
        sets: [set('fly-w1', exerciseId: 2, index: 0, setType: SetType.warmup)],
      );
      final block = resolver.blockFor([first, second], second);

      expect(resolver.restAfterLog(block, second, second.sets.single), isTrue);
      final completedSecond = second.copyWith(
        sets: [second.sets.single.copyWith(completed: true)],
      );
      expect(
        resolver.firstIncompleteSet(
          resolver.blockFor([first, completedSecond], completedSecond),
        ),
        isNull,
      );
    });

    test('single exercises rest after warmup and working sets', () {
      final member = exercise(
        'bench',
        exerciseId: 1,
        order: 0,
        sets: [
          set('bench-w1', exerciseId: 1, index: 0, setType: SetType.warmup),
          set('bench-s1', exerciseId: 1, index: 1),
        ],
      );
      final block = WorkoutRunnerBlock(members: [member]);

      for (final row in member.sets) {
        expect(resolver.restAfterLog(block, member, row), isTrue);
        expect(resolver.roundIndex(member, row), 0);
      }
      expect(resolver.shortSetLabel(member, member.sets[0]), 'W1');
      expect(resolver.shortSetLabel(member, member.sets[1]), 'S1');
    });
  });
}
