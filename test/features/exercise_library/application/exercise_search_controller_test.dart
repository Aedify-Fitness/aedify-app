import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockRepository implements ExerciseRepository {
  List<ExerciseListItem> searchResults = [];
  bool shouldThrow = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    if (shouldThrow) throw Exception('search failed');
    if (filters.searchQuery.isNotEmpty) {
      return searchResults
          .where(
            (e) => e.name.toLowerCase().contains(
              filters.searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    return searchResults;
  }

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
  group('ExerciseSearchController', () {
    late _MockRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = _MockRepository();
      mockRepository.searchResults = [
        const ExerciseListItem(
          id: 1,
          name: 'Bench Press',
          difficulty: ExerciseDifficulty.intermediate,
          muscleGroups: {BodymapBucket.chest},
          modality: ExerciseModality.strength,
          equipment: EquipmentTag.barbell,
          isFavorite: false,
          isSubstitutedOut: false,
          isCustom: false,
        ),
        const ExerciseListItem(
          id: 2,
          name: 'Squat',
          difficulty: ExerciseDifficulty.beginner,
          muscleGroups: {BodymapBucket.quads},
          modality: ExerciseModality.strength,
          equipment: EquipmentTag.barbell,
          isFavorite: false,
          isSubstitutedOut: false,
          isCustom: false,
        ),
      ];

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

    test('initial build loads items', () async {
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.isLoading, isFalse);
      expect(state.items.length, 2);
    });

    test('updateSearchQuery reloads with filtered results', () async {
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .updateSearchQuery('bench');
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.items.length, 1);
      expect(state.items.first.name, 'Bench Press');
    });

    test('updateFilters reloads items', () async {
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .updateFilters(
            const ExerciseFilterState(difficulty: ExerciseDifficulty.beginner),
          );
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.filters.difficulty, ExerciseDifficulty.beginner);
    });

    test('clearFilters resets state', () async {
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .updateFilters(
            const ExerciseFilterState(difficulty: ExerciseDifficulty.beginner),
          );
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .clearFilters();
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.filters.hasActiveFilters, isFalse);
    });

    test('repository failure surfaces error state', () async {
      mockRepository.shouldThrow = true;
      container = ProviderContainer(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            mockRepository,
          ),
        ],
      );
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.errorCode, isNotNull);
      container.dispose();
    });
  });
}
