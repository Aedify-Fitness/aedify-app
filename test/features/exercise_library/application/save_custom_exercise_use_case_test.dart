import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/save_custom_exercise_use_case.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  int createResult = 101;
  CustomExerciseSeed? lastCreatedSeed;
  int? lastUpdatedExerciseId;
  CustomExerciseSeed? lastUpdatedSeed;

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async {
    lastCreatedSeed = seed;
    return createResult;
  }

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {
    lastUpdatedExerciseId = exerciseId;
    lastUpdatedSeed = seed;
  }

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async => [];

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async =>
      null;

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {}

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {}

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async => null;

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

void main() {
  group('SaveCustomExerciseUseCase', () {
    late _FakeExerciseRepository repository;
    late SaveCustomExerciseUseCase useCase;

    setUp(() {
      repository = _FakeExerciseRepository();
      useCase = SaveCustomExerciseUseCase(exerciseRepository: repository);
    });

    test(
      'create calls repository.createCustomExercise and returns id',
      () async {
        const draft = CustomExerciseDraft(
          name: 'New Exercise',
          muscleGroups: {BodymapBucket.chest},
          modality: ExerciseModality.strength,
          steps: ['Step one'],
        );

        final id = await useCase.create(draft);

        expect(id, 101);
        expect(repository.lastCreatedSeed, isNotNull);
        expect(repository.lastCreatedSeed!.name, 'New Exercise');
      },
    );

    test('create converts draft to seed via toSeed', () async {
      const draft = CustomExerciseDraft(
        name: 'Push-up',
        muscleGroups: {BodymapBucket.chest, BodymapBucket.triceps},
        modality: ExerciseModality.strength,
        steps: ['Lower', 'Push'],
      );

      final seed = draft.toSeed();
      expect(seed.name, 'Push-up');
      expect(seed.muscleGroups, {BodymapBucket.chest, BodymapBucket.triceps});
      expect(seed.steps, ['Lower', 'Push']);
    });

    test(
      'update calls repository.updateCustomExercise with correct args',
      () async {
        const draft = CustomExerciseDraft(
          name: 'Updated Exercise',
          muscleGroups: {BodymapBucket.back},
          modality: ExerciseModality.strength,
        );

        await useCase.update(exerciseId: 42, draft: draft);

        expect(repository.lastUpdatedExerciseId, 42);
        expect(repository.lastUpdatedSeed, isNotNull);
        expect(repository.lastUpdatedSeed!.name, 'Updated Exercise');
      },
    );

    test('update passes seed with all draft fields', () async {
      const draft = CustomExerciseDraft(
        name: 'Full Exercise',
        muscleGroups: {BodymapBucket.shoulders, BodymapBucket.triceps},
        modality: ExerciseModality.strength,
        steps: ['Step A', 'Step B'],
      );

      await useCase.update(exerciseId: 7, draft: draft);

      final seed = repository.lastUpdatedSeed!;
      expect(seed.name, 'Full Exercise');
      expect(seed.muscleGroups, {
        BodymapBucket.shoulders,
        BodymapBucket.triceps,
      });
      expect(seed.modality, ExerciseModality.strength);
      expect(seed.steps, ['Step A', 'Step B']);
      expect(seed.equipment, isNull);
      expect(seed.difficulty, isNull);
    });
  });
}
