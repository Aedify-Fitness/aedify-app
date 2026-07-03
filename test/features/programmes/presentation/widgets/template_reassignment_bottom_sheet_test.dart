import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';

Widget _wrap(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

Future<void> _openBottomSheet(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    _wrap(
      Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => child,
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
}

ProgrammeBuilderTemplateDraft _template(String id, String name) {
  return ProgrammeBuilderTemplateDraft(id: id, templateKey: id, name: name);
}

SavedWorkoutListItem _savedWorkout(String id, String name, int exerciseCount) {
  return SavedWorkoutListItem(
    id: id,
    name: name,
    status: SavedWorkoutStatus.active,
    exerciseCount: exerciseCount,
    updatedAt: DateTime(2025),
  );
}

void main() {
  group('TemplateReassignmentBottomSheet', () {
    testWidgets('shows assign workout title', (tester) async {
      await tester.pumpWidget(_wrap(const TemplateReassignmentBottomSheet()));
      expect(find.text(AppStrings.assignTemplate), findsOneWidget);
    });

    testWidgets('always shows create template button', (tester) async {
      await tester.pumpWidget(_wrap(const TemplateReassignmentBottomSheet()));
      expect(find.text(AppStrings.createTemplate), findsOneWidget);
    });

    testWidgets('create template tap pops with true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    builder: (_) => const TemplateReassignmentBottomSheet(),
                  );
                  expect(result, isTrue);
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
      await tester.ensureVisible(find.text(AppStrings.createTemplate));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(AppStrings.createTemplate),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('shows no saved workouts message when none provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TemplateReassignmentBottomSheet(savedWorkouts: [])),
      );
      expect(find.text(AppStrings.noSavedWorkoutsToImport), findsOneWidget);
    });

    testWidgets('shows saved workouts when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TemplateReassignmentBottomSheet(
            savedWorkouts: [_savedWorkout('sw-1', 'Upper Body A', 4)],
          ),
        ),
      );
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(find.text('4 exercises selected'), findsOneWidget);
    });

    testWidgets('calls onSelectSavedWorkout when saved workout is tapped', (
      tester,
    ) async {
      SavedWorkoutListItem? selected;
      await _openBottomSheet(
        tester,
        TemplateReassignmentBottomSheet(
          savedWorkouts: [_savedWorkout('sw-1', 'Upper Body A', 4)],
          onSelectSavedWorkout: (item) => selected = item,
        ),
      );
      await tester.ensureVisible(find.text('Upper Body A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upper Body A'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected?.id, 'sw-1');
    });

    testWidgets(
      'shows programme templates section header when templates exist',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            TemplateReassignmentBottomSheet(
              availableTemplates: [_template('t-1', 'Push Day')],
            ),
          ),
        );
        expect(find.text(AppStrings.programmeTemplates), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
      },
    );

    testWidgets('does not show programme templates section when none exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TemplateReassignmentBottomSheet(availableTemplates: [])),
      );
      expect(find.text(AppStrings.programmeTemplates), findsNothing);
    });

    testWidgets('shows both saved workouts and programme templates', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TemplateReassignmentBottomSheet(
            savedWorkouts: [_savedWorkout('sw-1', 'Upper Body A', 4)],
            availableTemplates: [_template('t-1', 'Push Day')],
          ),
        ),
      );
      expect(find.text(AppStrings.fromSavedWorkouts), findsOneWidget);
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(find.text(AppStrings.programmeTemplates), findsOneWidget);
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('calls onSelected when programme template is tapped', (
      tester,
    ) async {
      ProgrammeBuilderTemplateDraft? selected;
      await _openBottomSheet(
        tester,
        TemplateReassignmentBottomSheet(
          availableTemplates: [_template('t-1', 'Push Day')],
          onSelected: (template) => selected = template,
        ),
      );
      await tester.ensureVisible(find.text('Push Day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push Day'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selected?.name, 'Push Day');
    });
  });
}
