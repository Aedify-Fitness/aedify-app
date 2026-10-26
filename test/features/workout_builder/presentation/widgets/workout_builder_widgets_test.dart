import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
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
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: child),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData(colorSchemeSeed: Colors.blue),
  );
}

class _ReorderableSetList extends StatefulWidget {
  const _ReorderableSetList({required this.setTypeOptions});

  final List<SetTypeOption> setTypeOptions;

  @override
  State<_ReorderableSetList> createState() => _ReorderableSetListState();
}

class _ReorderableSetListState extends State<_ReorderableSetList> {
  List<SetPrescriptionDraft> _sets = [
    SetPrescriptionDraft(id: 's1', setIndex: 0, setType: SetType.working),
    SetPrescriptionDraft(id: 's2', setIndex: 1, setType: SetType.warmup),
  ];

  void _reorder() {
    setState(() {
      _sets = [_sets[1].copyWith(setIndex: 0), _sets[0].copyWith(setIndex: 1)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          key: const ValueKey('reorder'),
          onPressed: _reorder,
          child: const Text('Reorder'),
        ),
        SetPrescriptionList(
          exerciseDraftId: 'ex1',
          setTypeOptions: widget.setTypeOptions,
          sets: _sets,
          onUpdateSet: (_, _) {},
          onRemoveSet: (_) {},
          validationErrors: const [],
        ),
      ],
    );
  }
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
        wrapApp(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      DiscardChangesDialog(onDiscard: () => discarded = true),
                ),
                child: const Text('Open'),
              ),
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
            onChanged: (_) {},
            onRemove: () => removed = true,
          ),
        ),
      );
      await tester.tap(find.byTooltip(AppStrings.removeSet));
      expect(removed, isTrue);
    });

    testWidgets('renders set type dropdown', (tester) async {
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
            onChanged: (_) {},
            onRemove: () {},
          ),
        ),
      );
      expect(find.text('Working'), findsOneWidget);
    });

    testWidgets('set type dropdown changes value', (tester) async {
      SetPrescriptionDraft? updated;
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
            onChanged: (s) => updated = s,
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.text('Working'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warm-up').last);
      await tester.pumpAndSettle();
      expect(updated?.setType, equals(SetType.warmup));
    });
  });

  group('SetPrescriptionList', () {
    testWidgets('renders multiple sets', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          SetPrescriptionList(
            exerciseDraftId: 'ex1',
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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

    testWidgets('reflects reordered sets', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          _ReorderableSetList(
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('reorder')));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Warm-up'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
    });
  });

  group('WorkoutExerciseCard', () {
    testWidgets('renders exercise name and sets', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          WorkoutExerciseCard(
            exercise: _placeholderExercise,
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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
            setTypeOptions: const [
              SetTypeOption(
                type: SetType.working,
                label: 'Working',
                description: '',
              ),
              SetTypeOption(
                type: SetType.warmup,
                label: 'Warm-up',
                description: '',
              ),
            ],
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
