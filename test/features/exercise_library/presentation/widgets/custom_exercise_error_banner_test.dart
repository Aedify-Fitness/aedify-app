import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createTestApp(CustomExerciseErrorBanner banner) {
  return MaterialApp(home: Scaffold(body: banner));
}

void main() {
  group('CustomExerciseErrorBanner', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseErrorBanner(message: 'Something went wrong.'),
        ),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseErrorBanner(message: 'Error.', onRetry: _noOp),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        _createTestApp(const CustomExerciseErrorBanner(message: 'Error.')),
      );

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseErrorBanner(
            message: 'Error.',
            onRetry: () => retried = true,
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}

void _noOp() {}
