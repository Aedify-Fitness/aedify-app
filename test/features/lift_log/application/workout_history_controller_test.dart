import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  _FakeWorkoutHistoryRepository({this.shouldThrow = false});

  final bool shouldThrow;
  final sessions = <WorkoutHistoryListItem>[];

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    if (shouldThrow) throw Exception('Database error');
    return sessions;
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    return null;
  }
}

void main() {
  group('WorkoutHistoryController', () {
    ProviderContainer createContainer({bool shouldThrow = false}) {
      return ProviderContainer(
        overrides: [
          AppProviders.workoutHistoryRepositoryProvider.overrideWith(
            (ref) => _FakeWorkoutHistoryRepository(shouldThrow: shouldThrow),
          ),
        ],
      );
    }

    test('initial state is empty when no history', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutHistoryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.items, isEmpty);
      expect(state.errorCode, isNull);
      expect(state.isEmpty, isTrue);
    });

    test('loads completed sessions', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.workoutHistoryRepositoryProvider)
              as _FakeWorkoutHistoryRepository;

      repo.sessions.add(
        WorkoutHistoryListItem(
          sessionId: 's1',
          name: 'Test Session',
          source: SessionSource.standalone,
          completedAt: DateTime(2026, 6, 30),
          durationSeconds: 1800,
          exerciseCount: 5,
        ),
      );

      final controller = container.read(
        AppProviders.workoutHistoryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.items.length, equals(1));
      expect(state.items[0].name, equals('Test Session'));
    });

    test('handles load failure gracefully', () async {
      final container = createContainer(shouldThrow: true);
      final controller = container.read(
        AppProviders.workoutHistoryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.errorCode, isNotNull);
      expect(state.items, isEmpty);
    });

    test('reload refreshes state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutHistoryControllerProvider.notifier,
      );
      await controller.future;
      await controller.reload();
      final state = container
          .read(AppProviders.workoutHistoryControllerProvider)
          .requireValue;
      expect(state.isLoading, isFalse);
    });
  });
}
