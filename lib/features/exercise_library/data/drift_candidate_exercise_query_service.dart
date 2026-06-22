import 'dart:convert';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/features/exercise_library/data/candidate_exercise_query_service.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_dto.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_query.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_ranked_result.dart';

class DriftCandidateExerciseQueryService
    implements CandidateExerciseQueryService {
  DriftCandidateExerciseQueryService({required AppDatabase database})
    : _dao = ExerciseDao(database);

  final ExerciseDao _dao;

  @override
  Future<List<CandidateExerciseDto>> queryCandidates(
    CandidateExerciseQuery query,
  ) async {
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
      if (exercise.muscleGroups.any(
        (mg) => mg.toLowerCase() == preferred.toLowerCase(),
      )) {
        score += 3;
      }
    }

    for (final tag in query.goalTags) {
      final lowerTag = tag.toLowerCase();
      if (exercise.modality.toLowerCase() == lowerTag) {
        score += 2;
      }
      if (exercise.mechanic?.toLowerCase() == lowerTag) {
        score += 2;
      }
      if (exercise.force?.toLowerCase() == lowerTag) {
        score += 2;
      }
    }

    return score;
  }

  CandidateExerciseDto _toDto(Exercise exercise) {
    return CandidateExerciseDto(
      id: exercise.id,
      name: exercise.name,
      difficulty: exercise.difficulty,
      muscleGroups: _decodeJsonList(exercise.muscleGroupsJson),
      modality: exercise.modality,
      equipment: exercise.equipment,
      mechanic: exercise.mechanic,
      force: exercise.force,
      isCustom: exercise.isCustom,
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
