import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';

class WorkoutHistoryState {
  const WorkoutHistoryState({
    required this.items,
    required this.isLoading,
    this.errorCode,
    this.errorMessage,
  });

  final List<WorkoutHistoryListItem> items;
  final bool isLoading;
  final String? errorCode;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty && !isLoading && errorCode == null;
}
