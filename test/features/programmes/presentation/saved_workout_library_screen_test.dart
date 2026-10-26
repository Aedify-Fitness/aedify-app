import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/presentation/saved_workout_library_screen.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/shared/constants/app_strings.dart';
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
  Future<String> saveSavedWorkout(dynamic draft) async => '';

  @override
  Future<void> archiveSavedWorkout(String id) async {}

  @override
  Future<void> deleteSavedWorkout(String id) async {}
}

Widget _wrap(Widget widget) {
  return ProviderScope(
    overrides: [
      AppProviders.savedWorkoutRepositoryProvider.overrideWith(
        (ref) => _FakeSavedWorkoutRepository(),
      ),
    ],
    child: MaterialApp(home: widget),
  );
}

void main() {
  testWidgets('shows empty state when no saved workouts', (tester) async {
    await tester.pumpWidget(_wrap(const SavedWorkoutLibraryScreen()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noSavedWorkoutsYet), findsOneWidget);
    expect(find.text(AppStrings.noSavedWorkoutsYetHint), findsOneWidget);
  });
}
