import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_save_bar.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';

ProviderScope _wrap(Widget widget) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: widget)),
  );
}

ProgrammeBuilderState _state({
  bool isDirty = false,
  bool isSaving = false,
  String name = 'Test',
  bool hasWeeks = false,
}) {
  return ProgrammeBuilderState(
    mode: ProgrammeBuilderMode.create,
    phase: isSaving
        ? ProgrammeBuilderPhase.saving
        : ProgrammeBuilderPhase.editing,
    draft: ProgrammeBuilderDraft(
      id: 'test-id',
      name: name,
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: ProgramStatus.draft,
      weeks: hasWeeks
          ? [const ProgrammeBuilderWeekDraft(id: 'w1', weekNumber: 1)]
          : null,
    ),
    validationErrors: [],
    isDirty: isDirty,
  );
}

void main() {
  group('ProgrammeSaveBar', () {
    testWidgets('shows dirty indicator when isDirty is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(isDirty: true),
            onSave: () {},
            onToggleActive: () {},
          ),
        ),
      );

      expect(
        find.byKey(const Key('programme_dirty_indicator')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.unsavedProgrammeChanges), findsOneWidget);
    });

    testWidgets('hides dirty indicator when isDirty is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(isDirty: false),
            onSave: () {},
            onToggleActive: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('programme_dirty_indicator')), findsNothing);
    });

    testWidgets(
      'save button is enabled when name is non-empty and not saving',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ProgrammeSaveBar(
              state: _state(name: 'Valid', isDirty: true, hasWeeks: true),
              onSave: () {},
              onToggleActive: () {},
            ),
          ),
        );

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('save button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(name: '', isDirty: true),
            onSave: () {},
            onToggleActive: () {},
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('save button shows spinner when saving', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(isDirty: true, isSaving: true),
            onSave: () {},
            onToggleActive: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.saveProgramme), findsNothing);
    });

    testWidgets('calls onSave when save button is tapped', (tester) async {
      bool saved = false;
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(isDirty: true, hasWeeks: true),
            onSave: () => saved = true,
            onToggleActive: () {},
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(saved, isTrue);
    });

    testWidgets('calls onToggleActive from the explicit status control', (
      tester,
    ) async {
      bool toggled = false;
      await tester.pumpWidget(
        _wrap(
          ProgrammeSaveBar(
            state: _state(hasWeeks: true),
            onSave: () {},
            onToggleActive: () => toggled = true,
          ),
        ),
      );

      expect(find.text(AppStrings.programmeInactive), findsOneWidget);
      await tester.tap(find.byType(AppTogglePill));
      expect(toggled, isTrue);
    });
  });
}
