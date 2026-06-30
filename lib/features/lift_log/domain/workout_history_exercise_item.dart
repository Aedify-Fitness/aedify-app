import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';

class WorkoutHistoryExerciseItem {
  const WorkoutHistoryExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
    required this.sets,
    this.supersetGroupId,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;
  final List<WorkoutHistorySetItem> sets;
  final String? supersetGroupId;
  final String? notes;
}
