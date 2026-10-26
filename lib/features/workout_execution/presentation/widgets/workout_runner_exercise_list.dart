import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_exercise_card.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_superset_group_card.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class WorkoutRunnerExerciseList extends StatelessWidget {
  const WorkoutRunnerExerciseList({
    super.key,
    required this.exercises,
    required this.onUpdateSet,
    required this.onToggleSetCompleted,
    required this.onToggleSetSkipped,
    required this.groups,
  });

  final List<WorkoutRunnerExerciseItem> exercises;
  final void Function(String exerciseId, String setId, WorkoutRunnerSetItem set)
  onUpdateSet;
  final void Function(String exerciseId, String setId, bool completed)
  onToggleSetCompleted;
  final void Function(String exerciseId, String setId, bool skipped)
  onToggleSetSkipped;
  final List<SupersetGroupSummary> groups;

  @override
  Widget build(BuildContext context) {
    final groupedIds = <String>{};
    for (final g in groups) {
      groupedIds.addAll(g.memberIds);
    }

    final orderedExercises = <Widget>[];
    final seenGroups = <String>{};

    for (final exercise in exercises) {
      if (groupedIds.contains(exercise.id)) {
        final gid = exercise.supersetGroupId!;
        if (!seenGroups.contains(gid)) {
          seenGroups.add(gid);
          final group = groups.firstWhere((g) => g.groupId == gid);
          final groupExercises = group.memberIds
              .map((mid) => exercises.firstWhere((e) => e.id == mid))
              .toList();
          orderedExercises.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: WorkoutRunnerSupersetGroupCard(
                group: group,
                exercises: groupExercises,
                onUpdateSet: onUpdateSet,
                onToggleSetCompleted: onToggleSetCompleted,
                onToggleSetSkipped: onToggleSetSkipped,
              ),
            ),
          );
        }
      } else {
        orderedExercises.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: WorkoutRunnerExerciseCard(
              exercise: exercise,
              onUpdateSet: (setId, set) => onUpdateSet(exercise.id, setId, set),
              onToggleSetCompleted: (setId, completed) =>
                  onToggleSetCompleted(exercise.id, setId, completed),
              onToggleSetSkipped: (setId, skipped) =>
                  onToggleSetSkipped(exercise.id, setId, skipped),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: orderedExercises,
    );
  }
}
