import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_superset_group_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: widget)),
  );
}

void main() {
  group('WorkoutHistorySupersetGroupCard', () {
    final group = SupersetGroupSummary(
      groupId: 'g1',
      memberIds: ['e1', 'e2'],
      memberCount: 2,
    );

    final exercises = [
      WorkoutHistoryExerciseItem(
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
        supersetGroupId: 'g1',
        supersetOrder: 0,
      ),
      WorkoutHistoryExerciseItem(
        id: 'e2',
        exerciseId: 2,
        exerciseName: 'Fly',
        sortOrder: 0,
        sets: [
          WorkoutHistorySetItem(
            id: 's2',
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
    ];

    testWidgets('renders superset label and exercise names', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutHistorySupersetGroupCard(group: group, exercises: exercises),
        ),
      );

      expect(find.text(AppStrings.supersetHistoryLabel), findsOneWidget);
      expect(find.text('2 ${AppStrings.exercisesLabel}'), findsOneWidget);
      expect(find.text(AppStrings.supersetRunnerHint), findsOneWidget);
      expect(find.text(AppStrings.exerciseNumberLabel(1)), findsOneWidget);
      expect(find.text(AppStrings.exerciseNumberLabel(2)), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Fly'), findsOneWidget);
    });

    testWidgets('renders set data for each exercise', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutHistorySupersetGroupCard(group: group, exercises: exercises),
        ),
      );

      expect(find.text('10 reps'), findsOneWidget);
      expect(find.text('100.0 kg'), findsOneWidget);
      expect(find.text('12 reps'), findsOneWidget);
      expect(find.text('30.0 kg'), findsOneWidget);
    });
  });
}
