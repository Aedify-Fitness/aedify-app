import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';

extension WorkoutRunnerSetItemX on WorkoutRunnerSetItem {
  bool get isWarmup => setType == SetType.warmup;

  bool get isWorking => setType == SetType.working;

  WorkoutRunnerSetItem withSetType(SetType setType) {
    return copyWith(setType: setType);
  }
}
