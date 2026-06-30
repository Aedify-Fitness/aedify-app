import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
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

    test('preserves superset group context in detail', () async {
      final detail = WorkoutHistoryDetailViewData(
        sessionId: 's1',
        name: 'Grouped Session',
        source: SessionSource.savedWorkout,
        startedAt: DateTime(2026, 6, 30, 10, 0),
        completedAt: DateTime(2026, 6, 30, 11, 0),
        durationSeconds: 3600,
        exercises: [
          WorkoutHistoryExerciseItem(
            id: 'e1',
            exerciseId: 1,
            exerciseName: 'Bench Press',
            sortOrder: 0,
            sets: [
              WorkoutHistorySetItem(
                id: 'set1',
                setIndex: 0,
                setType: SetType.working,
                completed: true,
                skipped: false,
                actualReps: 10,
                actualWeightKg: 100.0,
              ),
            ],
            supersetGroupId: 'g1',
            supersetOrder: 0,
          ),
          WorkoutHistoryExerciseItem(
            id: 'e2',
            exerciseId: 2,
            exerciseName: 'Fly',
            sortOrder: 1,
            sets: [
              WorkoutHistorySetItem(
                id: 'set2',
                setIndex: 0,
                setType: SetType.working,
                completed: true,
                skipped: false,
                actualReps: 12,
                actualWeightKg: 30.0,
              ),
            ],
            supersetGroupId: 'g1',
            supersetOrder: 1,
          ),
        ],
      );

      final container = createContainer(detail: detail);
      final controller = container.read(
        AppProviders.workoutHistoryDetailControllerProvider('s1').notifier,
      );
      final state = await controller.future;

      expect(state.item, isNotNull);
      expect(state.item!.exercises.length, equals(2));
      expect(state.item!.exercises[0].supersetGroupId, equals('g1'));
      expect(state.item!.exercises[0].supersetOrder, equals(0));
      expect(state.item!.exercises[1].supersetGroupId, equals('g1'));
      expect(state.item!.exercises[1].supersetOrder, equals(1));
    });
  });
}
