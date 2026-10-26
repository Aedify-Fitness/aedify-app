import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/presentation/workout_builder_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSavedWorkoutRepository implements SavedWorkoutRepository {
  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async => null;

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    return [];
  }

  @override
  Future<String> saveSavedWorkout(dynamic draft) async => 'saved-id';

  @override
  Future<void> archiveSavedWorkout(String id) async {}

  @override
  Future<void> deleteSavedWorkout(String id) async {}
}

class _FakeExerciseRepository implements ExerciseRepository {
  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    return [
      const ExerciseListItem(
        id: 100,
        name: 'Bench Press',
        modality: ExerciseModality.strength,
        equipment: EquipmentTag.barbell,
        difficulty: ExerciseDifficulty.intermediate,
        muscleGroups: {BodymapBucket.chest},
        isFavorite: false,
        isSubstitutedOut: false,
        isCustom: false,
      ),
    ];
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
  Future<int> createCustomExercise(CustomExerciseSeed seed) async => 0;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

void main() {
  testWidgets('create workout, add exercise, name it, and save', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) => _FakeSavedWorkoutRepository(),
          ),
          AppProviders.exerciseRepositoryProvider.overrideWith(
            (ref) => _FakeExerciseRepository(),
          ),
        ],
        child: const MaterialApp(home: WorkoutBuilderScreen.create()),
      ),
    );

    // Initial loading completes
    await tester.pumpAndSettle();

    // Verify initial state: header title and name field
    expect(find.text(AppStrings.createNewWorkout), findsOneWidget);
    expect(find.text(AppStrings.workoutNameHint), findsOneWidget);
    final nameField = find.widgetWithText(
      TextField,
      AppStrings.workoutNameHint,
    );
    expect(nameField, findsOneWidget);

    // Type a workout name
    await tester.enterText(nameField, 'Push Day');
    await tester.pump();

    // Scroll to find and tap the Add Exercise button
    final addExerciseFinder = find.text(AppStrings.addExercise);
    await tester.ensureVisible(addExerciseFinder);
    await tester.pump();
    await tester.tap(addExerciseFinder);
    await tester.pump();
    await tester.pump();

    // Bottom sheet opens with exercise list
    expect(find.text('Bench Press'), findsOneWidget);

    // Dismiss the bottom sheet by tapping the barrier (Navigator.pop)
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pump();
    await tester.pump();

    // Exercise should be added — verify via controller state
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutBuilderScreen)),
    );
    final state = container.read(
      AppProviders.workoutBuilderControllerProvider((
        mode: WorkoutBuilderMode.create,
        savedWorkoutId: null,
      )),
    );

    expect(state.asData?.value.draft.name, equals('Push Day'));
    expect(state.asData?.value.isDirty, isTrue);
  });
}
