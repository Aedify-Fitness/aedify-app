import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_editor_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  group('SupersetEditorSheet', () {
    final exercises = [
      WorkoutBuilderExerciseDraft(
        id: 'e1',
        exercise: const ExerciseReference(
          exerciseId: 1,
          name: 'Bench Press',
          modality: 'strength',
        ),
        sortOrder: 0,
        sets: [
          SetPrescriptionDraft(id: 's1', setIndex: 0, setType: SetType.working),
        ],
      ),
      WorkoutBuilderExerciseDraft(
        id: 'e2',
        exercise: const ExerciseReference(
          exerciseId: 2,
          name: 'Fly',
          modality: 'strength',
        ),
        sortOrder: 1,
        sets: [
          SetPrescriptionDraft(id: 's2', setIndex: 0, setType: SetType.working),
        ],
      ),
      WorkoutBuilderExerciseDraft(
        id: 'e3',
        exercise: const ExerciseReference(
          exerciseId: 3,
          name: 'Press',
          modality: 'strength',
        ),
        sortOrder: 2,
        sets: [
          SetPrescriptionDraft(id: 's3', setIndex: 0, setType: SetType.working),
        ],
      ),
    ];

    testWidgets('renders exercise list and create button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupersetEditorSheet(
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
      expect(
        find.widgetWithText(FilledButton, AppStrings.createSuperset),
        findsOneWidget,
      );
    });

    testWidgets('create button disabled with fewer than 2 selections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SupersetEditorSheet(
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
          SupersetEditorSheet(
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

    testWidgets('fires onToggleSelection when checkbox tapped', (tester) async {
      String? toggled;
      await tester.pumpWidget(
        _wrap(
          SupersetEditorSheet(
            exercises: exercises,
            selectedExerciseIds: const {},
            onToggleSelection: (id) => toggled = id,
            onCreateSuperset: () {},
          ),
        ),
      );

      await tester.tap(find.text('Bench Press'));
      expect(toggled, 'e1');
    });

    testWidgets('fires onCreateSuperset when create button tapped', (
      tester,
    ) async {
      var created = false;
      await tester.pumpWidget(
        _wrap(
          SupersetEditorSheet(
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
  });
}
