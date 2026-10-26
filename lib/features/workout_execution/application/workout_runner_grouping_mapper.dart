import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';

class WorkoutRunnerGroupingMapper {
  const WorkoutRunnerGroupingMapper();

  List<SupersetGroupSummary> buildGroups(
    List<WorkoutRunnerExerciseItem> exercises,
  ) {
    final groups = <String, List<WorkoutRunnerExerciseItem>>{};
    for (final ex in exercises) {
      final gid = ex.supersetGroupId;
      if (gid == null) continue;
      groups.putIfAbsent(gid, () => []).add(ex);
    }

    return groups.entries.map((entry) {
      final sorted = [
        ...entry.value,
      ]..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));
      return SupersetGroupSummary(
        groupId: entry.key,
        memberIds: sorted.map((e) => e.id).toList(),
        memberCount: sorted.length,
      );
    }).toList();
  }

  List<WorkoutRunnerExerciseItem> orderedForDisplay(
    List<WorkoutRunnerExerciseItem> exercises,
  ) {
    final groups = buildGroups(exercises);
    final groupedIds = <String>{};
    for (final g in groups) {
      groupedIds.addAll(g.memberIds);
    }

    final result = <WorkoutRunnerExerciseItem>[];
    final seenGroups = <String>{};
    for (final ex in exercises) {
      if (groupedIds.contains(ex.id)) {
        final gid = ex.supersetGroupId!;
        if (!seenGroups.contains(gid)) {
          seenGroups.add(gid);
          final group = groups.firstWhere((g) => g.groupId == gid);
          for (final mid in group.memberIds) {
            final member = exercises.firstWhere((e) => e.id == mid);
            result.add(member);
          }
        }
      } else {
        result.add(ex);
      }
    }
    return result;
  }
}
