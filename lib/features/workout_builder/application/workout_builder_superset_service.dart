import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';

class WorkoutBuilderSupersetService {
  const WorkoutBuilderSupersetService();

  List<WorkoutBuilderExerciseDraft> createSuperset({
    required List<WorkoutBuilderExerciseDraft> exercises,
    required List<String> selectedExerciseIds,
    required String groupId,
  }) {
    if (selectedExerciseIds.length < 2) return exercises;

    final selectedSet = selectedExerciseIds.toSet();
    return exercises.map((e) {
      if (!selectedSet.contains(e.id)) return e;
      final order = selectedExerciseIds.indexOf(e.id);
      return e.copyWith(
        supersetGroupId: e.supersetGroupId ?? groupId,
        supersetOrder: order >= 0 ? order : 0,
      );
    }).toList();
  }

  List<WorkoutBuilderExerciseDraft> removeExerciseFromSuperset({
    required List<WorkoutBuilderExerciseDraft> exercises,
    required String exerciseId,
  }) {
    final target = exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => exercises.first,
    );
    final groupId = target.supersetGroupId;
    if (groupId == null) return exercises;

    final updated = exercises.map((e) {
      if (e.id == exerciseId) {
        return _clearSupersetFields(e);
      }
      return e;
    }).toList();

    return _renumberGroup(updated, groupId);
  }

  List<WorkoutBuilderExerciseDraft> deleteSupersetGroup({
    required List<WorkoutBuilderExerciseDraft> exercises,
    required String groupId,
  }) {
    return exercises.map((e) {
      if (e.supersetGroupId != groupId) return e;
      return _clearSupersetFields(e);
    }).toList();
  }

  List<WorkoutBuilderExerciseDraft> reorderWithinSuperset({
    required List<WorkoutBuilderExerciseDraft> exercises,
    required String groupId,
    required String exerciseId,
    required int newOrder,
  }) {
    final memberIds = exercises
        .where((e) => e.supersetGroupId == groupId)
        .map((e) => e.id)
        .toList();
    if (memberIds.length < 2) return exercises;

    final idx = memberIds.indexOf(exerciseId);
    if (idx == -1) return exercises;

    memberIds.removeAt(idx);
    final clamped = newOrder.clamp(0, memberIds.length);
    memberIds.insert(clamped, exerciseId);

    return exercises.map((e) {
      final pos = memberIds.indexOf(e.id);
      if (pos == -1) return e;
      return e.copyWith(supersetOrder: pos);
    }).toList();
  }

  WorkoutBuilderExerciseDraft _clearSupersetFields(
    WorkoutBuilderExerciseDraft e,
  ) {
    return WorkoutBuilderExerciseDraft(
      id: e.id,
      exercise: e.exercise,
      sortOrder: e.sortOrder,
      sets: e.sets,
      supersetGroupId: null,
      supersetOrder: null,
      exerciseRole: e.exerciseRole,
      notes: e.notes,
    );
  }

  List<WorkoutBuilderExerciseDraft> _renumberGroup(
    List<WorkoutBuilderExerciseDraft> exercises,
    String groupId,
  ) {
    final members = exercises
        .where((e) => e.supersetGroupId == groupId)
        .toList();
    if (members.length < 2) {
      return exercises.map((e) {
        if (e.supersetGroupId != groupId) return e;
        return _clearSupersetFields(e);
      }).toList();
    }

    var order = 0;
    return exercises.map((e) {
      if (e.supersetGroupId != groupId) return e;
      return e.copyWith(supersetOrder: order++);
    }).toList();
  }
}
