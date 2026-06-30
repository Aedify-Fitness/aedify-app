import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  testWidgets('displays exercise name', (tester) async {
    final item = WorkoutHistoryExerciseItem(
      id: 'e1',
      exerciseId: 1,
      exerciseName: 'Bench Press',
      sortOrder: 0,
      sets: [
        WorkoutHistorySetItem(
          id: 's1',
          setIndex: 0,
          setType: SetType.working,
          completed: true,
          skipped: false,
          actualReps: 10,
          actualWeightKg: 100.0,
        ),
      ],
    );

    await tester.pumpWidget(_wrap(WorkoutHistoryExerciseCard(item: item)));

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text(AppStrings.historySetList), findsOneWidget);
    expect(find.text('10 reps'), findsOneWidget);
    expect(find.text('100.0 kg'), findsOneWidget);
  });

  testWidgets('displays exercise notes when present', (tester) async {
    final item = WorkoutHistoryExerciseItem(
      id: 'e1',
      exerciseId: 1,
      exerciseName: 'Bench Press',
      sortOrder: 0,
      sets: [],
      notes: 'Felt strong on these',
    );

    await tester.pumpWidget(_wrap(WorkoutHistoryExerciseCard(item: item)));

    expect(find.text('Felt strong on these'), findsOneWidget);
  });

  testWidgets('shows sets section even with zero sets', (tester) async {
    final item = WorkoutHistoryExerciseItem(
      id: 'e1',
      exerciseId: 1,
      exerciseName: 'Squat',
      sortOrder: 0,
      sets: [],
    );

    await tester.pumpWidget(_wrap(WorkoutHistoryExerciseCard(item: item)));

    expect(find.text('Squat'), findsOneWidget);
    // Sets header should not appear when there are no sets
    expect(find.text(AppStrings.historySetList), findsNothing);
  });
}
