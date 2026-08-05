import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_card.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  const _FakeExerciseRepository(this.items);

  final List<ExerciseListItem> items;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    final query = filters.searchQuery.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SheetLauncher extends ConsumerWidget {
  const _SheetLauncher({required this.onConfirmed});

  final ValueChanged<List<ExerciseReference>> onConfirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddExerciseBottomSheet(
              initialSelections: const [
                ExerciseReference(
                  exerciseId: 1,
                  name: 'Bench Press',
                  modality: 'strength',
                ),
              ],
              excludedExerciseIds: const [2],
              onSelectExercises: onConfirmed,
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  const items = [
    ExerciseListItem(
      id: 1,
      name: 'Bench Press',
      difficulty: null,
      muscleGroups: <BodymapBucket>{BodymapBucket.chest},
      modality: ExerciseModality.strength,
      equipment: null,
      isFavorite: false,
      isSubstitutedOut: false,
    ),
    ExerciseListItem(
      id: 2,
      name: 'Back Squat',
      difficulty: null,
      muscleGroups: <BodymapBucket>{BodymapBucket.quads},
      modality: ExerciseModality.strength,
      equipment: null,
      isFavorite: false,
      isSubstitutedOut: false,
    ),
    ExerciseListItem(
      id: 3,
      name: 'Deadlift',
      difficulty: null,
      muscleGroups: <BodymapBucket>{BodymapBucket.back},
      modality: ExerciseModality.strength,
      equipment: null,
      isFavorite: false,
      isSubstitutedOut: false,
    ),
  ];

  testWidgets('restores, excludes, clears, filters, and confirms selections', (
    tester,
  ) async {
    final confirmed = <ExerciseReference>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => _SheetLauncher(
            onConfirmed: (exercises) => confirmed.addAll(exercises),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.exerciseRepositoryProvider.overrideWithValue(
            const _FakeExerciseRepository(items),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(AddExerciseBottomSheet), findsOneWidget);
    expect(find.text('Back Squat'), findsNothing);
    expect(
      tester
          .widget<ExerciseCard>(
            find.widgetWithText(ExerciseCard, 'Bench Press'),
          )
          .isSelected,
      isTrue,
    );

    await tester.tap(find.text(AppStrings.filterClearAll));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ExerciseCard>(
            find.widgetWithText(ExerciseCard, 'Bench Press'),
          )
          .isSelected,
      isFalse,
    );

    final searchField = find.descendant(
      of: find.byType(AddExerciseBottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(searchField, 'dead');
    await tester.pumpAndSettle();
    expect(find.text('Bench Press'), findsNothing);
    expect(find.text('Deadlift'), findsOneWidget);

    await tester.tap(find.text('Deadlift'));
    await tester.pumpAndSettle();
    final confirm = find.widgetWithText(
      FilledButton,
      AppStrings.filterConfirmSelection(1),
    );
    await tester.ensureVisible(confirm);
    tester.widget<FilledButton>(confirm).onPressed!();
    await tester.pumpAndSettle();

    expect(confirmed.map((exercise) => exercise.exerciseId), [3]);
  });
}
