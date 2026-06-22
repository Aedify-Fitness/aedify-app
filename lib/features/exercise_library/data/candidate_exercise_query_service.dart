import 'package:aedify/features/exercise_library/domain/candidate_exercise_dto.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_query.dart';

abstract class CandidateExerciseQueryService {
  Future<List<CandidateExerciseDto>> queryCandidates(
    CandidateExerciseQuery query,
  );
}
