import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  group('ProgrammeWeekCard', () {
    testWidgets('displays week number', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 3,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 2,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text('${AppStrings.weekLabelPrefix} 3'), findsOneWidget);
    });

    testWidgets('shows add workout slot button', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.addWorkoutSlot), findsOneWidget);
    });

    testWidgets('displays slot cards for each slot', (tester) async {
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 't-1',
              templateKey: 't-1',
              name: 'Push Day',
            ),
          ),
          ProgrammeBuilderWorkoutSlotDraft(slotIndex: 1, scheduledDayIndex: 1),
        ],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text(AppStrings.weekTemplateEmpty), findsOneWidget);
    });

    testWidgets('calls onDuplicate when duplicate button is tapped', (
      tester,
    ) async {
      bool duplicated = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () => duplicated = true,
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.duplicateWeek));
      expect(duplicated, isTrue);
    });

    testWidgets('calls onRemove when remove button is tapped', (tester) async {
      bool removed = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () {},
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.tap(find.byTooltip(AppStrings.removeWeek));
      expect(removed, isTrue);
    });

    testWidgets('calls onAddSlot when add slot button is tapped', (
      tester,
    ) async {
      bool added = false;
      final week = ProgrammeBuilderWeekDraft(
        id: 'w1',
        weekNumber: 1,
        slots: [],
      );
      await tester.pumpWidget(
        _wrap(
          ProgrammeWeekCard(
            week: week,
            weekIndex: 0,
            onAddSlot: () => added = true,
            onRemoveSlot: (_) {},
            onAssignTemplate: (_) {},
            onDuplicate: () {},
            onRemove: () {},
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.addWorkoutSlot));
      expect(added, isTrue);
    });
  });
}
