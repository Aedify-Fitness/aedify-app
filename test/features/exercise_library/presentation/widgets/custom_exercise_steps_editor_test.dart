import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StepsHarness extends StatefulWidget {
  const _StepsHarness({
    super.key,
    required this.initialSteps,
    this.enabled = true,
    this.errors = const [],
  });

  final List<String> initialSteps;
  final bool enabled;
  final List<CustomExerciseValidationError> errors;

  @override
  State<_StepsHarness> createState() => _StepsHarnessState();
}

class _StepsHarnessState extends State<_StepsHarness> {
  late List<String> steps;

  @override
  void initState() {
    super.initState();
    steps = [...widget.initialSteps];
  }

  void replace(List<String> replacement) => setState(() => steps = replacement);

  @override
  Widget build(BuildContext context) => CustomExerciseStepsEditor(
    steps: steps,
    enabled: widget.enabled,
    validationErrors: widget.errors,
    onAddStep: () => setState(() => steps = [...steps, '']),
    onUpdateStep: (index, value) =>
        setState(() => steps = [...steps]..[index] = value),
    onRemoveStep: (index) =>
        setState(() => steps = [...steps]..removeAt(index)),
    onSwitchToText: () {},
  );
}

class _StepsTestData {
  _StepsTestData._();

  static Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );
}

void main() {
  testWidgets(
    'empty instructions stay optional with an accessible add action',
    (tester) async {
      final key = GlobalKey<_StepsHarnessState>();
      await _StepsTestData.pump(
        tester,
        _StepsHarness(key: key, initialSteps: const []),
      );
      expect(find.text(AppStrings.customExerciseNoSteps), findsOneWidget);
      final add = find.byKey(const Key('custom_exercise_add_step'));
      expect(
        tester.getSize(add).height,
        greaterThanOrEqualTo(AppCustomExerciseEditorTokens.controlSize),
      );
      await tester.tap(add);
      await tester.pump();
      expect(key.currentState!.steps, ['']);
      expect(find.byType(AppTextField), findsOneWidget);
    },
  );

  testWidgets('numbered cue cards expose editable fields and 48px removal', (
    tester,
  ) async {
    await _StepsTestData.pump(
      tester,
      const _StepsHarness(initialSteps: ['Stand tall.', 'Press smoothly.']),
    );
    expect(find.text(AppStrings.exerciseStepLabel(1)), findsOneWidget);
    expect(find.text(AppStrings.exerciseStepLabel(2)), findsOneWidget);
    expect(find.text('Stand tall.'), findsOneWidget);
    expect(find.text('Press smoothly.'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
    for (final element in find.byType(IconButton).evaluate()) {
      expect(
        tester.getSize(find.byWidget(element.widget)).shortestSide,
        greaterThanOrEqualTo(AppCustomExerciseEditorTokens.controlSize),
      );
    }
  });

  testWidgets('adding waits until the final cue is nonblank', (tester) async {
    final key = GlobalKey<_StepsHarnessState>();
    await _StepsTestData.pump(
      tester,
      _StepsHarness(key: key, initialSteps: const ['   ']),
    );
    await tester.tap(find.byKey(const Key('custom_exercise_add_step')));
    await tester.pump();
    expect(key.currentState!.steps, ['   ']);
    await tester.enterText(find.byType(TextField), 'Stand tall.');
    await tester.pump();
    await tester.tap(find.byKey(const Key('custom_exercise_add_step')));
    await tester.pump();
    expect(key.currentState!.steps, ['Stand tall.', '']);
  });

  testWidgets('edits and removal update the correct model index', (
    tester,
  ) async {
    final key = GlobalKey<_StepsHarnessState>();
    await _StepsTestData.pump(
      tester,
      _StepsHarness(key: key, initialSteps: const ['First', 'Second']),
    );
    await tester.enterText(find.byType(TextField).at(1), 'Updated second');
    await tester.pump();
    expect(key.currentState!.steps, ['First', 'Updated second']);
    await tester.tap(find.byKey(const Key('custom_exercise_step_remove_0')));
    await tester.pump();
    expect(key.currentState!.steps, ['Updated second']);
    expect(find.text('Updated second'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing an earlier cue retains the active field and caret', (
    tester,
  ) async {
    final key = GlobalKey<_StepsHarnessState>();
    await _StepsTestData.pump(
      tester,
      _StepsHarness(key: key, initialSteps: const ['First', 'Second cue']),
    );
    final field = tester.widget<AppTextField>(find.byType(AppTextField).at(1));
    await tester.tap(find.byType(TextField).at(1));
    field.controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump();
    key.currentState!.replace(['Second cue']);
    await tester.pump();
    final remaining = tester.widget<AppTextField>(find.byType(AppTextField));
    expect(remaining.controller, same(field.controller));
    expect(remaining.controller.selection.baseOffset, 3);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('external text updates preserve a valid selection', (
    tester,
  ) async {
    final key = GlobalKey<_StepsHarnessState>();
    await _StepsTestData.pump(
      tester,
      _StepsHarness(key: key, initialSteps: const ['Original cue']),
    );
    final field = tester.widget<AppTextField>(find.byType(AppTextField));
    field.controller.selection = const TextSelection(
      baseOffset: 2,
      extentOffset: 5,
    );
    key.currentState!.replace(['Updated cue']);
    await tester.pump();
    expect(field.controller.text, 'Updated cue');
    expect(
      field.controller.selection,
      const TextSelection(baseOffset: 2, extentOffset: 5),
    );
    key.currentState!.replace(['Go']);
    await tester.pump();
    expect(
      field.controller.selection,
      const TextSelection(baseOffset: 2, extentOffset: 2),
    );
  });

  testWidgets(
    'saving disables editing, adding, removal and representation switch',
    (tester) async {
      final key = GlobalKey<_StepsHarnessState>();
      await _StepsTestData.pump(
        tester,
        _StepsHarness(
          key: key,
          initialSteps: const ['Keep this cue'],
          enabled: false,
        ),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );
      for (final button in tester.widgetList<TextButton>(
        find.byType(TextButton),
      )) {
        expect(button.onPressed, isNull);
      }
      await tester.tap(find.byKey(const Key('custom_exercise_add_step')));
      await tester.tap(find.byKey(const Key('custom_exercise_step_remove_0')));
      await tester.pump();
      expect(key.currentState!.steps, ['Keep this cue']);
    },
  );

  testWidgets('step errors are shown beside the matching cue', (tester) async {
    await _StepsTestData.pump(
      tester,
      _StepsHarness(
        initialSteps: const ['Valid cue', ''],
        errors: [
          CustomExerciseValidationError(
            scope: CustomExerciseValidationScope.steps,
            code: 'test_empty',
            message: AppStrings.customExerciseStepEmpty(2),
            stepIndex: 1,
          ),
        ],
      ),
    );
    expect(find.text(AppStrings.customExerciseStepEmpty(2)), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(AppStrings.customExerciseStepEmpty(2))).dy,
      greaterThan(
        tester.getTopLeft(find.text(AppStrings.exerciseStepLabel(2))).dy,
      ),
    );
  });
}
