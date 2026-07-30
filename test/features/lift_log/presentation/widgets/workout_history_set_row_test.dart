import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_set_row.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  group('WorkoutHistorySetRow', () {
    testWidgets('renders completed working set', (tester) async {
      final item = WorkoutHistorySetItem(
        id: 's1',
        setIndex: 0,
        setType: SetType.working,
        completed: true,
        skipped: false,
        prescribedRepsMin: 8,
        prescribedRepsMax: 10,
        prescribedWeightKg: 90.0,
        actualReps: 10,
        actualWeightKg: 100.0,
      );

      await tester.pumpWidget(_wrap(WorkoutHistorySetRow(item: item)));

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
      expect(find.text(AppStrings.workingSet), findsOneWidget);
      expect(find.text(AppStrings.completed), findsOneWidget);
      expect(find.text(AppStrings.actual), findsOneWidget);
      expect(find.text('10 reps'), findsOneWidget);
      expect(find.text('100.0 kg'), findsOneWidget);
      expect(find.text(AppStrings.planned), findsOneWidget);
      expect(find.text('8-10 reps'), findsOneWidget);
      expect(find.text('90.0 kg'), findsOneWidget);
      expect(find.text(AppStrings.warmupSet), findsNothing);
    });

    testWidgets('renders completed warmup set with warmup label', (
      tester,
    ) async {
      final item = WorkoutHistorySetItem(
        id: 's2',
        setIndex: 0,
        setType: SetType.warmup,
        completed: true,
        skipped: false,
        actualReps: 8,
        actualWeightKg: 50.0,
      );

      await tester.pumpWidget(_wrap(WorkoutHistorySetRow(item: item)));

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
      expect(find.text('8 reps'), findsOneWidget);
      expect(find.text('50.0 kg'), findsOneWidget);
      expect(find.text(AppStrings.warmupSet), findsOneWidget);
    });

    testWidgets('renders skipped warmup set', (tester) async {
      final item = WorkoutHistorySetItem(
        id: 's3',
        setIndex: 0,
        setType: SetType.warmup,
        completed: false,
        skipped: true,
        actualReps: null,
        actualWeightKg: null,
      );

      await tester.pumpWidget(_wrap(WorkoutHistorySetRow(item: item)));

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
      expect(find.text(AppStrings.skipped), findsOneWidget);
      expect(find.text(AppStrings.warmupSet), findsOneWidget);
    });

    testWidgets('renders working set with an explicit working label', (
      tester,
    ) async {
      final item = WorkoutHistorySetItem(
        id: 's4',
        setIndex: 0,
        setType: SetType.working,
        completed: true,
        skipped: false,
        actualReps: 12,
        actualWeightKg: 80.0,
      );

      await tester.pumpWidget(_wrap(WorkoutHistorySetRow(item: item)));

      expect(find.text(AppStrings.setNumberLabel(1)), findsOneWidget);
      expect(find.text('12 reps'), findsOneWidget);
      expect(find.text('80.0 kg'), findsOneWidget);
      expect(find.text(AppStrings.workingSet), findsOneWidget);
      expect(find.text(AppStrings.warmupSet), findsNothing);
    });

    testWidgets('renders incomplete state explicitly', (tester) async {
      final item = WorkoutHistorySetItem(
        id: 's5',
        setIndex: 1,
        setType: SetType.working,
        completed: false,
        skipped: false,
        prescribedRepsMin: 6,
        prescribedRepsMax: 6,
      );

      await tester.pumpWidget(_wrap(WorkoutHistorySetRow(item: item)));

      expect(find.text(AppStrings.setNumberLabel(2)), findsOneWidget);
      expect(find.text(AppStrings.inProgressLabel), findsOneWidget);
      expect(find.text('6 reps'), findsOneWidget);
    });
  });
}
