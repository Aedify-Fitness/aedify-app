import 'dart:convert';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';

abstract class ExerciseRepository {
  Future<List<ExerciseListItem>> searchExercises(ExerciseFilterState filters);

  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId);

  Future<void> setFavorite({required int exerciseId, required bool isFavorite});

  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  });
}

class DriftExerciseRepository implements ExerciseRepository {
  DriftExerciseRepository({required AppDatabase database})
    : _exerciseDao = ExerciseDao(database),
      _videoDao = ExerciseVideoDao(database);

  final ExerciseDao _exerciseDao;
  final ExerciseVideoDao _videoDao;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    final exercises = await _exerciseDao.searchExercises(
      query: filters.searchQuery.isNotEmpty ? filters.searchQuery : null,
      muscleGroup: filters.muscleGroup,
      equipment: filters.equipment,
      difficulty: filters.difficulty,
      modality: filters.modality,
      favoritesOnly: filters.favoritesOnly,
      excludeSubstituted: filters.excludeSubstituted,
    );

    return exercises
        .map(
          (e) => ExerciseListItem(
            id: e.id,
            name: e.name,
            difficulty: e.difficulty,
            muscleGroups: _decodeJsonList(e.muscleGroupsJson),
            modality: e.modality,
            equipment: e.equipment,
            isFavorite: e.isFavorite,
            isSubstitutedOut: e.isSubstitutedOut,
          ),
        )
        .toList();
  }

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    final exercise = await _exerciseDao.getExerciseById(exerciseId);
    if (exercise == null) return null;

    final videos = await _videoDao.getVideosByExerciseId(exerciseId);

    return ExerciseDetailViewData(
      id: exercise.id,
      name: exercise.name,
      difficulty: exercise.difficulty,
      primaryMuscles: _decodeJsonList(exercise.primaryMusclesJson),
      muscleGroups: _decodeJsonList(exercise.muscleGroupsJson),
      category: exercise.category,
      modality: exercise.modality,
      equipment: exercise.equipment,
      force: exercise.force,
      mechanic: exercise.mechanic,
      grips: _decodeJsonList(exercise.gripsJson),
      steps: _decodeJsonList(exercise.stepsJson),
      videos: videos
          .map(
            (v) => ExerciseDetailVideoViewData(
              url: v.url,
              angle: v.angle,
              gender: v.gender,
              ogImageUrl: v.ogImageUrl,
            ),
          )
          .toList(),
      isFavorite: exercise.isFavorite,
      isSubstitutedOut: exercise.isSubstitutedOut,
    );
  }

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {
    await _exerciseDao.setFavorite(
      exerciseId: exerciseId,
      isFavorite: isFavorite,
    );
  }

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {
    await _exerciseDao.setSubstitutedOut(
      exerciseId: exerciseId,
      isSubstitutedOut: isSubstitutedOut,
    );
  }

  List<String> _decodeJsonList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
