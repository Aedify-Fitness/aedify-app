import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/cancel_workout_dialog.dart';
import 'package:aedify/shared/constants/app_strings.dart';

void _onConfirm() {}

Widget _createDialogApp(CancelWorkoutDialog dialog) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () =>
                showDialog(context: context, builder: (_) => dialog),
            child: const Text('Show'),
          );
        },
      ),
    ),
  );
}

void main() {
  group('CancelWorkoutDialog', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(
        _createDialogApp(CancelWorkoutDialog(onConfirm: _onConfirm)),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cancelWorkout), findsWidgets);
      expect(find.text(AppStrings.cancelWorkoutMessage), findsOneWidget);
    });

    testWidgets('calls onConfirm when confirm button is tapped', (
      tester,
    ) async {
      bool confirmed = false;
      await tester.pumpWidget(
        _createDialogApp(
          CancelWorkoutDialog(onConfirm: () => confirmed = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancelWorkout).last);
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('dismisses dialog when cancel button is tapped', (
      tester,
    ) async {
      bool confirmed = false;
      await tester.pumpWidget(
        _createDialogApp(
          CancelWorkoutDialog(onConfirm: () => confirmed = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(find.text(AppStrings.cancelWorkoutMessage), findsNothing);
    });
  });
}
