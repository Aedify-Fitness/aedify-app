import 'package:aedify/features/exercise_library/domain/candidate_exercise_dto.dart';

class CandidateExerciseRankedResult {
  const CandidateExerciseRankedResult({
    required this.exercise,
    required this.score,
  });

  final CandidateExerciseDto exercise;
  final int score;
}
