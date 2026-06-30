import 'dart:convert';

import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_exercise.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_validation_failure.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_video.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';

class ExerciseDatasetParser {
  const ExerciseDatasetParser();

  static const Set<String> supportedDifficulties = {
    'novice',
    'beginner',
    'intermediate',
    'advanced',
  };

  static const Set<String> supportedModalities = {
    'strength',
    'flexibility',
    'cardio',
    'recovery',
  };

  static const Set<String> supportedMuscleBuckets = {
    'Chest',
    'Shoulders',
    'Back',
    'Biceps',
    'Triceps',
    'Forearms',
    'Core',
    'Glutes',
    'Quads',
    'Hamstrings',
    'Calves',
    'Adductors',
    'Neck',
    'Feet',
  };

  ExerciseDataset parse({
    required String rawJson,
    required int supportedSchemaVersion,
    required int minimumSupportedAppSchemaVersion,
  }) {
    final json = _decodeJsonObject(rawJson);
    return _parseDataset(
      json,
      supportedSchemaVersion: supportedSchemaVersion,
      minimumSupportedAppSchemaVersion: minimumSupportedAppSchemaVersion,
    );
  }

  Map<String, Object?> _decodeJsonObject(String rawJson) {
    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map<String, Object?>) {
        throw const ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.invalidTopLevelShape,
          message: 'Root must be a JSON object',
        );
      }
      return decoded;
    } on FormatException catch (e) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.invalidTopLevelShape,
        message: 'Malformed JSON: ${e.message}',
      );
    }
  }

  ExerciseDataset _parseDataset(
    Map<String, Object?> json, {
    required int supportedSchemaVersion,
    required int minimumSupportedAppSchemaVersion,
  }) {
    final schemaVersion = _requireInt(json, 'schema_version');
    if (schemaVersion > supportedSchemaVersion) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.unsupportedSchemaVersion,
        message:
            'Dataset schema version $schemaVersion is newer than '
            'supported $supportedSchemaVersion',
        field: 'schema_version',
      );
    }
    if (schemaVersion < minimumSupportedAppSchemaVersion) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode
            .unsupportedMinimumAppSchemaVersion,
        message:
            'Dataset schema version $schemaVersion is older than '
            'minimum supported $minimumSupportedAppSchemaVersion',
        field: 'schema_version',
      );
    }

    final generatedAtStr = _requireString(json, 'generated_at');
    final generatedAt = DateTime.tryParse(generatedAtStr);
    if (generatedAt == null) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.missingRequiredField,
        message: 'generated_at is not a valid date/time string',
        field: 'generated_at',
      );
    }

    final source = _requireString(json, 'source');
    final declaredCount = _requireInt(json, 'exercise_count');
    final exercisesJson = _requireList(json, 'exercises');

    final exercises = <ExerciseDatasetExercise>[];
    for (final (i, entry) in exercisesJson.indexed) {
      if (entry is! Map<String, Object?>) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.invalidTopLevelShape,
          message: 'exercises[$i] must be an object',
          field: 'exercises',
        );
      }
      exercises.add(_parseExercise(entry, exerciseId: i));
    }

    _validateExerciseCount(
      declaredCount: declaredCount,
      actualCount: exercises.length,
    );

    _validateUniqueIds(exercises);

    return ExerciseDataset(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      source: source,
      exerciseCount: declaredCount,
      exercises: exercises,
    );
  }

  ExerciseDatasetExercise _parseExercise(
    Map<String, Object?> json, {
    required int exerciseId,
  }) {
    final id = _requireInt(json, 'id', exerciseId: exerciseId);
    final name = _requireString(json, 'name', exerciseId: id);
    if (name.trim().isEmpty) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.missingRequiredField,
        message: 'Exercise name must not be empty',
        field: 'name',
        exerciseId: id,
      );
    }

    final difficultyValue = _requireString(json, 'difficulty', exerciseId: id);
    _validateDifficulty(difficultyValue, exerciseId: id);
    final difficulty = ExerciseDifficulty.fromDb(difficultyValue);

    final primaryMuscles = _requireStringList(
      json,
      'primary_muscles',
      exerciseId: id,
    );

    final muscleGroupValues = _requireStringList(
      json,
      'muscle_groups',
      exerciseId: id,
    );
    _validateMuscleGroups(muscleGroupValues, exerciseId: id);
    final muscleGroups = muscleGroupValues.map(_bodymapBucketFromLabel).toSet();

    final modalityValue = _requireString(json, 'modality', exerciseId: id);
    _validateModality(modalityValue, exerciseId: id);
    final modality = ExerciseModality.fromDb(modalityValue);

    final equipmentValue = _readNullableString(json, 'equipment');
    _validateStrengthEquipment(
      modality: modality.dbValue,
      equipment: equipmentValue,
      exerciseId: id,
    );
    final equipment = equipmentValue == null || equipmentValue.trim().isEmpty
        ? null
        : EquipmentTag.fromDb(equipmentValue);

    final grips = _requireStringList(json, 'grips', exerciseId: id);

    final steps = _requireStringList(json, 'steps', exerciseId: id);

    final videosJson = _requireList(json, 'videos', exerciseId: id);
    final videos = <ExerciseDatasetVideo>[];
    for (final (i, entry) in videosJson.indexed) {
      if (entry is! Map<String, Object?>) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.invalidVideos,
          message: 'videos[$i] must be an object',
          field: 'videos',
          exerciseId: id,
        );
      }
      videos.add(_parseVideo(entry, exerciseId: id));
    }

    return ExerciseDatasetExercise(
      id: id,
      name: name,
      difficulty: difficulty,
      primaryMuscles: primaryMuscles,
      muscleGroups: muscleGroups,
      category: _readNullableString(json, 'category'),
      modality: modality,
      equipment: equipment,
      force: _decodeForce(_readNullableString(json, 'force')),
      mechanic: _decodeMechanic(_readNullableString(json, 'mechanic')),
      grips: grips,
      steps: steps,
      videos: videos,
    );
  }

  ExerciseDatasetVideo _parseVideo(
    Map<String, Object?> json, {
    required int exerciseId,
  }) {
    final urlStr = _requireString(json, 'url', exerciseId: exerciseId);
    final url = Uri.tryParse(urlStr);
    if (url == null || !url.hasScheme || !url.hasAuthority) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.invalidVideoUrl,
        message: 'Invalid video URL: $urlStr',
        field: 'url',
        exerciseId: exerciseId,
      );
    }

    final angle = ExerciseVideoAngle.fromDb(
      _requireString(json, 'angle', exerciseId: exerciseId),
    );
    final gender = ExerciseVideoGender.fromDb(
      _requireString(json, 'gender', exerciseId: exerciseId),
    );

    return ExerciseDatasetVideo(
      url: url,
      angle: angle,
      gender: gender,
      ogImage: _readNullableString(json, 'og_image'),
    );
  }

  BodymapBucket _bodymapBucketFromLabel(String label) {
    return BodymapBucket.values.firstWhere((bucket) => bucket.label == label);
  }

  ExerciseForce? _decodeForce(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return ExerciseForce.fromDb(value.toLowerCase());
  }

  ExerciseMechanic? _decodeMechanic(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return ExerciseMechanic.fromDb(value.toLowerCase());
  }

  void _validateExerciseCount({
    required int declaredCount,
    required int actualCount,
  }) {
    if (declaredCount != actualCount) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.exerciseCountMismatch,
        message:
            'Declared count $declaredCount does not match '
            'actual count $actualCount',
        field: 'exercise_count',
      );
    }
  }

  void _validateUniqueIds(List<ExerciseDatasetExercise> exercises) {
    final seen = <int>{};
    for (final exercise in exercises) {
      if (!seen.add(exercise.id)) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.duplicateExerciseId,
          message: 'Duplicate exercise ID: ${exercise.id}',
          field: 'id',
          exerciseId: exercise.id,
        );
      }
    }
  }

  void _validateDifficulty(String value, {required int exerciseId}) {
    if (!supportedDifficulties.contains(value)) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.invalidDifficulty,
        message:
            'Unsupported difficulty "$value". '
            'Supported: ${supportedDifficulties.join(', ')}',
        field: 'difficulty',
        exerciseId: exerciseId,
      );
    }
  }

  void _validateModality(String value, {required int exerciseId}) {
    if (!supportedModalities.contains(value)) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.invalidModality,
        message:
            'Unsupported modality "$value". '
            'Supported: ${supportedModalities.join(', ')}',
        field: 'modality',
        exerciseId: exerciseId,
      );
    }
  }

  void _validateMuscleGroups(List<String> values, {required int exerciseId}) {
    for (final value in values) {
      if (!supportedMuscleBuckets.contains(value)) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.invalidMuscleGroup,
          message:
              'Unsupported muscle group "$value". '
              'Supported: ${supportedMuscleBuckets.join(', ')}',
          field: 'muscle_groups',
          exerciseId: exerciseId,
        );
      }
    }
  }

  void _validateStrengthEquipment({
    required String modality,
    required String? equipment,
    required int exerciseId,
  }) {
    if (modality == 'strength') {
      if (equipment == null || equipment.trim().isEmpty) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.invalidStrengthEquipment,
          message: 'Strength exercises must specify equipment',
          field: 'equipment',
          exerciseId: exerciseId,
        );
      }
    }
  }

  String _requireString(
    Map<String, Object?> json,
    String key, {
    int? exerciseId,
  }) {
    final value = json[key];
    if (value is! String) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.missingRequiredField,
        message: 'Missing or invalid required field: $key',
        field: key,
        exerciseId: exerciseId,
      );
    }
    return value;
  }

  int _requireInt(Map<String, Object?> json, String key, {int? exerciseId}) {
    final value = json[key];
    if (value is! int) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.missingRequiredField,
        message: 'Missing or invalid required field: $key',
        field: key,
        exerciseId: exerciseId,
      );
    }
    return value;
  }

  List<Object?> _requireList(
    Map<String, Object?> json,
    String key, {
    int? exerciseId,
  }) {
    final value = json[key];
    if (value is! List) {
      throw ExerciseDatasetValidationFailure(
        code: ExerciseDatasetValidationFailureCode.missingRequiredField,
        message: 'Missing or invalid required field: $key',
        field: key,
        exerciseId: exerciseId,
      );
    }
    return value;
  }

  List<String> _requireStringList(
    Map<String, Object?> json,
    String key, {
    int? exerciseId,
  }) {
    final list = _requireList(json, key, exerciseId: exerciseId);
    final result = <String>[];
    for (final (i, entry) in list.indexed) {
      if (entry is! String) {
        throw ExerciseDatasetValidationFailure(
          code: ExerciseDatasetValidationFailureCode.missingRequiredField,
          message: '$key[$i] must be a string',
          field: key,
          exerciseId: exerciseId,
        );
      }
      result.add(entry);
    }
    return result;
  }

  String? _readNullableString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    return null;
  }
}
