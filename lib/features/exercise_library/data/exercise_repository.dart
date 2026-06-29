import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/features/exercise_library/data/custom_exercise_identity_service.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
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

  Future<List<ExerciseListItem>> getCustomExercises();

  Future<ExerciseDetailViewData?> getCustomExerciseDetail(int exerciseId);

  Future<int> createCustomExercise(CustomExerciseSeed seed);

  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  });

  Future<void> deleteCustomExercise(int exerciseId);
}

class DriftExerciseRepository implements ExerciseRepository {
  DriftExerciseRepository({
    required AppDatabase database,
    CustomExerciseIdentityService? identityService,
  }) : _exerciseDao = ExerciseDao(database),
       _videoDao = ExerciseVideoDao(database),
       _identityService =
           identityService ?? const CustomExerciseIdentityService();

  final ExerciseDao _exerciseDao;
  final ExerciseVideoDao _videoDao;
  final CustomExerciseIdentityService _identityService;

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
            isCustom: e.isCustom,
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

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async {
    final exercises = await _exerciseDao.getCustomExercises();
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
            isCustom: e.isCustom,
          ),
        )
        .toList();
  }

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async {
    final exercise = await _exerciseDao.getExerciseById(exerciseId);
    if (exercise == null || !exercise.isCustom) return null;

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
      videos: const [],
      isFavorite: exercise.isFavorite,
      isSubstitutedOut: exercise.isSubstitutedOut,
    );
  }

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async {
    final allIds = (await _exerciseDao.getAllExercises())
        .map((e) => e.id)
        .toSet();
    final id = _identityService.nextCustomExerciseId(existingIds: allIds);
    final uuid = _identityService.newCustomExerciseUuid();
    final now = DateTime.now();

    await _exerciseDao.insertCustomExercise(
      ExercisesCompanion(
        id: Value(id),
        isCustom: const Value(true),
        customExerciseUuid: Value(uuid),
        source: const Value('custom'),
        name: Value(seed.name),
        nameNormalized: Value(seed.name.toLowerCase()),
        primaryMusclesJson: Value(json.encode(seed.muscleGroups)),
        muscleGroupsJson: Value(json.encode(seed.muscleGroups)),
        modality: Value(seed.modality),
        equipment: seed.equipment != null
            ? Value(seed.equipment)
            : const Value(null),
        difficulty: seed.difficulty != null
            ? Value(seed.difficulty)
            : const Value(null),
        gripsJson: const Value('[]'),
        stepsJson: Value(json.encode(seed.steps)),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {
    final now = DateTime.now();
    await _exerciseDao.updateCustomExercise(
      ExercisesCompanion(
        id: Value(exerciseId),
        name: Value(seed.name),
        nameNormalized: Value(seed.name.toLowerCase()),
        primaryMusclesJson: Value(json.encode(seed.muscleGroups)),
        muscleGroupsJson: Value(json.encode(seed.muscleGroups)),
        modality: Value(seed.modality),
        equipment: seed.equipment != null
            ? Value(seed.equipment)
            : const Value(null),
        difficulty: seed.difficulty != null
            ? Value(seed.difficulty)
            : const Value(null),
        stepsJson: Value(json.encode(seed.steps)),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {
    await _exerciseDao.deleteCustomExerciseById(exerciseId);
  }

  List<String> _decodeJsonList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
