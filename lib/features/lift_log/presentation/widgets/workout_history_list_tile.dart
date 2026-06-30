import 'package:flutter/material.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutHistoryListTile extends StatelessWidget {
  const WorkoutHistoryListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final WorkoutHistoryListItem item;
  final VoidCallback onTap;

  String _sourceLabel() {
    return switch (item.source) {
      SessionSource.program => AppStrings.sourceProgramme,
      SessionSource.savedWorkout => AppStrings.sourceSavedWorkout,
      SessionSource.standalone => AppStrings.sourceStandalone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sourceLabel = _sourceLabel();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(
          '$sourceLabel \u2022 ${item.exerciseCount} ${AppStrings.historyExerciseList.toLowerCase()}',
        ),
        trailing: Text(
          _formatDuration(item.durationSeconds),
          style: context.textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '';
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }
}
