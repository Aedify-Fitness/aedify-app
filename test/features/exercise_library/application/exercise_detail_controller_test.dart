import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDetailRepository implements ExerciseRepository {
  ExerciseDetailViewData? detail;
  bool shouldThrow = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async => [];

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    if (shouldThrow) throw Exception('load failed');
    return detail;
  }

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
  Future<int> createCustomExercise(CustomExerciseSeed seed) async => -1;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

void main() {
  group('ExerciseDetailController', () {
    late _MockDetailRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = _MockDetailRepository();
      mockRepository.detail = ExerciseDetailViewData(
        id: 1,
        name: 'Bench Press',
        difficulty: 'intermediate',
        primaryMuscles: ['Chest'],
        muscleGroups: ['Chest'],
        category: 'compound',
        modality: 'strength',
        equipment: 'barbell',
        force: 'push',
        mechanic: 'compound',
        grips: ['barbell'],
        steps: ['Step 1'],
        videos: [
          const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: 'front',
            gender: 'male',
            ogImageUrl: null,
          ),
        ],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      container = ProviderContainer(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            mockRepository,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<ExerciseDetailViewData?> resolveDetail(
      ProviderContainer targetContainer,
      int id,
    ) async {
      for (var i = 0; i < 50; i++) {
        final asyncValue = targetContainer.read(
          AppProviders.exerciseDetailControllerProvider(id),
        );
        if (asyncValue is AsyncData) {
          return asyncValue.value;
        }
        await Future.delayed(const Duration(milliseconds: 1));
      }
      return null;
    }

    test('loads detail by id', () async {
      final detail = await resolveDetail(container, 1);
      expect(detail, isNotNull);
      expect(detail!.name, 'Bench Press');
    });

    test('returns null when missing', () async {
      mockRepository.detail = null;
      container = ProviderContainer(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            mockRepository,
          ),
        ],
      );
      final detail = await resolveDetail(container, 1);
      expect(detail, isNull);
      container.dispose();
    });

    test('reads updated detail after repository change', () async {
      await resolveDetail(container, 1);

      mockRepository.detail = ExerciseDetailViewData(
        id: 1,
        name: 'Updated Bench',
        difficulty: 'intermediate',
        primaryMuscles: ['Chest'],
        muscleGroups: ['Chest'],
        category: 'compound',
        modality: 'strength',
        equipment: 'barbell',
        force: 'push',
        mechanic: 'compound',
        grips: ['barbell'],
        steps: ['Step 1'],
        videos: [],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      final newContainer = ProviderContainer(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            mockRepository,
          ),
        ],
      );

      final detail = await resolveDetail(newContainer, 1);
      expect(detail, isNotNull);
      expect(detail!.name, 'Updated Bench');
      newContainer.dispose();
    });
  });
}
