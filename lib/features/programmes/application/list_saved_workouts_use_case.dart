import 'dart:convert';

import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';

class ListSavedWorkoutsUseCase {
  const ListSavedWorkoutsUseCase({
    required SavedWorkoutRepository savedWorkoutRepository,
    required ExerciseDao exerciseDao,
  }) : _savedWorkoutRepository = savedWorkoutRepository,
       _exerciseDao = exerciseDao;

  final SavedWorkoutRepository _savedWorkoutRepository;
  final ExerciseDao _exerciseDao;

  Future<List<SavedWorkoutListItem>> execute() async {
    final aggregates = await _savedWorkoutRepository.listSavedWorkouts();

    final allExerciseIds = <int>{};
    for (final a in aggregates) {
      for (final e in a.exercises) {
        allExerciseIds.add(e.exerciseId);
      }
    }

    final modalityById = await _exerciseDao.getModalityByIds(
      allExerciseIds.toList(),
    );

    return aggregates.map((a) {
      final uniqueModalities = <String>{};
      for (final e in a.exercises) {
        final modality = modalityById[e.exerciseId];
        if (modality != null) {
          uniqueModalities.add(modality);
        }
      }
      return SavedWorkoutListItem(
        id: a.savedWorkout.id,
        name: a.savedWorkout.name,
        status: SavedWorkoutStatus.fromDb(a.savedWorkout.status),
        exerciseCount: a.exercises.length,
        updatedAt: a.savedWorkout.updatedAt,
        description: a.savedWorkout.description,
        estimatedDurationMinutes: a.savedWorkout.estimatedDurationMinutes,
        modalities: uniqueModalities.toList(),
        focus: _formatFocus(a.savedWorkout.goalTagsJson),
      );
    }).toList();
  }

  String _formatFocus(String goalTagsJson) {
    try {
      final tags = (jsonDecode(goalTagsJson) as List).cast<String>();
      if (tags.isEmpty) return '';
      return tags.map((t) => t[0].toUpperCase() + t.substring(1)).join(' & ');
    } catch (_) {
      return '';
    }
  }
}
