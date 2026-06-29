import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/discard_changes_dialog.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_prescription_editor_row.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_prescription_list.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_builder_error_banner.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_card.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_list.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_name_field.dart';

Widget wrapApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.blue),
    home: Scaffold(body: child),
  );
}

final _placeholderExercise = WorkoutBuilderExerciseDraft(
  id: 'ex1',
  exercise: const ExerciseReference(
    exerciseId: 1,
    name: 'Bench Press',
    modality: 'strength',
    equipment: 'barbell',
  ),
  sortOrder: 0,
  sets: [
    SetPrescriptionDraft(
      id: 's1',
      setIndex: 0,
      setType: SetType.working,
      prescribedRepsMin: 8,
      prescribedWeightKg: 60.0,
      restSeconds: 90,
    ),
  ],
);

void main() {
  group('WorkoutBuilderErrorBanner', () {
    testWidgets('renders message', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          const WorkoutBuilderErrorBanner(message: 'Something went wrong'),
        ),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapApp(
          WorkoutBuilderErrorBanner(
            message: 'Error',
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        wrapApp(const WorkoutBuilderErrorBanner(message: 'Error')),
      );
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('DiscardChangesDialog', () {
    testWidgets('fires onDiscard when discard button is tapped', (
      tester,
    ) async {
      var discarded = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) =>
                    DiscardChangesDialog(onDiscard: () => discarded = true),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.unsavedChanges), findsOneWidget);

      await tester.tap(find.text(AppStrings.discardChanges));
      expect(discarded, isTrue);
    });
  });

  group('WorkoutNameField', () {
    testWidgets('shows initial value', (tester) async {
      await tester.pumpWidget(
        wrapApp(WorkoutNameField(initialValue: 'Push Day', onChanged: (_) {})),
      );
      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('fires onChanged when text is entered', (tester) async {
      String? changed;
      await tester.pumpWidget(
        wrapApp(
          WorkoutNameField(initialValue: '', onChanged: (v) => changed = v),
        ),
      );

      await tester.enterText(find.byType(TextField), 'New Name');
      expect(changed, 'New Name');
    });
  });

  group('SetPrescriptionEditorRow', () {
    testWidgets('renders set index and fields', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          SetPrescriptionEditorRow(
            prescription: SetPrescriptionDraft(
              id: 's1',
              setIndex: 0,
              setType: SetType.working,
              prescribedRepsMin: 10,
              prescribedWeightKg: 50.0,
              restSeconds: 60,
            ),
            modality: 'strength',
            onChanged: (_) {},
            onRemove: () {},
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('fires onChanged when reps field changes', (tester) async {
      SetPrescriptionDraft? updated;
      await tester.pumpWidget(
        wrapApp(
          SetPrescriptionEditorRow(
            prescription: SetPrescriptionDraft(
              id: 's1',
              setIndex: 0,
              setType: SetType.working,
            ),
            modality: 'strength',
            onChanged: (s) => updated = s,
            onRemove: () {},
          ),
        ),
      );

      final repsField = find.byType(TextField).first;
      await tester.enterText(repsField, '12');
      expect(updated?.prescribedRepsMin, 12);
    });

    testWidgets('fires onRemove when delete button is tapped', (tester) async {
      var removed = false;
      await tester.pumpWidget(
        wrapApp(
          SetPrescriptionEditorRow(
            prescription: SetPrescriptionDraft(
              id: 's1',
              setIndex: 0,
              setType: SetType.working,
            ),
            modality: 'strength',
            onChanged: (_) {},
            onRemove: () => removed = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(removed, isTrue);
    });
  });

  group('SetPrescriptionList', () {
    testWidgets('renders multiple sets', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          SetPrescriptionList(
            exerciseDraftId: 'ex1',
            sets: [
              SetPrescriptionDraft(
                id: 's1',
                setIndex: 0,
                setType: SetType.working,
              ),
              SetPrescriptionDraft(
                id: 's2',
                setIndex: 1,
                setType: SetType.working,
              ),
            ],
            onUpdateSet: (_, _) {},
            onRemoveSet: (_) {},
            validationErrors: const [],
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('WorkoutExerciseCard', () {
    testWidgets('renders exercise name and sets', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          WorkoutExerciseCard(
            exercise: _placeholderExercise,
            onRemove: () {},
            onDuplicate: () {},
            onAddSet: () {},
            onUpdateSet: (_, _) {},
            onRemoveSet: (_) {},
            validationErrors: const [],
          ),
        ),
      );
      expect(find.text('Bench Press'), findsOneWidget);
    });
  });

  group('WorkoutExerciseList', () {
    testWidgets('shows empty state when no exercises', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          WorkoutExerciseList(
            exercises: const [],
            onReorder: (_, _) {},
            onRemove: (_) {},
            onDuplicate: (_) {},
            onAddSet: (_) {},
            onUpdateSet: (_, _, _) {},
            onRemoveSet: (_, _) {},
            validationErrors: const [],
          ),
        ),
      );
      expect(find.text(AppStrings.noExercisesAdded), findsOneWidget);
    });

    testWidgets('renders exercises list', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          WorkoutExerciseList(
            exercises: [_placeholderExercise],
            onReorder: (_, _) {},
            onRemove: (_) {},
            onDuplicate: (_) {},
            onAddSet: (_) {},
            onUpdateSet: (_, _, _) {},
            onRemoveSet: (_, _) {},
            validationErrors: const [],
          ),
        ),
      );
      expect(find.text('Bench Press'), findsOneWidget);
    });
  });
}
