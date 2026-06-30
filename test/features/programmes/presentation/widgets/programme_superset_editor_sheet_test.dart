import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_superset_editor_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
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

    testWidgets('renders exercises and create button', (tester) async {
      await tester.pumpWidget(
        _wrap(
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
        _wrap(
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
        _wrap(
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

    testWidgets('fires onCreateSuperset', (tester) async {
      var created = false;
      await tester.pumpWidget(
        _wrap(
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
        _wrap(
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
        _wrap(
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

      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
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
        _wrap(
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
