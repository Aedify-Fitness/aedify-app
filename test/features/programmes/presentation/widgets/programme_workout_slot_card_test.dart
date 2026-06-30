import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_workout_slot_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  group('ProgrammeWorkoutSlotCard', () {
    testWidgets('displays template name when template is assigned', (
      tester,
    ) async {
      final slot = ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: 0,
        scheduledDayIndex: 0,
        template: ProgrammeBuilderTemplateDraft(
          id: 't-1',
          templateKey: 't-1',
          name: 'Upper Body',
        ),
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWorkoutSlotCard(
            slot: slot,
            onAssignTemplate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text('Upper Body'), findsOneWidget);
    });

    testWidgets('displays placeholder when no template is assigned', (
      tester,
    ) async {
      final slot = ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: 0,
        scheduledDayIndex: 0,
        template: null,
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWorkoutSlotCard(
            slot: slot,
            onAssignTemplate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.weekTemplateEmpty), findsOneWidget);
    });

    testWidgets('calls onAssignTemplate when swap button is tapped', (
      tester,
    ) async {
      bool assigned = false;
      final slot = ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: 0,
        scheduledDayIndex: 0,
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWorkoutSlotCard(
            slot: slot,
            onAssignTemplate: () => assigned = true,
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.assignTemplate));
      expect(assigned, isTrue);
    });

    testWidgets('calls onRemove when close button is tapped', (tester) async {
      bool removed = false;
      final slot = ProgrammeBuilderWorkoutSlotDraft(
        slotIndex: 0,
        scheduledDayIndex: 0,
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWorkoutSlotCard(
            slot: slot,
            onAssignTemplate: () {},
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.removeSlot));
      expect(removed, isTrue);
    });
  });
}
