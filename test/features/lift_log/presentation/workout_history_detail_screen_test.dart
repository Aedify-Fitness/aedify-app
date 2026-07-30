import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/presentation/workout_history_detail_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  const _FakeWorkoutHistoryRepository(this.detail);

  final WorkoutHistoryDetailViewData? detail;

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    return detail;
  }

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async => [];
}

Widget _wrap(WorkoutHistoryDetailViewData? detail) {
  final router = GoRouter(
    initialLocation: '/history/session-1',
    routes: [
      GoRoute(
        path: '/history/:sessionId',
        builder: (context, state) => WorkoutHistoryDetailScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      AppProviders.workoutHistoryRepositoryProvider.overrideWith(
        (ref) => _FakeWorkoutHistoryRepository(detail),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
  );
}

void main() {
  testWidgets('renders the session summary hero without a standard AppBar', (
    tester,
  ) async {
    final detail = WorkoutHistoryDetailViewData(
      sessionId: 'session-1',
      name: 'Upper Strength',
      source: SessionSource.savedWorkout,
      startedAt: DateTime(2026, 7, 24, 9),
      completedAt: DateTime(2026, 7, 24, 10, 5),
      durationSeconds: 3900,
      notes: 'Moved well and kept every rep controlled.',
      energyLevel: 7,
      perceivedDifficulty: 8,
      exercises: const [
        WorkoutHistoryExerciseItem(
          id: 'exercise-1',
          exerciseId: 1,
          exerciseName: 'Bench Press',
          sortOrder: 0,
          sets: [],
        ),
        WorkoutHistoryExerciseItem(
          id: 'exercise-2',
          exerciseId: 2,
          exerciseName: 'Barbell Row',
          sortOrder: 1,
          sets: [],
        ),
      ],
    );

    await tester.pumpWidget(_wrap(detail));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Upper Strength'), findsOneWidget);
    expect(find.text(AppStrings.sourceSavedWorkout), findsOneWidget);
    expect(find.text('${AppStrings.completedOn}: 2026-07-24'), findsOneWidget);
    expect(find.text('1h 5m'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(
      find.text('Moved well and kept every rep controlled.'),
      findsOneWidget,
    );
    expect(find.text('${AppStrings.performance}: 7'), findsOneWidget);
    expect(find.text('${AppStrings.filterDifficulty}: 8'), findsOneWidget);
  });

  testWidgets('renders a deliberate missing-session state', (tester) async {
    await tester.pumpWidget(_wrap(null));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.missingSession), findsOneWidget);
  });
}
