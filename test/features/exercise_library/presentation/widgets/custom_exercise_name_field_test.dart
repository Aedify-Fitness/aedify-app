import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_name_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createTestApp(CustomExerciseNameField field) {
  return MaterialApp(home: Scaffold(body: field));
}

void main() {
  group('CustomExerciseNameField', () {
    testWidgets('renders with initial value and label', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseNameField(
            initialValue: 'Squat',
            onChanged: _onChanged,
          ),
        ),
      );

      expect(find.text(AppStrings.customExerciseName), findsOneWidget);
      expect(find.text(AppStrings.customExerciseNameHint), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseNameField(
            initialValue: '',
            onChanged: _onChanged,
            errorText: 'Name is required.',
          ),
        ),
      );

      expect(find.text('Name is required.'), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseNameField(
            initialValue: '',
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Deadlift');
      await tester.pump();

      expect(changedValue, 'Deadlift');
    });

    testWidgets('displays empty initial value when empty string given', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseNameField(
            initialValue: '',
            onChanged: _onChanged,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });
  });
}

void _onChanged(String value) {}
