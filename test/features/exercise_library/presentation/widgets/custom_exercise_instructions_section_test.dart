import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_instructions_section.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _InstructionsHarness extends StatefulWidget {
  const _InstructionsHarness({
    super.key,
    this.initialSteps = const [],
    this.initialEnabled = true,
    this.errors = const [],
  });

  final List<String> initialSteps;
  final bool initialEnabled;
  final List<CustomExerciseValidationError> errors;

  @override
  State<_InstructionsHarness> createState() => _InstructionsHarnessState();
}

class _InstructionsHarnessState extends State<_InstructionsHarness> {
  late List<String> steps;
  late bool enabled;

  @override
  void initState() {
    super.initState();
    steps = [...widget.initialSteps];
    enabled = widget.initialEnabled;
  }

  void replace(List<String> replacement) => setState(() => steps = replacement);

  void setEnabled(bool value) => setState(() => enabled = value);

  @override
  Widget build(BuildContext context) => CustomExerciseInstructionsSection(
    steps: steps,
    enabled: enabled,
    validationErrors: widget.errors,
    onAddStep: () => setState(() => steps = [...steps, '']),
    onUpdateStep: (index, value) =>
        setState(() => steps = [...steps]..[index] = value),
    onRemoveStep: (index) =>
        setState(() => steps = [...steps]..removeAt(index)),
  );
}

class _InstructionsTestData {
  _InstructionsTestData._();

  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize / tester.view.devicePixelRatio,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      ),
    ),
  );

  static Finder get textarea =>
      find.byKey(const Key('custom_exercise_instructions_text_field'));

  static Future<void> tapAction(WidgetTester tester, String key) async {
    final action = find.byKey(Key(key));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'empty instructions remain optional and switch is outside input',
    (tester) async {
      final key = GlobalKey<_InstructionsHarnessState>();
      await _InstructionsTestData.pump(tester, _InstructionsHarness(key: key));
      expect(
        find.text(AppStrings.customExerciseInstructionsOptional),
        findsOneWidget,
      );
      expect(_InstructionsTestData.textarea, findsOneWidget);
      expect(key.currentState!.steps, isEmpty);
      final surface = find.byKey(
        const Key('custom_exercise_instructions_surface'),
      );
      final action = find.byKey(const Key('custom_exercise_add_cue_list'));
      expect(
        tester.getTopLeft(action).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(surface).dy),
      );
      expect(
        tester.getSize(action).height,
        greaterThanOrEqualTo(AppCustomExerciseEditorTokens.controlSize),
      );
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(key.currentState!.steps, isEmpty);
      await _InstructionsTestData.tapAction(
        tester,
        'custom_exercise_add_cue_list',
      );
      expect(key.currentState!.steps, isEmpty);
      expect(find.text(AppStrings.customExerciseNoSteps), findsOneWidget);
      expect(find.text(AppStrings.customExerciseStepEmpty(1)), findsNothing);
    },
  );

  testWidgets(
    'textarea conversion trims cues, removes blank lines and roundtrips',
    (tester) async {
      final key = GlobalKey<_InstructionsHarnessState>();
      await _InstructionsTestData.pump(tester, _InstructionsHarness(key: key));
      const raw = '  Stand tall.  \r\n\n Press upward. \n  ';
      await tester.enterText(find.byType(TextField), raw);
      await tester.pump();
      expect(key.currentState!.steps, [raw]);
      await _InstructionsTestData.tapAction(
        tester,
        'custom_exercise_add_cue_list',
      );
      expect(key.currentState!.steps, ['Stand tall.', 'Press upward.']);
      expect(find.byType(TextField), findsNWidgets(2));
      await tester.enterText(
        find.byType(TextField).at(1),
        'Lower with control.',
      );
      await tester.pump();
      await _InstructionsTestData.tapAction(tester, 'custom_exercise_use_text');
      final field = tester.widget<AppTextField>(_InstructionsTestData.textarea);
      expect(field.controller.text, 'Stand tall.\nLower with control.');
      expect(key.currentState!.steps, ['Stand tall.', 'Lower with control.']);
      await _InstructionsTestData.tapAction(
        tester,
        'custom_exercise_add_cue_list',
      );
      expect(key.currentState!.steps, ['Stand tall.', 'Lower with control.']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'multi-step data starts in cue mode and supports add and remove',
    (tester) async {
      final key = GlobalKey<_InstructionsHarnessState>();
      await _InstructionsTestData.pump(
        tester,
        _InstructionsHarness(
          key: key,
          initialSteps: const ['Stand tall.', 'Press upward.'],
        ),
      );
      expect(find.byKey(const Key('custom_exercise_cue_list')), findsOneWidget);
      expect(_InstructionsTestData.textarea, findsNothing);
      await _InstructionsTestData.tapAction(tester, 'custom_exercise_add_step');
      expect(key.currentState!.steps, ['Stand tall.', 'Press upward.', '']);
      final newField = find.byType(TextField).at(2);
      await tester.ensureVisible(newField);
      await tester.enterText(newField, 'Lower slowly.');
      await tester.pump();
      await _InstructionsTestData.tapAction(
        tester,
        'custom_exercise_step_remove_0',
      );
      expect(key.currentState!.steps, ['Press upward.', 'Lower slowly.']);
      await _InstructionsTestData.tapAction(tester, 'custom_exercise_use_text');
      expect(
        tester
            .widget<AppTextField>(_InstructionsTestData.textarea)
            .controller
            .text,
        'Press upward.\nLower slowly.',
      );
    },
  );

  testWidgets(
    'draft echoes preserve active textarea selection and composition',
    (tester) async {
      final key = GlobalKey<_InstructionsHarnessState>();
      await _InstructionsTestData.pump(tester, _InstructionsHarness(key: key));
      await tester.tap(find.byType(TextField));
      const edit = TextEditingValue(
        text: 'Raise the arms',
        selection: TextSelection.collapsed(offset: 3),
        composing: TextRange(start: 0, end: 5),
      );
      tester.testTextInput.updateEditingValue(edit);
      await tester.pump();
      final field = tester.widget<AppTextField>(_InstructionsTestData.textarea);
      expect(key.currentState!.steps, ['Raise the arms']);
      expect(field.controller.value, edit);
      expect(tester.testTextInput.isVisible, isTrue);
      key.currentState!.replace(['Raise the arms']);
      await tester.pump();
      expect(field.controller.value, edit);
    },
  );

  testWidgets(
    'external replacements update text without invalid caret positions',
    (tester) async {
      final key = GlobalKey<_InstructionsHarnessState>();
      await _InstructionsTestData.pump(
        tester,
        _InstructionsHarness(key: key, initialSteps: const ['Stand upright']),
      );
      final field = tester.widget<AppTextField>(_InstructionsTestData.textarea);
      field.controller.selection = const TextSelection(
        baseOffset: 2,
        extentOffset: 6,
      );
      key.currentState!.replace(['Stand tall']);
      await tester.pump();
      expect(field.controller.text, 'Stand tall');
      expect(
        field.controller.selection,
        const TextSelection(baseOffset: 2, extentOffset: 6),
      );
      key.currentState!.replace(['Go']);
      await tester.pump();
      expect(
        field.controller.selection,
        const TextSelection(baseOffset: 2, extentOffset: 2),
      );
      key.currentState!.replace([]);
      await tester.pump();
      expect(field.controller.text, isEmpty);
    },
  );

  testWidgets('step validation stays visible in textarea and cue list modes', (
    tester,
  ) async {
    await _InstructionsTestData.pump(
      tester,
      _InstructionsHarness(
        initialSteps: const [''],
        errors: [
          CustomExerciseValidationError(
            scope: CustomExerciseValidationScope.steps,
            code: 'test_empty',
            message: AppStrings.customExerciseStepEmpty(1),
            stepIndex: 0,
          ),
          const CustomExerciseValidationError(
            scope: CustomExerciseValidationScope.name,
            code: 'test_name',
            message: AppStrings.customExerciseNameRequired,
          ),
        ],
      ),
    );
    expect(find.text(AppStrings.customExerciseStepEmpty(1)), findsOneWidget);
    expect(find.text(AppStrings.customExerciseNameRequired), findsNothing);
    await _InstructionsTestData.tapAction(
      tester,
      'custom_exercise_add_cue_list',
    );
    await _InstructionsTestData.tapAction(tester, 'custom_exercise_add_step');
    expect(find.text(AppStrings.customExerciseStepEmpty(1)), findsOneWidget);
  });

  testWidgets('saving disables text edits and both representation switches', (
    tester,
  ) async {
    final key = GlobalKey<_InstructionsHarnessState>();
    await _InstructionsTestData.pump(
      tester,
      _InstructionsHarness(
        key: key,
        initialSteps: const ['Keep this cue'],
        initialEnabled: false,
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    final addList = tester.widget<TextButton>(
      find.byKey(const Key('custom_exercise_add_cue_list')),
    );
    expect(addList.onPressed, isNull);
    key.currentState!.setEnabled(true);
    await tester.pump();
    await _InstructionsTestData.tapAction(
      tester,
      'custom_exercise_add_cue_list',
    );
    key.currentState!.setEnabled(false);
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    for (final button in tester.widgetList<TextButton>(
      find.byType(TextButton),
    )) {
      expect(button.onPressed, isNull);
    }
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    expect(key.currentState!.steps, ['Keep this cue']);
  });

  for (final brightness in Brightness.values) {
    testWidgets('320px, 2x text and cue controls in ${brightness.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _InstructionsTestData.pump(
        tester,
        const _InstructionsHarness(
          initialSteps: [
            'Keep the movement controlled and your shoulders relaxed.',
          ],
        ),
        brightness: brightness,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await _InstructionsTestData.tapAction(
        tester,
        'custom_exercise_add_cue_list',
      );
      expect(tester.takeException(), isNull);
      final remove = find.byKey(const Key('custom_exercise_step_remove_0'));
      await tester.ensureVisible(remove);
      expect(
        tester.getSize(remove).shortestSide,
        greaterThanOrEqualTo(AppCustomExerciseEditorTokens.controlSize),
      );
      final useText = find.byKey(const Key('custom_exercise_use_text'));
      await tester.ensureVisible(useText);
      expect(
        tester.getSize(useText).height,
        greaterThanOrEqualTo(AppCustomExerciseEditorTokens.controlSize),
      );
      await _InstructionsTestData.tapAction(tester, 'custom_exercise_use_text');
      expect(tester.takeException(), isNull);
      expect(_InstructionsTestData.textarea, findsOneWidget);
    });
  }
}
