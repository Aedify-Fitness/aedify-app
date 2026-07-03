import 'package:aedify/features/exercise_library/presentation/widgets/delete_custom_exercise_dialog.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _createDialogApp(DeleteCustomExerciseDialog dialog) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
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
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
  );
}

void main() {
  group('DeleteCustomExerciseDialog', () {
    testWidgets('renders title and action buttons', (tester) async {
      await tester.pumpWidget(
        _createDialogApp(DeleteCustomExerciseDialog(onConfirm: () {})),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.customExerciseDeleteConfirm), findsWidgets);
      expect(find.text(AppStrings.cancel), findsOneWidget);
      expect(find.text(AppStrings.customExerciseDelete), findsOneWidget);
    });

    testWidgets('calls onConfirm when delete button is tapped', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        _createDialogApp(
          DeleteCustomExerciseDialog(onConfirm: () => confirmed = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.customExerciseDelete));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('dismisses dialog when cancel button is tapped', (
      tester,
    ) async {
      bool confirmed = false;
      await tester.pumpWidget(
        _createDialogApp(
          DeleteCustomExerciseDialog(onConfirm: () => confirmed = true),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(find.text(AppStrings.customExerciseDeleteConfirm), findsNothing);
    });
  });
}
