import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';

class WorkoutBuilderSupersetValidator {
  const WorkoutBuilderSupersetValidator();

  bool isValidGroup(
    List<WorkoutBuilderExerciseDraft> exercises,
    String groupId,
  ) {
    final members = exercises
        .where((e) => e.supersetGroupId == groupId)
        .toList();
    return members.length >= 2 && hasSequentialOrders(exercises, groupId);
  }

  bool hasSequentialOrders(
    List<WorkoutBuilderExerciseDraft> exercises,
    String groupId,
  ) {
    final orders = exercises
        .where((e) => e.supersetGroupId == groupId)
        .map((e) => e.supersetOrder)
        .whereType<int>()
        .toList();
    if (orders.isEmpty) return false;
    orders.sort();
    for (var i = 0; i < orders.length; i++) {
      if (orders[i] != i) return false;
    }
    return true;
  }

  bool allMembersBelongToSameWorkout(
    List<WorkoutBuilderExerciseDraft> exercises,
    String groupId,
  ) {
    final members = exercises
        .where((e) => e.supersetGroupId == groupId)
        .toList();
    if (members.length < 2) return false;
    return members.length ==
        exercises.where((e) => e.id == members.first.id).length + 1;
  }
}
