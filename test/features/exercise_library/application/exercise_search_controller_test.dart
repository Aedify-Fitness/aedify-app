import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
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
          difficulty: 'intermediate',
          muscleGroups: ['Chest'],
          modality: 'strength',
          equipment: 'barbell',
          isFavorite: false,
          isSubstitutedOut: false,
        ),
        const ExerciseListItem(
          id: 2,
          name: 'Squat',
          difficulty: 'beginner',
          muscleGroups: ['Quadriceps'],
          modality: 'strength',
          equipment: 'barbell',
          isFavorite: false,
          isSubstitutedOut: false,
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
          .updateFilters(const ExerciseFilterState(difficulty: 'beginner'));
      final state = container.read(
        AppProviders.exerciseSearchControllerProvider,
      );
      expect(state.filters.difficulty, 'beginner');
    });

    test('clearFilters resets state', () async {
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .reload();
      await container
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .updateFilters(const ExerciseFilterState(difficulty: 'beginner'));
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
