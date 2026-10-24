import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_state.dart';
import 'package:aedify/features/exercise_library/application/delete_custom_exercise_use_case.dart';
import 'package:aedify/features/exercise_library/application/load_custom_exercise_draft_use_case.dart';
import 'package:aedify/features/exercise_library/application/save_custom_exercise_use_case.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/presentation/custom_exercise_editor_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _LoadUseCase implements LoadCustomExerciseDraftUseCase {
  CustomExerciseDraft? draft;
  bool shouldThrow = false;
  int loads = 0;

  Future<CustomExerciseDraft> _load(CustomExerciseDraft fallback) async {
    loads++;
    if (shouldThrow) throw StateError('private load failure');
    return draft ?? fallback;
  }

  @override
  Future<CustomExerciseDraft> createEmptyDraft() => _load(
    const CustomExerciseDraft(
      name: '',
      muscleGroups: {},
      modality: ExerciseModality.strength,
      loggingType: ExerciseLoggingType.repsWeight,
    ),
  );

  @override
  Future<CustomExerciseDraft> loadForEdit(int exerciseId) =>
      _load(_EditorFixture.validDraft);
}

class _SaveUseCase implements SaveCustomExerciseUseCase {
  final created = <CustomExerciseDraft>[];
  final updated = <({int exerciseId, CustomExerciseDraft draft})>[];
  bool shouldThrow = false;
  Completer<void>? pending;

  Future<void> _finish() async {
    if (pending != null) await pending!.future;
    if (shouldThrow) throw StateError('private save failure');
  }

  @override
  Future<int> create(CustomExerciseDraft draft) async {
    created.add(draft);
    await _finish();
    return -42;
  }

  @override
  Future<void> update({
    required int exerciseId,
    required CustomExerciseDraft draft,
  }) async {
    updated.add((exerciseId: exerciseId, draft: draft));
    await _finish();
  }
}

class _DeleteUseCase implements DeleteCustomExerciseUseCase {
  final deleted = <int>[];
  bool shouldThrow = false;
  Completer<void>? pending;

  @override
  Future<void> delete(int exerciseId) async {
    deleted.add(exerciseId);
    if (pending != null) await pending!.future;
    if (shouldThrow) throw StateError('private delete failure');
  }
}

class _EditorFixture {
  _EditorFixture({this.mode = CustomExerciseEditorMode.create}) {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            key: const Key('custom_exercise_test_host'),
            body: Center(
              child: FilledButton(
                key: const Key('open_custom_editor'),
                onPressed: () async {
                  result = await context.pushNamed<bool>('editor');
                  returns++;
                },
                child: const Text(AppStrings.createExercise),
              ),
            ),
          ),
          routes: [
            GoRoute(
              name: 'editor',
              path: 'editor',
              builder: (_, _) => mode == CustomExerciseEditorMode.create
                  ? const CustomExerciseEditorScreen.create()
                  : const CustomExerciseEditorScreen.edit(exerciseId: -1),
            ),
          ],
        ),
      ],
    );
  }

  static const validDraft = CustomExerciseDraft(
    name: 'Cable Face Pulls',
    muscleGroups: {BodymapBucket.shoulders},
    modality: ExerciseModality.strength,
    loggingType: ExerciseLoggingType.repsWeight,
    equipment: EquipmentTag.cable,
    difficulty: ExerciseDifficulty.beginner,
    steps: ['Keep the cable at eye level.'],
  );
  static final name = find.byKey(const Key('custom_exercise_name_text_field'));
  static final primary = find.byKey(
    const Key('custom_exercise_primary_action'),
  );
  static final discard = find.byKey(
    const Key('custom_exercise_discard_action'),
  );
  static final back = find.byKey(const Key('custom_exercise_back_action'));
  static final actions = find.byKey(
    const Key('custom_exercise_editor_actions'),
  );
  static final instructions = find.byKey(
    const Key('custom_exercise_instructions_text_field'),
  );

  final CustomExerciseEditorMode mode;
  final load = _LoadUseCase();
  final save = _SaveUseCase();
  final delete = _DeleteUseCase();
  late final GoRouter router;
  bool? result;
  int returns = 0;

  ({CustomExerciseEditorMode mode, int? exerciseId}) get args => (
    mode: mode,
    exerciseId: mode == CustomExerciseEditorMode.create ? null : -1,
  );

  ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(CustomExerciseEditorScreen)),
  );

  CustomExerciseEditorState state(WidgetTester tester) => container(tester)
      .read(AppProviders.customExerciseEditorControllerProvider(args))
      .requireValue;

  Future<void> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double width = 390,
    double scale = 1,
    bool accessible = false,
  }) async {
    tester.view.physicalSize = Size(width, 884);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.loadCustomExerciseDraftUseCaseProvider.overrideWithValue(
            load,
          ),
          AppProviders.saveCustomExerciseUseCaseProvider.overrideWithValue(
            save,
          ),
          AppProviders.deleteCustomExerciseUseCaseProvider.overrideWithValue(
            delete,
          ),
        ],
        child: MaterialApp.router(
          theme: brightness == Brightness.light
              ? AppTheme.lightTheme
              : AppTheme.darkTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              highContrast: accessible,
              accessibleNavigation: accessible,
              disableAnimations: accessible,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_custom_editor')));
    await tester.pumpAndSettle();
  }

  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static TextEditingController textController(
    WidgetTester tester,
    Finder field,
  ) => tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .controller;

  static Finder dialogButton(String label) => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(FilledButton, label),
  );

  Future<void> confirmDelete(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppStrings.customExerciseDelete));
    await tester.pumpAndSettle();
    await tester.tap(dialogButton(AppStrings.customExerciseDelete));
    await tester.pump();
  }
}

void main() {
  group('CustomExerciseEditorScreen', () {
    testWidgets('create context keeps actions outside the scrolling form', (
      tester,
    ) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      expect(find.text(AppStrings.createCustomExercise), findsWidgets);
      expect(find.byTooltip(AppStrings.customExerciseDelete), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('custom_exercise_editor_scroll')),
          matching: _EditorFixture.actions,
        ),
        findsNothing,
      );
      expect(_EditorFixture.primary.hitTestable(), findsOneWidget);
      expect(
        tester.getSize(_EditorFixture.back).shortestSide,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(_EditorFixture.primary).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('edit context preserves values and delete action', (
      tester,
    ) async {
      final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
      await fixture.pump(tester);
      expect(find.text(AppStrings.editCustomExercise), findsWidgets);
      expect(find.byTooltip(AppStrings.customExerciseDelete), findsOneWidget);
      expect(
        _EditorFixture.textController(tester, _EditorFixture.name).text,
        'Cable Face Pulls',
      );
      expect(fixture.state(tester).draft.equipment, EquipmentTag.cable);
      expect(
        fixture.state(tester).draft.difficulty,
        ExerciseDifficulty.beginner,
      );
      expect(
        find.widgetWithText(FilledButton, AppStrings.save),
        findsOneWidget,
      );
    });

    testWidgets('name updates preserve caret through unrelated draft changes', (
      tester,
    ) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      await tester.tap(_EditorFixture.name);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Tempo Squat',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      await tester.pump();
      expect(fixture.state(tester).draft.name, 'Tempo Squat');
      await fixture
          .container(tester)
          .read(
            AppProviders.customExerciseEditorControllerProvider(
              fixture.args,
            ).notifier,
          )
          .setDifficulty(ExerciseDifficulty.advanced);
      await tester.pump();
      expect(
        _EditorFixture.textController(tester, _EditorFixture.name).selection,
        const TextSelection.collapsed(offset: 5),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('selection controls update the real draft', (tester) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      for (final key in [
        'custom_exercise_muscle_chest',
        'custom_exercise_difficulty_advanced',
        'custom_exercise_modality_cardio',
        'custom_exercise_logging_duration',
      ]) {
        await _EditorFixture.tap(tester, find.byKey(Key(key)));
      }
      await _EditorFixture.tap(
        tester,
        find.byKey(const Key('custom_exercise_equipment_control')),
      );
      await tester.tap(find.text('Dumbbell').last);
      await tester.pumpAndSettle();
      final draft = fixture.state(tester).draft;
      expect(draft.muscleGroups, contains(BodymapBucket.chest));
      expect(draft.difficulty, ExerciseDifficulty.advanced);
      expect(draft.modality, ExerciseModality.cardio);
      expect(draft.loggingType, ExerciseLoggingType.duration);
      expect(draft.equipment, EquipmentTag.dumbbell);
    });

    testWidgets('validation preserves form and prevents persistence', (
      tester,
    ) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      await tester.tap(_EditorFixture.primary);
      await tester.pumpAndSettle();
      expect(fixture.save.created, isEmpty);
      expect(fixture.state(tester).hasValidationErrors, isTrue);
      expect(find.text(AppStrings.customExerciseNameRequired), findsWidgets);
      expect(
        find.text(AppStrings.customExerciseMuscleGroupRequired),
        findsWidgets,
      );
      expect(_EditorFixture.name, findsOneWidget);
    });

    testWidgets('instructions roundtrip between text and editable cue list', (
      tester,
    ) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      await _EditorFixture.reveal(tester, _EditorFixture.instructions);
      await tester.enterText(
        _EditorFixture.instructions,
        '  Brace first.  \n\n  Lower slowly.  \n',
      );
      await tester.pumpAndSettle();
      await _EditorFixture.tap(
        tester,
        find.byKey(const Key('custom_exercise_add_cue_list')),
      );
      expect(fixture.state(tester).draft.steps, [
        'Brace first.',
        'Lower slowly.',
      ]);
      final cue = find
          .descendant(
            of: find.byKey(const Key('custom_exercise_cue_list')),
            matching: find.byType(AppTextField),
          )
          .at(1);
      await _EditorFixture.reveal(tester, cue);
      await tester.enterText(cue, 'Pause, then lower.');
      await tester.pumpAndSettle();
      await _EditorFixture.tap(
        tester,
        find.byKey(const Key('custom_exercise_add_step')),
      );
      expect(fixture.state(tester).draft.steps.length, 3);
      await _EditorFixture.tap(
        tester,
        find.byKey(const Key('custom_exercise_step_remove_2')),
      );
      await _EditorFixture.tap(
        tester,
        find.byKey(const Key('custom_exercise_use_text')),
      );
      expect(
        _EditorFixture.textController(tester, _EditorFixture.instructions).text,
        'Brace first.\nPause, then lower.',
      );
      expect(fixture.state(tester).draft.steps, [
        'Brace first.',
        'Pause, then lower.',
      ]);
      expect(tester.takeException(), isNull);
    });

    for (final useBack in [false, true]) {
      testWidgets(
        'dirty ${useBack ? 'back' : 'discard'} confirms once and preserves cancellation',
        (tester) async {
          final fixture = _EditorFixture();
          await fixture.pump(tester);
          await tester.enterText(_EditorFixture.name, 'Tempo Squat');
          await tester.pumpAndSettle();
          await _EditorFixture.tap(
            tester,
            useBack ? _EditorFixture.back : _EditorFixture.discard,
          );
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(
            find.text(AppStrings.customExerciseUnsavedChanges),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(TextButton, AppStrings.cancel));
          await tester.pumpAndSettle();
          expect(fixture.state(tester).draft.name, 'Tempo Squat');
          expect(fixture.returns, 0);
          await tester.tap(
            useBack ? _EditorFixture.back : _EditorFixture.discard,
          );
          await tester.pumpAndSettle();
          await tester.tap(
            _EditorFixture.dialogButton(AppStrings.customExerciseDiscard),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CustomExerciseEditorScreen), findsNothing);
          expect(find.byType(AlertDialog), findsNothing);
          expect(fixture.returns, 1);
          expect(fixture.result, isNull);
        },
      );
    }

    testWidgets('clean back returns without a discard dialog', (tester) async {
      final fixture = _EditorFixture();
      await fixture.pump(tester);
      await tester.tap(_EditorFixture.back);
      await tester.pumpAndSettle();
      expect(find.byType(CustomExerciseEditorScreen), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(fixture.returns, 1);
    });

    for (final mode in CustomExerciseEditorMode.values) {
      testWidgets('successful ${mode.name} saves once and Done returns true', (
        tester,
      ) async {
        final fixture = _EditorFixture(mode: mode);
        fixture.load.draft = _EditorFixture.validDraft;
        await fixture.pump(tester);
        await tester.tap(_EditorFixture.primary);
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.customExerciseSaved), findsOneWidget);
        expect(
          mode == CustomExerciseEditorMode.create
              ? fixture.save.created.length
              : fixture.save.updated.length,
          1,
        );
        expect(fixture.delete.deleted, isEmpty);
        await tester.tap(find.widgetWithText(FilledButton, AppStrings.done));
        await tester.pumpAndSettle();
        expect(fixture.result, isTrue);
        expect(fixture.returns, 1);
        expect(find.byType(CustomExerciseEditorScreen), findsNothing);
      });
    }

    testWidgets('save failure keeps input and Retry repeats save only', (
      tester,
    ) async {
      final fixture = _EditorFixture();
      fixture.load.draft = _EditorFixture.validDraft;
      fixture.save.shouldThrow = true;
      await fixture.pump(tester);
      await tester.tap(_EditorFixture.primary);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.customExerciseSaveFailed), findsOneWidget);
      expect(find.textContaining('private save failure'), findsNothing);
      expect(fixture.state(tester).draft.name, 'Cable Face Pulls');
      fixture.save.shouldThrow = false;
      await _EditorFixture.tap(tester, find.text(AppStrings.retry));
      expect(fixture.save.created.length, 2);
      expect(fixture.save.updated, isEmpty);
      expect(fixture.delete.deleted, isEmpty);
      expect(find.text(AppStrings.customExerciseSaved), findsOneWidget);
    });

    testWidgets(
      'delete cancellation is harmless and confirmation auto-exits true',
      (tester) async {
        final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
        await fixture.pump(tester);
        await tester.tap(find.byTooltip(AppStrings.customExerciseDelete));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(fixture.delete.deleted, isEmpty);
        expect(fixture.returns, 0);
        await fixture.confirmDelete(tester);
        await tester.pumpAndSettle();
        expect(fixture.delete.deleted, [-1]);
        expect(fixture.save.updated, isEmpty);
        expect(fixture.result, isTrue);
        expect(fixture.returns, 1);
      },
    );

    testWidgets('delete failure Retry repeats delete and never saves', (
      tester,
    ) async {
      final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
      fixture.delete.shouldThrow = true;
      await fixture.pump(tester);
      await fixture.confirmDelete(tester);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.customExerciseDeleteFailed), findsOneWidget);
      expect(find.textContaining('private delete failure'), findsNothing);
      fixture.delete.shouldThrow = false;
      await _EditorFixture.tap(tester, find.text(AppStrings.retry));
      expect(fixture.delete.deleted, [-1, -1]);
      expect(fixture.save.created, isEmpty);
      expect(fixture.save.updated, isEmpty);
      expect(fixture.result, isTrue);
      expect(fixture.returns, 1);
    });

    for (final deleting in [false, true]) {
      testWidgets(
        '${deleting ? 'deleting' : 'saving'} blocks edits, exit and duplicate operations',
        (tester) async {
          final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
          final pending = Completer<void>();
          if (deleting) {
            fixture.delete.pending = pending;
          } else {
            fixture.save.pending = pending;
          }
          await fixture.pump(tester);
          if (deleting) {
            await fixture.confirmDelete(tester);
          } else {
            await tester.tap(_EditorFixture.primary);
            await tester.pump();
          }
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            fixture.state(tester).phase,
            deleting
                ? CustomExerciseEditorPhase.deleting
                : CustomExerciseEditorPhase.saving,
          );
          expect(
            tester.widget<FilledButton>(_EditorFixture.primary).onPressed,
            isNull,
          );
          expect(
            tester
                .widget<EditableText>(
                  find.descendant(
                    of: _EditorFixture.name,
                    matching: find.byType(EditableText),
                  ),
                )
                .readOnly,
            isTrue,
          );
          expect(
            tester.widget<IconButton>(_EditorFixture.back).onPressed,
            isNull,
          );
          expect(
            tester
                .widget<IconButton>(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is IconButton &&
                        widget.tooltip == AppStrings.customExerciseDelete,
                  ),
                )
                .onPressed,
            isNull,
          );
          await tester.tap(_EditorFixture.primary);
          await tester.tap(_EditorFixture.discard);
          await tester.binding.handlePopRoute();
          await tester.pump();
          expect(fixture.returns, 0);
          expect(find.byType(AlertDialog), findsNothing);
          expect(fixture.save.updated.length, deleting ? 0 : 1);
          expect(fixture.delete.deleted.length, deleting ? 1 : 0);
          pending.complete();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('load errors stay sanitized and Retry reloads the same mode', (
      tester,
    ) async {
      final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
      fixture.load.shouldThrow = true;
      await fixture.pump(tester);
      expect(find.text(AppStrings.customExerciseLoadFailed), findsOneWidget);
      expect(find.textContaining('private load failure'), findsNothing);
      fixture.load.shouldThrow = false;
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(
        _EditorFixture.textController(tester, _EditorFixture.name).text,
        'Cable Face Pulls',
      );
      expect(fixture.load.loads, greaterThanOrEqualTo(2));
    });

    for (final brightness in Brightness.values) {
      testWidgets(
        '320px, 2x text and keyboard keep controls reachable in ${brightness.name}',
        (tester) async {
          final fixture = _EditorFixture(mode: CustomExerciseEditorMode.edit);
          await fixture.pump(
            tester,
            brightness: brightness,
            width: 320,
            scale: 2,
            accessible: true,
          );
          expect(tester.takeException(), isNull);
          for (final key in [
            'custom_exercise_difficulty_advanced',
            'custom_exercise_modality_cardio',
            'custom_exercise_logging_duration',
          ]) {
            await _EditorFixture.tap(tester, find.byKey(Key(key)));
            expect(tester.takeException(), isNull);
          }
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.pumpAndSettle();
          await Scrollable.ensureVisible(
            tester.element(_EditorFixture.instructions),
            alignment: 1,
          );
          await tester.pumpAndSettle();
          expect(_EditorFixture.primary.hitTestable(), findsOneWidget);
          expect(
            tester.getBottomRight(_EditorFixture.primary).dy,
            lessThanOrEqualTo(884 - 280),
          );
          expect(
            tester.getBottomRight(_EditorFixture.instructions).dy,
            lessThanOrEqualTo(tester.getTopLeft(_EditorFixture.actions).dy),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
