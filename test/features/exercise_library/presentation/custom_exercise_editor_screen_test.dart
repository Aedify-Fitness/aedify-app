import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/load_custom_exercise_draft_use_case.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/presentation/custom_exercise_editor_screen.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeLoadCustomExerciseDraftUseCase
    implements LoadCustomExerciseDraftUseCase {
  const _FakeLoadCustomExerciseDraftUseCase();

  @override
  Future<CustomExerciseDraft> createEmptyDraft() async {
    return const CustomExerciseDraft(
      name: '',
      muscleGroups: {},
      modality: ExerciseModality.strength,
      loggingType: ExerciseLoggingType.repsWeight,
    );
  }

  @override
  Future<CustomExerciseDraft> loadForEdit(int exerciseId) async {
    return const CustomExerciseDraft(
      name: 'Cable Face Pulls',
      muscleGroups: {BodymapBucket.shoulders},
      modality: ExerciseModality.strength,
      loggingType: ExerciseLoggingType.repsWeight,
      difficulty: ExerciseDifficulty.beginner,
      steps: ['Keep the cable at eye level.'],
    );
  }
}

class _CustomExerciseEditorTestFixtures {
  _CustomExerciseEditorTestFixtures._();

  static void useReferenceSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 884);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Widget app({
    CustomExerciseEditorMode mode = CustomExerciseEditorMode.create,
  }) {
    return ProviderScope(
      overrides: [
        AppProviders.loadCustomExerciseDraftUseCaseProvider.overrideWithValue(
          const _FakeLoadCustomExerciseDraftUseCase(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: mode == CustomExerciseEditorMode.create
            ? const CustomExerciseEditorScreen.create()
            : const CustomExerciseEditorScreen.edit(exerciseId: -1),
      ),
    );
  }

  static ({Widget app, GoRouter router}) routedApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            key: const Key('custom_exercise_test_host'),
            body: Center(
              child: FilledButton(
                onPressed: () => context.push('/editor'),
                child: const Text(AppStrings.createExercise),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'editor',
              builder: (context, state) =>
                  const CustomExerciseEditorScreen.create(),
            ),
          ],
        ),
      ],
    );
    return (
      router: router,
      app: ProviderScope(
        overrides: [
          AppProviders.loadCustomExerciseDraftUseCaseProvider.overrideWithValue(
            const _FakeLoadCustomExerciseDraftUseCase(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}

void main() {
  group('CustomExerciseEditorScreen', () {
    testWidgets('matches the supplied create form composition', (tester) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      await tester.pumpWidget(_CustomExerciseEditorTestFixtures.app());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byTooltip(AppStrings.customExerciseDelete), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);

      final orderedSections = <Finder>[
        find.text(AppStrings.customExerciseNameLabel.toUpperCase()),
        find.text(AppStrings.customExercisePrimaryMuscleGroup.toUpperCase()),
        find.text(AppStrings.customExerciseEquipment.toUpperCase()),
        find.text(AppStrings.customExerciseDifficulty.toUpperCase()),
        find.text(AppStrings.customExerciseModality.toUpperCase()),
        find.text(AppStrings.customExerciseInstructionsLabel.toUpperCase()),
        find.text(AppStrings.customExerciseLoggingType),
        find.byKey(const Key('custom_exercise_editor_actions')),
      ];
      for (var index = 0; index < orderedSections.length - 1; index++) {
        expect(
          tester.getTopLeft(orderedSections[index]).dy,
          lessThan(tester.getTopLeft(orderedSections[index + 1]).dy),
        );
      }

      expect(find.text('Novice'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(
        find.text(AppStrings.customExerciseInstructionsOptional),
        findsOneWidget,
      );

      final scroll = find.byKey(const Key('custom_exercise_editor_scroll'));
      final actions = find.byKey(const Key('custom_exercise_editor_actions'));
      expect(find.descendant(of: scroll, matching: actions), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const Key('custom_exercise_primary_action')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const Key('custom_exercise_discard_action')),
              )
              .dy,
        ),
      );

      final repsOnly = find.byKey(
        const Key('custom_exercise_logging_reps_only'),
      );
      final weightReps = find.byKey(
        const Key('custom_exercise_logging_weight_reps'),
      );
      final duration = find.byKey(
        const Key('custom_exercise_logging_duration'),
      );
      expect(
        tester.getTopLeft(repsOnly).dy,
        moreOrLessEquals(tester.getTopLeft(weightReps).dy),
      );
      expect(
        tester.getTopLeft(duration).dy,
        greaterThan(tester.getTopLeft(repsOnly).dy),
      );
    });

    testWidgets('slides the difficulty thumb between selected segments', (
      tester,
    ) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      await tester.pumpWidget(_CustomExerciseEditorTestFixtures.app());
      await tester.pumpAndSettle();

      const indicatorKey = Key('custom_exercise_difficulty_sliding_indicator');
      const thumbKey = Key('custom_exercise_difficulty_sliding_thumb');
      final novice = find.text('Novice');
      final advanced = find.text('Advanced');

      expect(find.byKey(indicatorKey), findsNothing);
      await tester.ensureVisible(novice);
      await tester.tap(novice);
      await tester.pumpAndSettle();

      AnimatedAlign indicator() =>
          tester.widget<AnimatedAlign>(find.byKey(indicatorKey));
      double thumbX() => tester.getCenter(find.byKey(thumbKey)).dx;

      expect(indicator().alignment, AlignmentDirectional.centerStart);
      expect(indicator().duration, AppDurations.segmentedControl);
      expect(indicator().curve, Curves.easeOutCubic);
      final controlRect = tester.getRect(
        find.byKey(const Key('custom_exercise_difficulty_control')),
      );
      final thumbRect = tester.getRect(find.byKey(thumbKey));
      final trackWidth = controlRect.width - (AppSpacing.inputHorizontal * 2);
      final segmentWidth = trackWidth / ExerciseDifficulty.values.length;
      final expectedStartX =
          controlRect.left + AppSpacing.inputHorizontal + (segmentWidth / 2);
      final expectedEndX =
          controlRect.right - AppSpacing.inputHorizontal - (segmentWidth / 2);
      expect(thumbRect.width, closeTo(segmentWidth, 0.01));
      expect(thumbRect.center.dy, closeTo(controlRect.center.dy, 0.01));
      final startX = thumbX();
      expect(startX, closeTo(expectedStartX, 0.01));

      await tester.tap(advanced);
      await tester.pump();
      expect(indicator().alignment, AlignmentDirectional.centerEnd);

      await tester.pump(const Duration(milliseconds: 100));
      final midpointX = thumbX();
      expect(midpointX, greaterThan(startX));

      await tester.pumpAndSettle();
      final endX = thumbX();
      expect(endX, greaterThan(midpointX));
      expect(endX, closeTo(expectedEndX, 0.01));

      await tester.tap(novice);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final reverseMidpointX = thumbX();
      expect(reverseMidpointX, lessThan(endX));
      expect(reverseMidpointX, greaterThan(startX));

      await tester.pumpAndSettle();
      expect(thumbX(), closeTo(expectedStartX, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps form notes in the textarea until cue list is selected', (
      tester,
    ) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      await tester.pumpWidget(_CustomExerciseEditorTestFixtures.app());
      await tester.pumpAndSettle();

      final instructions = find.byKey(
        const Key('custom_exercise_instructions_text_field'),
      );
      expect(tester.widget<AppTextField>(instructions), isA<AppTextField>());
      await tester.scrollUntilVisible(
        instructions,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        instructions,
        '  Keep the ribs stacked.  \n\n  Brace before lowering.  \n   ',
      );
      await tester.pumpAndSettle();

      expect(instructions, findsOneWidget);
      expect(find.byKey(const Key('custom_exercise_cue_list')), findsNothing);

      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      final cueListButton = find.byKey(
        const Key('custom_exercise_add_cue_list'),
      );
      await tester.ensureVisible(cueListButton);
      await tester.tap(cueListButton);
      await tester.pumpAndSettle();

      expect(instructions, findsNothing);
      expect(find.byKey(const Key('custom_exercise_cue_list')), findsOneWidget);
      final cueFields = tester
          .widgetList<AppTextField>(find.byType(AppTextField))
          .map((field) => field.controller.text)
          .toList(growable: false);
      expect(cueFields, ['Keep the ribs stacked.', 'Brace before lowering.']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('preserves the active name-field caret across draft updates', (
      tester,
    ) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      await tester.pumpWidget(_CustomExerciseEditorTestFixtures.app());
      await tester.pumpAndSettle();

      final nameField = find.byKey(
        const Key('custom_exercise_name_text_field'),
      );
      await tester.tap(nameField);
      await tester.pump();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'A',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<TextField>(nameField).controller!.selection,
        const TextSelection.collapsed(offset: 1),
      );

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Ab',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<TextField>(nameField).controller!.selection,
        const TextSelection.collapsed(offset: 2),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirms dirty discard once and returns to the prior route', (
      tester,
    ) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      final fixture = _CustomExerciseEditorTestFixtures.routedApp();
      addTearDown(fixture.router.dispose);
      await tester.pumpWidget(fixture.app);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.createExercise));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('custom_exercise_name_text_field')),
        'Tempo Squat',
      );
      await tester.pumpAndSettle();

      final discardAction = find.byKey(
        const Key('custom_exercise_discard_action'),
      );
      await tester.scrollUntilVisible(
        discardAction,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(discardAction);
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.customExerciseUnsavedChanges),
        findsOneWidget,
      );
      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.customExerciseDiscard),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('custom_exercise_test_host')),
        findsOneWidget,
      );
      expect(find.byType(CustomExerciseEditorScreen), findsNothing);
      expect(find.text(AppStrings.customExerciseUnsavedChanges), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retains edit actions and existing values', (tester) async {
      _CustomExerciseEditorTestFixtures.useReferenceSurface(tester);
      await tester.pumpWidget(
        _CustomExerciseEditorTestFixtures.app(
          mode: CustomExerciseEditorMode.edit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byTooltip(AppStrings.customExerciseDelete), findsOneWidget);
      expect(find.text('Cable Face Pulls'), findsOneWidget);
      expect(find.text(AppStrings.save), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
