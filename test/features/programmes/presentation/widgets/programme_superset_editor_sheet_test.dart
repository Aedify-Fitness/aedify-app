import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_superset_editor_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  _Harness._();

  static Widget wrap(Widget widget, {bool dark = false, double scale = 1}) =>
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: widget),
      );

  static void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
}

void main() {
  group('ProgrammeSupersetEditorSheet', () {
    final exercises = [
      ProgrammeExerciseDraft(
        id: 'e1',
        exerciseId: 1,
        sortOrder: 0,
        sets: [],
        exerciseRef: 'Bench Press',
      ),
      ProgrammeExerciseDraft(
        id: 'e2',
        exerciseId: 2,
        sortOrder: 1,
        sets: [],
        exerciseRef: 'Fly',
      ),
      ProgrammeExerciseDraft(
        id: 'e3',
        exerciseId: 3,
        sortOrder: 2,
        sets: [],
        exerciseRef: 'Press',
      ),
    ];

    testWidgets(
      'selection updates count, execution order and creation eligibility',
      (tester) async {
        final selected = <String>{};
        var created = false;
        await tester.pumpWidget(
          _Harness.wrap(
            StatefulBuilder(
              builder: (context, setState) => ProgrammeSupersetEditorSheet(
                exercises: exercises,
                selectedExerciseIds: selected,
                onToggleSelection: (id) => setState(() {
                  selected.contains(id)
                      ? selected.remove(id)
                      : selected.add(id);
                }),
                onCreateSuperset: () => created = true,
              ),
            ),
          ),
        );
        expect(find.text(AppStrings.supersetSelectedCount(0)), findsOneWidget);
        await tester.ensureVisible(find.text('Fly'));
        await tester.tap(find.text('Fly'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Bench Press'));
        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.supersetSelectedCount(2)), findsOneWidget);
        final bench = find.byKey(const ValueKey('superset_exercise_e1'));
        final fly = find.byKey(const ValueKey('superset_exercise_e2'));
        expect(
          find.descendant(of: fly, matching: find.text('1')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: bench, matching: find.text('2')),
          findsOneWidget,
        );
        await tester.tap(
          find.widgetWithText(FilledButton, AppStrings.createSuperset),
        );
        expect(created, isTrue);
        await tester.ensureVisible(find.text('Fly'));
        await tester.tap(find.text('Fly'));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.supersetSelectedCount(1)), findsOneWidget);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        expect(
          find.descendant(of: bench, matching: find.text('1')),
          findsOneWidget,
        );
      },
    );

    testWidgets('stale exercise IDs do not enable creation', (tester) async {
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {'e1', 'missing'},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
          ),
        ),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.text(AppStrings.supersetSelectedCount(1)), findsOneWidget);
    });

    testWidgets(
      'edit mode shows only active members in their execution order',
      (tester) async {
        await tester.pumpWidget(
          _Harness.wrap(
            ProgrammeSupersetEditorSheet(
              exercises: [
                exercises[0].copyWith(supersetGroupId: 'g1', supersetOrder: 1),
                exercises[1].copyWith(supersetGroupId: 'g1', supersetOrder: 0),
                exercises[2].copyWith(
                  supersetGroupId: 'other',
                  supersetOrder: 0,
                ),
              ],
              activeGroupId: 'g1',
              selectedExerciseIds: const {},
              onToggleSelection: (_) {},
              onCreateSuperset: () {},
              onRemoveMember: (_) {},
              onDeleteGroup: () {},
            ),
          ),
        );
        expect(find.text('Press'), findsNothing);
        expect(
          tester.getTopLeft(find.text('Fly')).dy,
          lessThan(tester.getTopLeft(find.text('Bench Press')).dy),
        );
        final remove = find.byKey(const ValueKey('remove_superset_member_e2'));
        expect(tester.getSize(remove).shortestSide, greaterThanOrEqualTo(48));
        expect(find.text(AppStrings.supersetDeleteHint), findsOneWidget);
      },
    );

    testWidgets('close dismisses the modal without changing the selection', (
      tester,
    ) async {
      var mutated = false;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ProgrammeSupersetEditorSheet(
                      exercises: exercises,
                      selectedExerciseIds: const {},
                      onToggleSelection: (_) => mutated = true,
                      onCreateSuperset: () => mutated = true,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router, theme: AppTheme.lightTheme),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final close = find.byTooltip(AppStrings.close);
      expect(tester.getSize(close).shortestSide, greaterThanOrEqualTo(48));
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(ProgrammeSupersetEditorSheet), findsNothing);
      expect(mutated, isFalse);
    });

    for (final dark in [false, true]) {
      for (final editing in [false, true]) {
        testWidgets(
          'small phone at 2x text scrolls while actions stay pinned: dark=$dark edit=$editing',
          (tester) async {
            _Harness.phone(tester);
            final many = List.generate(
              12,
              (i) => exercises.first.copyWith(
                id: 'exercise-$i',
                exerciseRef: 'Exercise $i with a long descriptive name',
                supersetGroupId: editing ? 'group' : null,
                supersetOrder: i,
              ),
            );
            await tester.pumpWidget(
              _Harness.wrap(
                ProgrammeSupersetEditorSheet(
                  exercises: many,
                  selectedExerciseIds: const {'exercise-0', 'exercise-1'},
                  activeGroupId: editing ? 'group' : null,
                  onToggleSelection: (_) {},
                  onCreateSuperset: () {},
                  onRemoveMember: (_) {},
                  onDeleteGroup: () {},
                ),
                dark: dark,
                scale: 2,
              ),
            );
            final action = editing
                ? find.widgetWithText(OutlinedButton, AppStrings.deleteSuperset)
                : find.widgetWithText(FilledButton, AppStrings.createSuperset);
            final before = tester.getRect(action);
            expect(before.bottom, lessThanOrEqualTo(740));
            final last = find.byKey(
              const ValueKey('superset_exercise_exercise-11'),
            );
            await tester.ensureVisible(last);
            await tester.pumpAndSettle();
            expect(tester.getRect(action), before);
            expect(tester.getRect(last).top, lessThan(before.top));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('empty workout shows guidance and disables creation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: const [],
            selectedExerciseIds: const {},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
          ),
        ),
      );
      expect(find.text(AppStrings.noExercisesAdded), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('renders exercises and create button', (tester) async {
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Fly'), findsOneWidget);
      expect(find.text('Press'), findsOneWidget);
      expect(find.text(AppStrings.createSuperset), findsWidgets);
    });

    testWidgets('create button disabled with fewer than 2 selections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {'e1'},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('create button enabled with 2+ selections', (tester) async {
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {'e1', 'e2'},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('uses custom selection rows and fires selection callback', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {},
            onToggleSelection: (id) => selected = id,
            onCreateSuperset: () {},
          ),
        ),
      );

      expect(find.byType(CheckboxListTile), findsNothing);
      await tester.ensureVisible(find.text('Bench Press'));
      await tester.tap(find.text('Bench Press'));
      expect(selected, 'e1');
    });

    testWidgets('fires onCreateSuperset', (tester) async {
      var created = false;
      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {'e1', 'e2'},
            onToggleSelection: (_) {},
            onCreateSuperset: () => created = true,
          ),
        ),
      );

      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.createSuperset),
      );
      expect(created, isTrue);
    });

    testWidgets('shows edit mode with activeGroupId', (tester) async {
      final groupedExercises = [
        ProgrammeExerciseDraft(
          id: 'e1',
          exerciseId: 1,
          sortOrder: 0,
          sets: [],
          exerciseRef: 'Bench Press',
          supersetGroupId: 'g1',
          supersetOrder: 0,
        ),
        ProgrammeExerciseDraft(
          id: 'e2',
          exerciseId: 2,
          sortOrder: 1,
          sets: [],
          exerciseRef: 'Fly',
          supersetGroupId: 'g1',
          supersetOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: groupedExercises,
            selectedExerciseIds: const {},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
            activeGroupId: 'g1',
            onDeleteGroup: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.editSuperset), findsOneWidget);
      expect(find.text(AppStrings.groupedExercises), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Fly'), findsOneWidget);
      expect(find.text(AppStrings.deleteSuperset), findsOneWidget);
    });

    testWidgets('fires onRemoveMember when remove icon tapped', (tester) async {
      String? removed;
      final groupedExercises = [
        ProgrammeExerciseDraft(
          id: 'e1',
          exerciseId: 1,
          sortOrder: 0,
          sets: [],
          exerciseRef: 'Bench Press',
          supersetGroupId: 'g1',
          supersetOrder: 0,
        ),
        ProgrammeExerciseDraft(
          id: 'e2',
          exerciseId: 2,
          sortOrder: 1,
          sets: [],
          exerciseRef: 'Fly',
          supersetGroupId: 'g1',
          supersetOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: groupedExercises,
            selectedExerciseIds: const {},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
            activeGroupId: 'g1',
            onRemoveMember: (id) => removed = id,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('remove_superset_member_e1')));
      expect(removed, equals('e1'));
    });

    testWidgets('fires onDeleteGroup when delete button tapped', (
      tester,
    ) async {
      var deleted = false;
      final groupedExercises = [
        ProgrammeExerciseDraft(
          id: 'e1',
          exerciseId: 1,
          sortOrder: 0,
          sets: [],
          exerciseRef: 'Bench Press',
          supersetGroupId: 'g1',
          supersetOrder: 0,
        ),
      ];

      await tester.pumpWidget(
        _Harness.wrap(
          ProgrammeSupersetEditorSheet(
            exercises: groupedExercises,
            selectedExerciseIds: const {},
            onToggleSelection: (_) {},
            onCreateSuperset: () {},
            activeGroupId: 'g1',
            onDeleteGroup: () => deleted = true,
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.deleteSuperset));
      expect(deleted, isTrue);
    });
  });
}
