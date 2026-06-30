import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  _FakeWorkoutHistoryRepository({this.shouldThrow = false, this.detail});

  final bool shouldThrow;
  final WorkoutHistoryDetailViewData? detail;

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    return [];
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    if (shouldThrow) throw Exception('Database error');
    return detail;
  }
}

void main() {
  group('WorkoutHistoryDetailController', () {
    ProviderContainer createContainer({
      bool shouldThrow = false,
      WorkoutHistoryDetailViewData? detail,
    }) {
      return ProviderContainer(
        overrides: [
          AppProviders.workoutHistoryRepositoryProvider.overrideWith(
            (ref) => _FakeWorkoutHistoryRepository(
              shouldThrow: shouldThrow,
              detail: detail,
            ),
          ),
        ],
      );
    }

    test('loads session detail', () async {
      final detail = WorkoutHistoryDetailViewData(
        sessionId: 's1',
        name: 'Test Session',
        source: SessionSource.standalone,
        startedAt: DateTime(2026, 6, 30, 10, 0),
        exercises: [],
        completedAt: DateTime(2026, 6, 30, 11, 0),
        durationSeconds: 3600,
      );

      final container = createContainer(detail: detail);
      final controller = container.read(
        AppProviders.workoutHistoryDetailControllerProvider('s1').notifier,
      );
      final state = await controller.future;

      expect(state.item, isNotNull);
      expect(state.item!.name, equals('Test Session'));
      expect(state.item!.durationSeconds, equals(3600));
    });

    test('returns null-item state for missing session', () async {
      final container = createContainer(detail: null);
      final controller = container.read(
        AppProviders.workoutHistoryDetailControllerProvider(
          'nonexistent',
        ).notifier,
      );
      final state = await controller.future;

      expect(state.item, isNull);
      expect(state.errorCode, isNull);
    });

    test('handles load failure gracefully', () async {
      final container = createContainer(shouldThrow: true);
      final controller = container.read(
        AppProviders.workoutHistoryDetailControllerProvider('s1').notifier,
      );
      final state = await controller.future;

      expect(state.errorCode, isNotNull);
      expect(state.item, isNull);
    });
  });
}
