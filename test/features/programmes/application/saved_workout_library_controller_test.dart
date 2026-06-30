import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSavedWorkoutRepository implements SavedWorkoutRepository {
  _FakeSavedWorkoutRepository({this.shouldThrow = false});

  final bool shouldThrow;
  final workouts = <SavedWorkoutAggregate>[];
  String? lastArchivedId;
  String? lastDeletedId;

  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async => null;

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    if (shouldThrow) throw Exception('Database error');
    return workouts;
  }

  @override
  Future<String> saveSavedWorkout(dynamic draft) async => '';

  @override
  Future<void> archiveSavedWorkout(String id) async {
    lastArchivedId = id;
  }

  @override
  Future<void> deleteSavedWorkout(String id) async {
    lastDeletedId = id;
  }
}

void main() {
  group('SavedWorkoutLibraryController', () {
    ProviderContainer createContainer({bool shouldThrow = false}) {
      return ProviderContainer(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) => _FakeSavedWorkoutRepository(shouldThrow: shouldThrow),
          ),
        ],
      );
    }

    test('initial state is empty when no saved workouts', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.savedWorkoutLibraryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.items, isEmpty);
      expect(state.errorCode, isNull);
    });

    test('archiveWorkout calls repository', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.savedWorkoutRepositoryProvider)
              as _FakeSavedWorkoutRepository;

      await container
          .read(AppProviders.savedWorkoutLibraryControllerProvider.notifier)
          .archiveWorkout('w1');

      expect(repo.lastArchivedId, equals('w1'));
    });

    test('deleteWorkout calls repository', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.savedWorkoutRepositoryProvider)
              as _FakeSavedWorkoutRepository;

      await container
          .read(AppProviders.savedWorkoutLibraryControllerProvider.notifier)
          .deleteWorkout('w1');

      expect(repo.lastDeletedId, equals('w1'));
    });

    test('handles load failure gracefully', () async {
      final container = createContainer(shouldThrow: true);
      final controller = container.read(
        AppProviders.savedWorkoutLibraryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.errorCode, isNotNull);
      expect(state.items, isEmpty);
    });
  });
}
