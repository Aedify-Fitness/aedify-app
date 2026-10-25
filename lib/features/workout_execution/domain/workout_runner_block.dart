import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';

/// A single exercise or a superset group of exercises being executed together.
class WorkoutRunnerBlock {
  const WorkoutRunnerBlock({required this.members});

  final List<WorkoutRunnerExerciseItem> members;

  bool get isSuperset => members.length > 1;
}

/// A set paired with the session exercise it belongs to inside a runner block.
class WorkoutRunnerBlockSet {
  const WorkoutRunnerBlockSet({required this.exercise, required this.set});

  final WorkoutRunnerExerciseItem exercise;
  final WorkoutRunnerSetItem set;
}

/// Pure helpers for resolving execution blocks and superset round ordering.
class WorkoutRunnerBlockResolver {
  const WorkoutRunnerBlockResolver();

  /// First exercise (in session order) that still has an incomplete set.
  WorkoutRunnerExerciseItem? firstIncompleteExercise(
    List<WorkoutRunnerExerciseItem> exercises,
  ) {
    for (final exercise in exercises) {
      if (_firstIncompleteSet(exercise.sets) != null) return exercise;
    }
    return null;
  }

  /// The execution block containing [lead], ordered by superset position.
  WorkoutRunnerBlock blockFor(
    List<WorkoutRunnerExerciseItem> exercises,
    WorkoutRunnerExerciseItem lead,
  ) {
    final groupId = lead.supersetGroupId;
    if (groupId == null) return WorkoutRunnerBlock(members: [lead]);
    final members = exercises
        .where((exercise) => exercise.supersetGroupId == groupId)
        .toList();
    members.sort((a, b) {
      final order = (a.supersetOrder ?? a.sortOrder).compareTo(
        b.supersetOrder ?? b.sortOrder,
      );
      return order != 0 ? order : a.sortOrder.compareTo(b.sortOrder);
    });
    return WorkoutRunnerBlock(members: members);
  }

  /// First incomplete (exercise, set) in warmup-then-round-major order.
  WorkoutRunnerBlockSet? firstIncompleteSet(WorkoutRunnerBlock block) {
    for (final row in orderedSets(block)) {
      if (!row.set.completed && !row.set.skipped) return row;
    }
    return null;
  }

  /// All sets in the display and execution order used by runner blocks.
  List<WorkoutRunnerBlockSet> orderedSets(WorkoutRunnerBlock block) {
    final rows = <WorkoutRunnerBlockSet>[];
    for (var round = 0; round < maxWarmupRounds(block); round++) {
      rows.addAll(warmupRoundSets(block, round));
    }
    for (var round = 0; round < maxWorkingRounds(block); round++) {
      rows.addAll(workingRoundSets(block, round));
    }
    return rows;
  }

  /// Warmup sets in a zero-based round, omitting members without that round.
  List<WorkoutRunnerBlockSet> warmupRoundSets(
    WorkoutRunnerBlock block,
    int roundIndex,
  ) => _roundSets(block, roundIndex, SetType.warmup);

  /// Working sets in a zero-based round, omitting members without that round.
  List<WorkoutRunnerBlockSet> workingRoundSets(
    WorkoutRunnerBlock block,
    int roundIndex,
  ) => _roundSets(block, roundIndex, SetType.working);

  /// Number of warmup rounds, including any asymmetric trailing rounds.
  int maxWarmupRounds(WorkoutRunnerBlock block) =>
      _maxRounds(block, SetType.warmup);

  /// Number of working rounds, including any asymmetric trailing rounds.
  int maxWorkingRounds(WorkoutRunnerBlock block) =>
      _maxRounds(block, SetType.working);

  /// Whether rest should start after logging [loggedSet] on [member].
  ///
  /// A single exercise always rests after each logged set. A superset rests
  /// only once the warmup or working round has no remaining incomplete sets,
  /// matching the "Exercise 1 -> Exercise 2 -> rest after group" flow.
  bool restAfterLog(
    WorkoutRunnerBlock block,
    WorkoutRunnerExerciseItem member,
    WorkoutRunnerSetItem loggedSet,
  ) {
    if (!block.isSuperset) return true;
    final round = roundIndex(member, loggedSet);
    for (final candidate in block.members) {
      for (final set in candidate.sets) {
        if (set.id == loggedSet.id) continue;
        if (set.completed || set.skipped) continue;
        if (set.setType == loggedSet.setType &&
            roundIndex(candidate, set) == round) {
          return false;
        }
      }
    }
    return true;
  }

  /// Zero-based round for [set] within its warmup or working sets on [member].
  int roundIndex(WorkoutRunnerExerciseItem member, WorkoutRunnerSetItem set) {
    return _setsForType(
      member,
      set.setType,
    ).indexWhere((candidate) => candidate.id == set.id);
  }

  /// One-based position of [block] among the session's superset groups.
  int blockNumber(
    List<WorkoutRunnerExerciseItem> exercises,
    WorkoutRunnerBlock block,
  ) {
    if (!block.isSuperset) return 0;
    final groupId = block.members.first.supersetGroupId;
    final seen = <String>{};
    var index = 0;
    for (final exercise in exercises) {
      final candidateGroupId = exercise.supersetGroupId;
      if (candidateGroupId == null) continue;
      if (seen.contains(candidateGroupId)) continue;
      seen.add(candidateGroupId);
      index++;
      if (candidateGroupId == groupId) return index;
    }
    return index;
  }

  /// Uppercase member letter (A, B, C...) for [member] within [block].
  String memberLetter(
    WorkoutRunnerBlock block,
    WorkoutRunnerExerciseItem member,
  ) {
    final index = block.members.indexWhere((m) => m.id == member.id);
    final safeIndex = index < 0 ? 0 : index;
    return String.fromCharCode('A'.codeUnitAt(0) + safeIndex);
  }

  /// Full display label for a set, e.g. `S1 (A)` or `W1 (A)`.
  String setLabel(
    WorkoutRunnerBlock block,
    WorkoutRunnerExerciseItem member,
    WorkoutRunnerSetItem set,
  ) {
    final prefix = set.setType == SetType.warmup
        ? AppStrings.warmupSetPrefix
        : AppStrings.workingSetPrefix;
    final number = roundIndex(member, set) + 1;
    return '$prefix$number (${memberLetter(block, member)})';
  }

  /// Short label without the member letter, e.g. `S1` or `W1`.
  String shortSetLabel(
    WorkoutRunnerExerciseItem member,
    WorkoutRunnerSetItem set,
  ) {
    final prefix = set.setType == SetType.warmup
        ? AppStrings.warmupSetPrefix
        : AppStrings.workingSetPrefix;
    final number = roundIndex(member, set) + 1;
    return '$prefix$number';
  }

  WorkoutRunnerSetItem? _firstIncompleteSet(List<WorkoutRunnerSetItem> sets) {
    for (final set in sets) {
      if (!set.completed && !set.skipped) return set;
    }
    return null;
  }

  List<WorkoutRunnerSetItem> _setsForType(
    WorkoutRunnerExerciseItem member,
    SetType type,
  ) => member.sets.where((set) => set.setType == type).toList();

  int _maxRounds(WorkoutRunnerBlock block, SetType type) {
    var max = 0;
    for (final member in block.members) {
      final count = _setsForType(member, type).length;
      if (count > max) max = count;
    }
    return max;
  }

  List<WorkoutRunnerBlockSet> _roundSets(
    WorkoutRunnerBlock block,
    int roundIndex,
    SetType type,
  ) {
    final rows = <WorkoutRunnerBlockSet>[];
    if (roundIndex < 0) return rows;
    for (final member in block.members) {
      final sets = _setsForType(member, type);
      if (roundIndex < sets.length) {
        rows.add(
          WorkoutRunnerBlockSet(exercise: member, set: sets[roundIndex]),
        );
      }
    }
    return rows;
  }
}
