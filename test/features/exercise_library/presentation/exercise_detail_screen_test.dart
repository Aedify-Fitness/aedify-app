import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDetailScreenRepository implements ExerciseRepository {
  ExerciseDetailViewData? detail;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async => [];

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    return detail;
  }

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {
    if (detail == null) return;
    detail = ExerciseDetailViewData(
      id: detail!.id,
      name: detail!.name,
      difficulty: detail!.difficulty,
      primaryMuscles: detail!.primaryMuscles,
      muscleGroups: detail!.muscleGroups,
      category: detail!.category,
      modality: detail!.modality,
      equipment: detail!.equipment,
      force: detail!.force,
      mechanic: detail!.mechanic,
      grips: detail!.grips,
      steps: detail!.steps,
      videos: detail!.videos,
      isFavorite: isFavorite,
      isSubstitutedOut: detail!.isSubstitutedOut,
    );
  }

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {
    if (detail == null) return;
    detail = ExerciseDetailViewData(
      id: detail!.id,
      name: detail!.name,
      difficulty: detail!.difficulty,
      primaryMuscles: detail!.primaryMuscles,
      muscleGroups: detail!.muscleGroups,
      category: detail!.category,
      modality: detail!.modality,
      equipment: detail!.equipment,
      force: detail!.force,
      mechanic: detail!.mechanic,
      grips: detail!.grips,
      steps: detail!.steps,
      videos: detail!.videos,
      isFavorite: detail!.isFavorite,
      isSubstitutedOut: isSubstitutedOut,
    );
  }

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

Widget createTestApp(ExerciseRepository repository, {int exerciseId = 1}) {
  return ProviderScope(
    overrides: [
      AppProviders.exerciseRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(home: ExerciseDetailScreen(exerciseId: exerciseId)),
  );
}

void main() {
  group('ExerciseDetailScreen', () {
    late _MockDetailScreenRepository mockRepository;

    setUp(() {
      mockRepository = _MockDetailScreenRepository();
      mockRepository.detail = ExerciseDetailViewData(
        id: 1,
        name: 'Bench Press',
        difficulty: 'intermediate',
        primaryMuscles: ['Chest', 'Triceps'],
        muscleGroups: ['Chest'],
        category: 'compound',
        modality: 'strength',
        equipment: 'barbell',
        force: 'push',
        mechanic: 'compound',
        grips: ['barbell'],
        steps: ['Step 1', 'Step 2'],
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
    });

    testWidgets('renders exercise metadata', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      // Name appears in AppBar title and body headline
      expect(find.text('Bench Press'), findsWidgets);
      expect(find.text('intermediate'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('barbell'), findsOneWidget);
      expect(find.text('push'), findsOneWidget);
    });

    testWidgets('renders steps in order', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
    });

    testWidgets('handles missing force/mechanic cleanly', (tester) async {
      mockRepository.detail = ExerciseDetailViewData(
        id: 1,
        name: 'Bench Press',
        difficulty: 'intermediate',
        primaryMuscles: ['Chest'],
        muscleGroups: ['Chest'],
        category: 'compound',
        modality: 'strength',
        equipment: 'barbell',
        force: null,
        mechanic: null,
        grips: [],
        steps: ['Step 1'],
        videos: [],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsWidgets);
    });

    testWidgets('renders video metadata', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('front'), findsOneWidget);
      expect(find.text('male'), findsOneWidget);
    });

    testWidgets('favorite toggle is shown', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byTooltip(AppStrings.toggleFavorite), findsOneWidget);
    });

    testWidgets('substituted toggle is shown', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byTooltip(AppStrings.toggleSubstitution), findsOneWidget);
    });

    testWidgets('renders video section with header', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideos), findsOneWidget);
    });

    testWidgets('shows no-video fallback when videos are empty', (
      tester,
    ) async {
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
        videos: [],
        isFavorite: false,
        isSubstitutedOut: false,
      );

      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noExerciseVideos), findsOneWidget);
    });

    testWidgets('instructions remain visible with videos', (tester) async {
      await tester.pumpWidget(createTestApp(mockRepository));
      await tester.pumpAndSettle();

      // Steps should be visible alongside video section
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text(AppStrings.exerciseVideos), findsOneWidget);
    });
  });
}
