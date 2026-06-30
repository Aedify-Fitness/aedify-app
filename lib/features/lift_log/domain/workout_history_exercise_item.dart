import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';

class WorkoutHistoryExerciseItem {
  const WorkoutHistoryExerciseItem({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
    required this.sets,
    this.supersetGroupId,
    this.supersetOrder,
    this.notes,
  });

  final String id;
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;
  final List<WorkoutHistorySetItem> sets;
  final String? supersetGroupId;
  final int? supersetOrder;
  final String? notes;

  WorkoutHistoryExerciseItem copyWith({
    String? id,
    int? exerciseId,
    String? exerciseName,
    int? sortOrder,
    List<WorkoutHistorySetItem>? sets,
    String? supersetGroupId,
    int? supersetOrder,
    String? notes,
  }) {
    return WorkoutHistoryExerciseItem(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sortOrder: sortOrder ?? this.sortOrder,
      sets: sets ?? this.sets,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      supersetOrder: supersetOrder ?? this.supersetOrder,
      notes: notes ?? this.notes,
    );
  }
}
