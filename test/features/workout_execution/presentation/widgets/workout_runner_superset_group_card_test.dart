import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_superset_group_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/superset_group_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(
      body: SingleChildScrollView(child: SizedBox(width: 400, child: widget)),
    ),
  );
}

void main() {
  group('WorkoutRunnerSupersetGroupCard', () {
    final group = SupersetGroupSummary(
      groupId: 'g1',
      memberIds: ['e1', 'e2'],
      memberCount: 2,
    );

    final exercises = [
      WorkoutRunnerExerciseItem(
        id: 'e1',
        exerciseId: 1,
        exerciseName: 'Bench Press',
        sortOrder: 0,
        sets: [
          WorkoutRunnerSetItem(
            id: 's1',
            exerciseId: 1,
            setIndex: 0,
            setType: SetType.working,
            performedAt: DateTime.now(),
            completed: false,
            skipped: false,
            prescribedRepsMin: 8,
            prescribedRepsMax: 12,
            prescribedWeightKg: 60.0,
          ),
        ],
        supersetGroupId: 'g1',
        supersetOrder: 0,
      ),
      WorkoutRunnerExerciseItem(
        id: 'e2',
        exerciseId: 2,
        exerciseName: 'Fly',
        sortOrder: 0,
        sets: [
          WorkoutRunnerSetItem(
            id: 's2',
            exerciseId: 2,
            setIndex: 0,
            setType: SetType.working,
            performedAt: DateTime.now(),
            completed: false,
            skipped: false,
            prescribedRepsMin: 10,
            prescribedRepsMax: 10,
          ),
        ],
        supersetGroupId: 'g1',
        supersetOrder: 1,
      ),
    ];

    testWidgets('renders group label and exercise names', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSupersetGroupCard(
            group: group,
            exercises: exercises,
            onUpdateSet: (e, s, set) {},
            onToggleSetCompleted: (e, s, c) {},
            onToggleSetSkipped: (e, s, s2) {},
          ),
        ),
      );

      expect(find.text(AppStrings.supersetGroup), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Fly'), findsOneWidget);
    });

    testWidgets('renders runner hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSupersetGroupCard(
            group: group,
            exercises: exercises,
            onUpdateSet: (e, s, set) {},
            onToggleSetCompleted: (e, s, c) {},
            onToggleSetSkipped: (e, s, s2) {},
          ),
        ),
      );

      expect(find.text(AppStrings.supersetRunnerHint), findsOneWidget);
    });

    testWidgets('renders set rows for each exercise', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSupersetGroupCard(
            group: group,
            exercises: exercises,
            onUpdateSet: (e, s, set) {},
            onToggleSetCompleted: (e, s, c) {},
            onToggleSetSkipped: (e, s, s2) {},
          ),
        ),
      );

      expect(find.text(AppStrings.setNumberLabel(1)), findsNWidgets(2));
    });
  });
}
