import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/presentation/lift_log_screen.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_list_tile.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  _FakeWorkoutHistoryRepository({
    this.sessions = const [],
    this.shouldThrow = false,
  });

  final List<WorkoutHistoryListItem> sessions;
  final bool shouldThrow;

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    if (shouldThrow) throw StateError('Failed to load history');
    return sessions;
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    return null;
  }
}

Widget _wrap(Widget widget, {_FakeWorkoutHistoryRepository? repository}) {
  return ProviderScope(
    overrides: [
      AppProviders.workoutHistoryRepositoryProvider.overrideWith(
        (ref) => repository ?? _FakeWorkoutHistoryRepository(),
      ),
    ],
    child: MaterialApp(home: widget),
  );
}

void main() {
  testWidgets('shows empty state when no workout history', (tester) async {
    await tester.pumpWidget(_wrap(const LiftLogScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.text(AppStrings.liftLog), findsOneWidget);
    expect(find.text(AppStrings.completedWorkouts), findsOneWidget);
    expect(find.text(AppStrings.noWorkoutHistoryYet), findsOneWidget);
    expect(find.text(AppStrings.noWorkoutHistoryYetHint), findsOneWidget);
  });

  testWidgets('shows completed sessions as rich history cards', (tester) async {
    final repository = _FakeWorkoutHistoryRepository(
      sessions: [
        WorkoutHistoryListItem(
          sessionId: 'session-1',
          name: 'Upper Body Strength',
          source: SessionSource.program,
          completedAt: DateTime(2026, 7, 20),
          durationSeconds: 3900,
          exerciseCount: 5,
          programName: 'Strength Base',
        ),
      ],
    );

    await tester.pumpWidget(
      _wrap(const LiftLogScreen(), repository: repository),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutHistoryListTile), findsOneWidget);
    expect(find.byType(AppBadge), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('Upper Body Strength'), findsOneWidget);
    expect(find.text(AppStrings.sourceProgramme), findsOneWidget);
    expect(
      find.text(DateFormat.yMMMd().format(DateTime(2026, 7, 20))),
      findsOneWidget,
    );
    expect(find.text('1h 5m'), findsOneWidget);
    expect(find.text('5 ${AppStrings.historyExerciseList}'), findsOneWidget);
    expect(find.text(AppStrings.totalVolume), findsNothing);
  });

  testWidgets('shows inline retry state when history fails to load', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const LiftLogScreen(),
        repository: _FakeWorkoutHistoryRepository(shouldThrow: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HistoryErrorBanner), findsOneWidget);
    expect(find.text(AppStrings.workoutHistoryLoadFailed), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
    expect(find.text(AppStrings.liftLog), findsOneWidget);
  });
}
