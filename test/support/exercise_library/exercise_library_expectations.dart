import 'package:aedify/features/exercise_library/domain/candidate_exercise_dto.dart';
import 'package:flutter_test/flutter_test.dart';

class ExerciseLibraryExpectations {
  ExerciseLibraryExpectations._();

  static void expectContainsExerciseIds(
    Iterable<int> actualIds,
    Iterable<int> expectedIds,
  ) {
    for (final id in expectedIds) {
      expect(actualIds, contains(id), reason: 'Expected exercise ID $id');
    }
  }

  static void expectExactExerciseIdsInOrder(
    Iterable<int> actualIds,
    Iterable<int> expectedIds,
  ) {
    expect(actualIds.toList(), equals(expectedIds.toList()));
  }

  static void expectCandidateDtosContainNoForbiddenFields(
    List<CandidateExerciseDto> candidates,
  ) {
    for (final c in candidates) {
      expect(c.id, isA<int>());
      expect(c.name, isNotEmpty);
      expect(c.muscleGroups, isNotEmpty);
      expect(c.modality, isNotEmpty);
      expect(c.isCustom, isA<bool>());
    }
  }

  static void expectBodymapBucketsAreValid(
    Iterable<String> buckets, {
    required List<String> validBuckets,
  }) {
    for (final bucket in buckets) {
      expect(
        validBuckets,
        contains(bucket),
        reason: 'Bucket "$bucket" is not in the valid bucket list',
      );
    }
  }
}
