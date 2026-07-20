import 'dart:convert';

import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
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
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_logging_type_resolver.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/exercise_source.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';

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
  static final _logger = AppLogger(name: 'DriftExerciseRepository');

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
    _logger.debug('searchExercises');
    final exercises = await _exerciseDao.searchExercises(
      query: filters.searchQuery.isNotEmpty ? filters.searchQuery : null,
      muscleGroup: filters.muscleGroup?.label,
      equipment: filters.equipment?.dbValue,
      difficulty: filters.difficulty?.dbValue,
      modality: filters.modality?.dbValue,
      favoritesOnly: filters.favoritesOnly,
      excludeSubstituted: filters.excludeSubstituted,
    );

    return exercises
        .map(
          (e) => ExerciseListItem(
            id: e.id,
            name: e.name,
            difficulty: _decodeDifficulty(e.difficulty),
            muscleGroups: _decodeBodymapBuckets(e.muscleGroupsJson),
            modality: ExerciseModality.fromDb(e.modality),
            equipment: _decodeEquipment(e.equipment),
            isFavorite: e.isFavorite,
            isSubstitutedOut: e.isSubstitutedOut,
            isCustom: e.isCustom,
            loggingType: _resolveLoggingType(
              e.loggingType,
              modalityValue: e.modality,
              equipmentValue: e.equipment,
              forceValue: e.force,
            ),
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
      difficulty: _decodeDifficulty(exercise.difficulty),
      primaryMuscles: _decodeJsonList(exercise.primaryMusclesJson),
      muscleGroups: _decodeBodymapBuckets(exercise.muscleGroupsJson),
      category: exercise.category,
      modality: ExerciseModality.fromDb(exercise.modality),
      equipment: _decodeEquipment(exercise.equipment),
      force: _decodeForce(exercise.force),
      mechanic: _decodeMechanic(exercise.mechanic),
      grips: _decodeJsonList(exercise.gripsJson),
      steps: _decodeJsonList(exercise.stepsJson),
      videos: videos
          .map(
            (v) => ExerciseDetailVideoViewData(
              url: v.url,
              angle: _decodeVideoAngle(v.angle),
              gender: _decodeVideoGender(v.gender),
              ogImageUrl: v.ogImageUrl,
            ),
          )
          .toList(),
      isFavorite: exercise.isFavorite,
      isSubstitutedOut: exercise.isSubstitutedOut,
      loggingType: _resolveLoggingType(
        exercise.loggingType,
        modalityValue: exercise.modality,
        equipmentValue: exercise.equipment,
        forceValue: exercise.force,
      ),
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
            difficulty: _decodeDifficulty(e.difficulty),
            muscleGroups: _decodeBodymapBuckets(e.muscleGroupsJson),
            modality: ExerciseModality.fromDb(e.modality),
            equipment: _decodeEquipment(e.equipment),
            isFavorite: e.isFavorite,
            isSubstitutedOut: e.isSubstitutedOut,
            isCustom: e.isCustom,
            loggingType: _resolveLoggingType(
              e.loggingType,
              modalityValue: e.modality,
              equipmentValue: e.equipment,
              forceValue: e.force,
            ),
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
      difficulty: _decodeDifficulty(exercise.difficulty),
      primaryMuscles: _decodeJsonList(exercise.primaryMusclesJson),
      muscleGroups: _decodeBodymapBuckets(exercise.muscleGroupsJson),
      category: exercise.category,
      modality: ExerciseModality.fromDb(exercise.modality),
      equipment: _decodeEquipment(exercise.equipment),
      force: _decodeForce(exercise.force),
      mechanic: _decodeMechanic(exercise.mechanic),
      grips: _decodeJsonList(exercise.gripsJson),
      steps: _decodeJsonList(exercise.stepsJson),
      videos: const [],
      isFavorite: exercise.isFavorite,
      isSubstitutedOut: exercise.isSubstitutedOut,
      loggingType: _resolveLoggingType(
        exercise.loggingType,
        modalityValue: exercise.modality,
        equipmentValue: exercise.equipment,
        forceValue: exercise.force,
      ),
    );
  }

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async {
    _logger.debug('createCustomExercise');
    try {
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
          source: Value(ExerciseSource.custom.dbValue),
          name: Value(seed.name),
          nameNormalized: Value(seed.name.toLowerCase()),
          primaryMusclesJson: Value(
            json.encode(seed.muscleGroups.map((e) => e.label).toList()),
          ),
          muscleGroupsJson: Value(
            json.encode(seed.muscleGroups.map((e) => e.label).toList()),
          ),
          modality: Value(seed.modality.dbValue),
          loggingType: seed.loggingType != null
              ? Value(seed.loggingType!.dbValue)
              : const Value(null),
          equipment: seed.equipment != null
              ? Value(seed.equipment!.dbValue)
              : const Value(null),
          difficulty: seed.difficulty != null
              ? Value(seed.difficulty!.dbValue)
              : const Value(null),
          gripsJson: const Value('[]'),
          stepsJson: Value(json.encode(seed.steps)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return id;
    } catch (e) {
      _logger.error('createCustomExercise — failure', error: e);
      rethrow;
    }
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
        primaryMusclesJson: Value(
          json.encode(seed.muscleGroups.map((e) => e.label).toList()),
        ),
        muscleGroupsJson: Value(
          json.encode(seed.muscleGroups.map((e) => e.label).toList()),
        ),
        modality: Value(seed.modality.dbValue),
        loggingType: seed.loggingType != null
            ? Value(seed.loggingType!.dbValue)
            : const Value(null),
        equipment: seed.equipment != null
            ? Value(seed.equipment!.dbValue)
            : const Value(null),
        difficulty: seed.difficulty != null
            ? Value(seed.difficulty!.dbValue)
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

  Set<BodymapBucket> _decodeBodymapBuckets(String json) {
    return _decodeJsonList(json)
        .map(
          (label) => BodymapBucket.values.firstWhere((e) => e.label == label),
        )
        .toSet();
  }

  ExerciseDifficulty? _decodeDifficulty(String? value) {
    if (value == null || value.isEmpty) return null;
    return ExerciseDifficulty.fromDb(value);
  }

  EquipmentTag? _decodeEquipment(String? value) {
    if (value == null || value.isEmpty) return null;
    return EquipmentTag.fromDb(value);
  }

  ExerciseForce? _decodeForce(String? value) {
    if (value == null || value.isEmpty) return null;
    return ExerciseForce.fromDb(value.toLowerCase());
  }

  ExerciseMechanic? _decodeMechanic(String? value) {
    if (value == null || value.isEmpty) return null;
    return ExerciseMechanic.fromDb(value.toLowerCase());
  }

  ExerciseLoggingType _resolveLoggingType(
    String? dbValue, {
    required String modalityValue,
    required String? equipmentValue,
    required String? forceValue,
  }) {
    if (dbValue != null && dbValue.isNotEmpty) {
      return ExerciseLoggingType.fromDb(dbValue);
    }
    return ExerciseLoggingTypeResolver.resolve(
      modality: ExerciseModality.fromDb(modalityValue),
      equipment: _decodeEquipment(equipmentValue),
      force: _decodeForce(forceValue),
    );
  }

  ExerciseVideoAngle? _decodeVideoAngle(String? value) {
    if (value == null || value.isEmpty) return null;
    return ExerciseVideoAngle.fromDb(value);
  }

  ExerciseVideoGender? _decodeVideoGender(String? value) {
    if (value == null || value.isEmpty) return null;
    return ExerciseVideoGender.fromDb(value);
  }
}
