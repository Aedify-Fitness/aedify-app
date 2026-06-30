import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: widget),
  );
}

void main() {
  final baseSet = WorkoutRunnerSetItem(
    id: 'set-1',
    exerciseId: 1,
    setIndex: 0,
    setType: SetType.working,
    performedAt: DateTime(2025, 6, 1),
    completed: false,
    skipped: false,
    prescribedRepsMin: 8,
    prescribedRepsMax: 12,
    prescribedWeightKg: 60.0,
  );

  group('WorkoutRunnerSetRow', () {
    testWidgets('displays set index and type', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
      expect(find.text(AppStrings.workingSet), findsOneWidget);
    });

    testWidgets('displays prescribed reps label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text('8-12 reps'), findsOneWidget);
    });

    testWidgets('calls onToggleCompleted when check circle is tapped', (
      tester,
    ) async {
      bool toggled = false;
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (_) {},
            onToggleCompleted: (v) => toggled = v,
            onToggleSkipped: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(toggled, isTrue);
    });

    testWidgets('completed set shows different styling', (tester) async {
      final completedSet = baseSet.copyWith(completed: true);
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: completedSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
    });

    testWidgets('warmup set shows warmup label', (tester) async {
      final warmupSet = baseSet.copyWith(setType: SetType.warmup);
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: warmupSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text(AppStrings.warmupSet), findsOneWidget);
      expect(find.text(AppStrings.workingSet), findsNothing);
    });

    testWidgets('skipped set shows skipped label', (tester) async {
      final skippedSet = baseSet.copyWith(skipped: true);
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: skippedSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text(AppStrings.skipped), findsOneWidget);
    });

    testWidgets('equal min/max reps shows single value', (tester) async {
      final equalSet = baseSet.copyWith(
        prescribedRepsMin: 10,
        prescribedRepsMax: 10,
      );
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: equalSet,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text('10 reps'), findsOneWidget);
    });

    testWidgets('weight input fires onChanged', (tester) async {
      WorkoutRunnerSetItem? captured;
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (v) => captured = v,
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, AppStrings.weightLabel),
        '70.0',
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.actualWeightKg, 70.0);
    });

    testWidgets('reps input fires onChanged', (tester) async {
      WorkoutRunnerSetItem? captured;
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (v) => captured = v,
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, AppStrings.repsLabel),
        '12',
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.actualReps, 12);
    });

    testWidgets('RPE dropdown fires onChanged', (tester) async {
      WorkoutRunnerSetItem? captured;
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (v) => captured = v,
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('rpe_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8').last);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.actualRpe, 8.0);
    });

    testWidgets('notes input fires onChanged', (tester) async {
      WorkoutRunnerSetItem? captured;
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: baseSet,
            onChanged: (v) => captured = v,
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, AppStrings.setNotes),
        'Felt heavy',
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.notes, 'Felt heavy');
    });

    testWidgets('no prescribed reps shows no label', (tester) async {
      final noPrescribed = WorkoutRunnerSetItem(
        id: baseSet.id,
        exerciseId: baseSet.exerciseId,
        setIndex: baseSet.setIndex,
        setType: baseSet.setType,
        performedAt: baseSet.performedAt,
        completed: baseSet.completed,
        skipped: baseSet.skipped,
      );
      await tester.pumpWidget(
        _wrap(
          WorkoutRunnerSetRow(
            set: noPrescribed,
            onChanged: (_) {},
            onToggleCompleted: (_) {},
            onToggleSkipped: (_) {},
          ),
        ),
      );

      expect(find.text('8-12 reps'), findsNothing);
    });
  });
}
