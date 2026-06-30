import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/load_custom_exercise_draft_use_case.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  ExerciseDetailViewData? detailToReturn;
  bool shouldThrow = false;

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async {
    if (shouldThrow) throw Exception('repository error');
    return detailToReturn;
  }

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<int> createCustomExercise(seed) async => 0;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}

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
}

void main() {
  group('LoadCustomExerciseDraftUseCase', () {
    late _FakeExerciseRepository repository;
    late LoadCustomExerciseDraftUseCase useCase;

    setUp(() {
      repository = _FakeExerciseRepository();
      useCase = LoadCustomExerciseDraftUseCase(exerciseRepository: repository);
    });

    test('createEmptyDraft returns a default draft', () async {
      final draft = await useCase.createEmptyDraft();

      expect(draft.name, '');
      expect(draft.muscleGroups, isEmpty);
      expect(draft.modality, ExerciseModality.strength);
      expect(draft.equipment, isNull);
      expect(draft.difficulty, isNull);
      expect(draft.steps, isEmpty);
    });

    test('createEmptyDraft does not call repository', () async {
      // Should succeed even if repository would throw
      repository.shouldThrow = true;
      final draft = await useCase.createEmptyDraft();
      expect(draft.name, '');
    });

    test('loadForEdit returns draft from custom exercise detail', () async {
      repository.detailToReturn = ExerciseDetailViewData(
        id: 101,
        name: 'Kettlebell Swing',
        difficulty: ExerciseDifficulty.intermediate,
        primaryMuscles: ['Glutes', 'Hamstrings'],
        muscleGroups: {BodymapBucket.glutes, BodymapBucket.hamstrings},
        category: 'Swing',
        modality: ExerciseModality.strength,
        equipment: EquipmentTag.kettlebell,
        force: ExerciseForce.pull,
        mechanic: ExerciseMechanic.compound,
        grips: ['Double'],
        steps: ['Hinge', 'Drive hips', 'Swing'],
        videos: const [],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      final draft = await useCase.loadForEdit(101);

      expect(draft.name, 'Kettlebell Swing');
      expect(draft.muscleGroups, {
        BodymapBucket.glutes,
        BodymapBucket.hamstrings,
      });
      expect(draft.modality, ExerciseModality.strength);
      expect(draft.equipment, EquipmentTag.kettlebell);
      expect(draft.difficulty, ExerciseDifficulty.intermediate);
      expect(draft.steps, ['Hinge', 'Drive hips', 'Swing']);
    });

    test('loadForEdit throws when detail is null', () async {
      repository.detailToReturn = null;

      expect(() => useCase.loadForEdit(999), throwsException);
    });

    test('loadForEdit throws when repository throws', () async {
      repository.shouldThrow = true;

      expect(() => useCase.loadForEdit(1), throwsException);
    });

    test('loadForEdit works with nullable fields as null', () async {
      repository.detailToReturn = ExerciseDetailViewData(
        id: 102,
        name: 'Bodyweight Squat',
        difficulty: null,
        primaryMuscles: ['Quads'],
        muscleGroups: {BodymapBucket.quads},
        category: null,
        modality: ExerciseModality.strength,
        equipment: null,
        force: null,
        mechanic: null,
        grips: [],
        steps: ['Stand', 'Squat', 'Stand up'],
        videos: const [],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      final draft = await useCase.loadForEdit(102);

      expect(draft.name, 'Bodyweight Squat');
      expect(draft.equipment, isNull);
      expect(draft.difficulty, isNull);
      expect(draft.steps, ['Stand', 'Squat', 'Stand up']);
    });
  });
}
