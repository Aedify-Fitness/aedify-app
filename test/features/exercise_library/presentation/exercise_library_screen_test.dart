import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/custom_exercise_editor_screen.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _MockSearchRepository implements ExerciseRepository {
  List<ExerciseListItem> searchResults = [];
  final searches = <ExerciseFilterState>[];
  bool shouldThrow = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    searches.add(filters);
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

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async => null;

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async {
    searchResults = [
      ...searchResults,
      ExerciseListItem(
        id: -1,
        name: seed.name,
        difficulty: seed.difficulty,
        muscleGroups: seed.muscleGroups,
        modality: seed.modality,
        equipment: seed.equipment,
        isFavorite: false,
        isSubstitutedOut: false,
        isCustom: true,
      ),
    ];
    return -1;
  }

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

class _FixedSyncNotifier extends ExerciseDatasetSyncController {
  @override
  Future<ExerciseDatasetSyncState> build() async {
    return const ExerciseDatasetSyncState(
      phase: ExerciseDatasetSyncPhase.synced,
    );
  }
}

Widget createTestApp(
  ExerciseRepository repository, {
  bool withBottomNavigation = false,
}) {
  return ProviderScope(
    overrides: [
      AppProviders.exerciseRepositoryProvider.overrideWithValue(repository),
      AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
        () => _FixedSyncNotifier(),
      ),
    ],
    child: MaterialApp(
      home: withBottomNavigation
          ? const AppBottomNavigationScope(child: ExerciseLibraryScreen())
          : const ExerciseLibraryScreen(),
    ),
  );
}

List<ExerciseListItem> _benchPressItem() => [
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
];

class _ExerciseLibraryNavigationFixtures {
  _ExerciseLibraryNavigationFixtures._();

  static ({Widget app, GoRouter router}) app(ExerciseRepository repository) {
    final router = GoRouter(
      initialLocation: AppRoutes.exercises().path,
      routes: [
        GoRoute(
          path: AppRoutes.exercises().path,
          name: AppRoutes.exercises().name,
          builder: (_, _) => const ExerciseLibraryScreen(),
        ),
        GoRoute(
          path: AppRoutes.customExerciseCreate().path,
          name: AppRoutes.customExerciseCreate().name,
          builder: (_, _) => const CustomExerciseEditorScreen.create(),
        ),
      ],
    );
    return (
      router: router,
      app: ProviderScope(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(repository),
          AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
            () => _FixedSyncNotifier(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}

void main() {
  group('ExerciseLibraryScreen', () {
    late _MockSearchRepository mockRepository;

    setUp(() {
      mockRepository = _MockSearchRepository();
    });

    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('search field exists', (tester) async {
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
    });

    testWidgets('view toggle has list and bodymap options', (tester) async {
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Exercise Library'), findsOneWidget);
      expect(find.text('Bodymap'), findsOneWidget);
    });

    testWidgets('muscle group filter chips exist', (tester) async {
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Legs'), findsOneWidget);
      expect(find.text('Shoulders'), findsOneWidget);
    });

    testWidgets('create exercise FAB exists', (tester) async {
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      final createFab = find.byKey(const Key('create_action_fab'));
      expect(createFab, findsOneWidget);
    });

    for (final returnWithBack in [false, true]) {
      testWidgets('reloads newly created exercise and keeps filters after '
          '${returnWithBack ? 'back' : 'Done'}', (tester) async {
        mockRepository.searchResults = _benchPressItem();
        final fixture = _ExerciseLibraryNavigationFixtures.app(mockRepository);
        addTearDown(fixture.router.dispose);
        await tester.pumpWidget(fixture.app);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Bench');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Chest').first);
        await tester.pumpAndSettle();
        final searchesBeforeCreate = mockRepository.searches.length;

        await tester.tap(find.byKey(const Key('create_action_fab')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('custom_exercise_name_text_field')),
          'Custom Bench Press',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final chest = find.byKey(
          const ValueKey('custom_exercise_muscle_chest'),
        );
        await tester.ensureVisible(chest);
        await tester.pumpAndSettle();
        await tester.tap(chest);
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const Key('custom_exercise_primary_action')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('custom_exercise_primary_action')),
        );
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.customExerciseSaved), findsOneWidget);

        await tester.tap(
          returnWithBack
              ? find.byKey(const Key('custom_exercise_back_action'))
              : find.text(AppStrings.done),
        );
        await tester.pumpAndSettle();

        expect(find.text('Custom Bench Press'), findsOneWidget);
        expect(mockRepository.searches.length, searchesBeforeCreate + 1);
        expect(mockRepository.searches.last.searchQuery, 'Bench');
        expect(mockRepository.searches.last.muscleGroup, BodymapBucket.chest);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Bench',
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('canceling exercise creation keeps existing library results', (
      tester,
    ) async {
      mockRepository.searchResults = _benchPressItem();
      final fixture = _ExerciseLibraryNavigationFixtures.app(mockRepository);
      addTearDown(fixture.router.dispose);
      await tester.pumpWidget(fixture.app);
      await tester.pumpAndSettle();
      final searchesBeforeCreate = mockRepository.searches.length;

      await tester.tap(find.byKey(const Key('create_action_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('custom_exercise_back_action')));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(mockRepository.searches.length, searchesBeforeCreate + 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses shell clearance for result and empty states', (
      tester,
    ) async {
      mockRepository.searchResults = _benchPressItem();
      await tester.pumpWidget(
        createTestApp(mockRepository, withBottomNavigation: true),
      );
      await tester.pumpAndSettle();

      final clearanceFinder = find.byKey(
        const ValueKey<String>('exercise_library_bottom_navigation_clearance'),
      );
      expect(
        tester.getSize(clearanceFinder).height,
        AppBottomNavigationScope.contentClearanceWithFloatingActionButton(
          tester.element(clearanceFinder),
          fallback: AppSpacing.xxxl * 2,
        ),
      );

      mockRepository.searchResults = [];
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(
        createTestApp(mockRepository, withBottomNavigation: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('No exercises found.'), findsOneWidget);
      expect(
        tester.getSize(clearanceFinder).height,
        AppBottomNavigationScope.contentClearanceWithFloatingActionButton(
          tester.element(clearanceFinder),
          fallback: AppSpacing.xxxl * 2,
        ),
      );
    });
  });
}
