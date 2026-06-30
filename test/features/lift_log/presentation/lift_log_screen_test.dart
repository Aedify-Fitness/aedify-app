import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/presentation/lift_log_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async {
    return [];
  }

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async {
    return null;
  }
}

Widget _wrap(Widget widget) {
  return ProviderScope(
    overrides: [
      AppProviders.workoutHistoryRepositoryProvider.overrideWith(
        (ref) => _FakeWorkoutHistoryRepository(),
      ),
    ],
    child: MaterialApp(home: widget),
  );
}

void main() {
  testWidgets('shows empty state when no workout history', (tester) async {
    await tester.pumpWidget(_wrap(const LiftLogScreen()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noWorkoutHistoryYet), findsOneWidget);
    expect(find.text(AppStrings.noWorkoutHistoryYetHint), findsOneWidget);
  });
}
