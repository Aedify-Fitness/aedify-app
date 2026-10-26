import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';

class ProgrammeBuilderSupersetValidator {
  const ProgrammeBuilderSupersetValidator();

  bool isValidGroup(List<ProgrammeExerciseDraft> exercises, String groupId) {
    final members = exercises
        .where((e) => e.supersetGroupId == groupId)
        .toList();
    return members.length >= 2 && hasSequentialOrders(exercises, groupId);
  }

  bool hasSequentialOrders(
    List<ProgrammeExerciseDraft> exercises,
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
}
