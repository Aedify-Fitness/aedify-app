import 'dart:convert';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/data/candidate_exercise_query_service.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_dto.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_query.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_ranked_result.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_logging_type_resolver.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

class DriftCandidateExerciseQueryService
    implements CandidateExerciseQueryService {
  static final _logger = AppLogger(name: 'DriftCandidateExerciseQueryService');

  DriftCandidateExerciseQueryService({required AppDatabase database})
    : _dao = ExerciseDao(database);

  final ExerciseDao _dao;

  @override
  Future<List<CandidateExerciseDto>> queryCandidates(
    CandidateExerciseQuery query,
  ) async {
    _logger.debug('queryCandidates');
    final rows = await _dao.getExercisesForCandidateEngine(
      includeCustomExercises: query.includeCustomExercises,
    );

    final candidates = <CandidateExerciseDto>[];
    for (final row in rows) {
      final dto = _toDto(row);
      if (_matchesHardFilters(dto, query)) {
        candidates.add(dto);
      }
    }

    final ranked = _rankCandidates(exercises: candidates, query: query);

    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      final nameCompare = a.exercise.name.compareTo(b.exercise.name);
      if (nameCompare != 0) return nameCompare;
      return a.exercise.id.compareTo(b.exercise.id);
    });

    return ranked.take(query.limit).map((r) => r.exercise).toList();
  }

  bool _matchesHardFilters(
    CandidateExerciseDto exercise,
    CandidateExerciseQuery query,
  ) {
    if (query.allowedEquipment.isNotEmpty &&
        !query.allowedEquipment.contains(exercise.equipment) &&
        exercise.equipment != null) {
      return false;
    }

    if (query.allowedDifficulties.isNotEmpty &&
        exercise.difficulty != null &&
        !query.allowedDifficulties.contains(exercise.difficulty)) {
      return false;
    }

    if (query.allowedModalities.isNotEmpty &&
        !query.allowedModalities.contains(exercise.modality)) {
      return false;
    }

    if (query.excludedExerciseIds.contains(exercise.id)) {
      return false;
    }

    if (query.excludedMuscleGroups.isNotEmpty) {
      if (exercise.muscleGroups.any(
        (mg) => query.excludedMuscleGroups.contains(mg),
      )) {
        return false;
      }
    }

    return true;
  }

  List<CandidateExerciseRankedResult> _rankCandidates({
    required List<CandidateExerciseDto> exercises,
    required CandidateExerciseQuery query,
  }) {
    return exercises.map((e) {
      final score = _scoreExercise(e, query);
      return CandidateExerciseRankedResult(exercise: e, score: score);
    }).toList();
  }

  int _scoreExercise(
    CandidateExerciseDto exercise,
    CandidateExerciseQuery query,
  ) {
    int score = 0;

    for (final preferred in query.preferredMuscleGroups) {
      if (exercise.muscleGroups.contains(preferred)) {
        score += 3;
      }
    }

    for (final tag in query.goalTags) {
      if ((tag == GoalTag.loseWeight || tag == GoalTag.improveEndurance) &&
          exercise.modality == ExerciseModality.cardio) {
        score += 2;
      }
      if (tag == GoalTag.buildMuscle &&
          exercise.mechanic == ExerciseMechanic.isolation) {
        score += 2;
      }
      if (tag == GoalTag.increaseStrength &&
          exercise.force == ExerciseForce.push) {
        score += 2;
      }
    }

    return score;
  }

  CandidateExerciseDto _toDto(Exercise exercise) {
    final modality = ExerciseModality.fromDb(exercise.modality);
    final equipment = exercise.equipment == null || exercise.equipment!.isEmpty
        ? null
        : EquipmentTag.fromDb(exercise.equipment!);
    final force = exercise.force == null || exercise.force!.isEmpty
        ? null
        : ExerciseForce.fromDb(exercise.force!.toLowerCase());
    return CandidateExerciseDto(
      id: exercise.id,
      name: exercise.name,
      difficulty: exercise.difficulty == null || exercise.difficulty!.isEmpty
          ? null
          : ExerciseDifficulty.fromDb(exercise.difficulty!),
      muscleGroups: _decodeJsonList(exercise.muscleGroupsJson)
          .map(
            (label) => BodymapBucket.values.firstWhere((e) => e.label == label),
          )
          .toSet(),
      modality: modality,
      equipment: equipment,
      mechanic: exercise.mechanic == null || exercise.mechanic!.isEmpty
          ? null
          : ExerciseMechanic.fromDb(exercise.mechanic!.toLowerCase()),
      force: force,
      isCustom: exercise.isCustom,
      loggingType: _resolveLoggingType(
        exercise.loggingType,
        modality: modality,
        equipment: equipment,
        force: force,
      ),
    );
  }

  List<String> _decodeJsonList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  ExerciseLoggingType _resolveLoggingType(
    String? dbValue, {
    required ExerciseModality modality,
    required EquipmentTag? equipment,
    required ExerciseForce? force,
  }) {
    if (dbValue != null && dbValue.isNotEmpty) {
      return ExerciseLoggingType.fromDb(dbValue);
    }
    return ExerciseLoggingTypeResolver.resolve(
      modality: modality,
      equipment: equipment,
      force: force,
    );
  }
}
