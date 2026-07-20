import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createTestApp(CustomExerciseStepsEditor editor) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: editor)),
  );
}

void main() {
  group('CustomExerciseStepsEditor', () {
    testWidgets('shows empty state when no steps', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseStepsEditor(
            steps: [],
            onAddStep: _noOp,
            onUpdateStep: _noOpUpdate,
            onRemoveStep: _noOpRemove,
          ),
        ),
      );

      expect(find.text(AppStrings.customExerciseAddStep), findsOneWidget);
    });

    testWidgets('renders step text fields and remove buttons', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseStepsEditor(
            steps: ['Step one', 'Step two'],
            onAddStep: _noOp,
            onUpdateStep: _noOpUpdate,
            onRemoveStep: _noOpRemove,
          ),
        ),
      );

      expect(find.text('Step one'), findsOneWidget);
      expect(find.text('Step two'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(IconButton), findsNWidgets(4));
      expect(find.text(AppStrings.customExerciseAddStep), findsOneWidget);
    });

    testWidgets('calls onAddStep when add button is tapped', (tester) async {
      bool added = false;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseStepsEditor(
            steps: const ['Step one'],
            onAddStep: () => added = true,
            onUpdateStep: _noOpUpdate,
            onRemoveStep: _noOpRemove,
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.customExerciseAddStep));
      await tester.pump();

      expect(added, isTrue);
    });

    testWidgets('calls onRemoveStep when remove button is tapped', (
      tester,
    ) async {
      int? removedIndex;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseStepsEditor(
            steps: const ['Step one', 'Step two'],
            onAddStep: _noOp,
            onUpdateStep: _noOpUpdate,
            onRemoveStep: (index) => removedIndex = index,
          ),
        ),
      );

      final removeButtons = find.byType(IconButton);
      await tester.tap(removeButtons.first);
      await tester.pump();

      expect(removedIndex, 0);
    });

    testWidgets('calls onUpdateStep when step text changes', (tester) async {
      String? updatedValue;
      int? updatedIndex;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseStepsEditor(
            steps: const ['Original'],
            onAddStep: _noOp,
            onUpdateStep: (index, value) {
              updatedIndex = index;
              updatedValue = value;
            },
            onRemoveStep: _noOpRemove,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Updated step');
      await tester.pump();

      expect(updatedIndex, 0);
      expect(updatedValue, 'Updated step');
    });
  });
}

void _noOp() {}
void _noOpUpdate(int index, String value) {}
void _noOpRemove(int index) {}
