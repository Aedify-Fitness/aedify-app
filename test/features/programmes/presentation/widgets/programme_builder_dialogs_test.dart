import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/presentation/widgets/add_week_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/discard_programme_changes_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/active_programme_warning_dialog.dart';
import 'package:aedify/shared/constants/app_strings.dart';

Future<bool?> _showDialog(WidgetTester tester, Widget dialog) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (_) => dialog,
              );
            },
            child: const Text('Open'),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump();
  return result;
}

void main() {
  group('AddWeekDialog', () {
    testWidgets('displays add week title', (tester) async {
      await _showDialog(tester, const AddWeekDialog());
      expect(find.text(AppStrings.addWeek), findsWidgets);
    });

    testWidgets('returns true when add button is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const AddWeekDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, AppStrings.addWeek));
      await tester.pump();
      await tester.pump();
      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const AddWeekDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pump();
      await tester.pump();
      expect(result, isFalse);
    });
  });

  group('DiscardProgrammeChangesDialog', () {
    testWidgets('displays discard warning', (tester) async {
      await _showDialog(tester, const DiscardProgrammeChangesDialog());
      expect(find.text(AppStrings.unsavedProgrammeChanges), findsWidgets);
    });

    testWidgets('returns true when discard is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const DiscardProgrammeChangesDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(
        find.widgetWithText(TextButton, AppStrings.discardProgrammeChanges),
      );
      await tester.pump();
      await tester.pump();
      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const DiscardProgrammeChangesDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pump();
      await tester.pump();
      expect(result, isFalse);
    });
  });

  group('ActiveProgrammeWarningDialog', () {
    testWidgets('displays warning', (tester) async {
      await _showDialog(tester, const ActiveProgrammeWarningDialog());
      expect(find.text(AppStrings.activeProgrammeWarning), findsWidgets);
    });

    testWidgets('returns true when continue is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const ActiveProgrammeWarningDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.pump();
      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const ActiveProgrammeWarningDialog(),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pump();
      await tester.pump();
      expect(result, isFalse);
    });
  });
}
