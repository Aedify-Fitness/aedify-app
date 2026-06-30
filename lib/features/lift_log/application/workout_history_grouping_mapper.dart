import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';

class WorkoutHistoryGroupingMapper {
  const WorkoutHistoryGroupingMapper();

  List<SupersetGroupSummary> buildGroups(
    List<WorkoutHistoryExerciseItem> exercises,
  ) {
    final groups = <String, List<WorkoutHistoryExerciseItem>>{};
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

  List<WorkoutHistoryExerciseItem> orderedForDisplay(
    List<WorkoutHistoryExerciseItem> exercises,
  ) {
    final groups = buildGroups(exercises);
    final groupedIds = <String>{};
    for (final g in groups) {
      groupedIds.addAll(g.memberIds);
    }

    final result = <WorkoutHistoryExerciseItem>[];
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
