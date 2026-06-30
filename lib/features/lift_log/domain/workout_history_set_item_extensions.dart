import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';

extension WorkoutHistorySetItemX on WorkoutHistorySetItem {
  bool get isWarmup => setType == SetType.warmup;

  bool get isWorking => setType == SetType.working;
}
