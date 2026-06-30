import 'package:aedify/features/exercise_library/presentation/widgets/discard_custom_exercise_changes_dialog.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createDialogApp(DiscardCustomExerciseChangesDialog dialog) {
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
  group('DiscardCustomExerciseChangesDialog', () {
    testWidgets('renders title, message and action buttons', (tester) async {
      await tester.pumpWidget(
        _createDialogApp(DiscardCustomExerciseChangesDialog(onDiscard: () {})),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.customExerciseUnsavedChanges), findsWidgets);
      expect(
        find.text(AppStrings.customExerciseUnsavedChangesMessage),
        findsOneWidget,
      );
      expect(find.text(AppStrings.cancel), findsOneWidget);
      expect(find.text(AppStrings.customExerciseDiscard), findsOneWidget);
    });

    testWidgets('calls onDiscard when discard button is tapped', (
      tester,
    ) async {
      bool discarded = false;
      await tester.pumpWidget(
        _createDialogApp(
          DiscardCustomExerciseChangesDialog(onDiscard: () => discarded = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.customExerciseDiscard));
      await tester.pumpAndSettle();

      expect(discarded, isTrue);
    });

    testWidgets('dismisses dialog when cancel button is tapped', (
      tester,
    ) async {
      bool discarded = false;
      await tester.pumpWidget(
        _createDialogApp(
          DiscardCustomExerciseChangesDialog(onDiscard: () => discarded = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(discarded, isFalse);
      expect(find.text(AppStrings.customExerciseUnsavedChanges), findsNothing);
    });
  });
}
