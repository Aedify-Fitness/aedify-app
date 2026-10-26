import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';

class WorkoutHistoryDetailState {
  const WorkoutHistoryDetailState({
    required this.item,
    required this.isLoading,
    this.errorCode,
    this.errorMessage,
  });

  final WorkoutHistoryDetailViewData? item;
  final bool isLoading;
  final String? errorCode;
  final String? errorMessage;

  bool get isEmpty => item == null && !isLoading && errorCode == null;
}
