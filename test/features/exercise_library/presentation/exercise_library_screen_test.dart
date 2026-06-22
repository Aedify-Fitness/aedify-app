import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockSearchRepository implements ExerciseRepository {
  List<ExerciseListItem> searchResults = [];
  bool shouldThrow = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    if (shouldThrow) throw Exception('search failed');
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

Widget createTestApp(ExerciseRepository repository) {
  return ProviderScope(
    overrides: [
      AppProviders.exerciseRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: ExerciseLibraryScreen()),
  );
}

void main() {
  group('ExerciseLibraryScreen', () {
    late _MockSearchRepository mockRepository;

    setUp(() {
      mockRepository = _MockSearchRepository();
    });

    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      // Initially the controller is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Resolve the async work
      await tester.pump();
    });

    testWidgets('shows empty state', (tester) async {
      mockRepository.searchResults = [];
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('No exercises found.'), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      mockRepository.shouldThrow = true;
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('renders result list', (tester) async {
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
      ];
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('search field exists', (tester) async {
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
      ];
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
    });

    testWidgets('filter button opens filter sheet', (tester) async {
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
      ];
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Filters'), findsWidgets);
    });
  });
}
