import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_details_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  testWidgets('uses custom goal pills and reports goal selection', (
    tester,
  ) async {
    final controller = TextEditingController();
    Set<GoalTag>? selectedGoals;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        ProgrammeDetailsSection(
          nameController: controller,
          onNameChanged: (_) {},
          selectedGoals: const {GoalTag.buildMuscle},
          onGoalsChanged: (goals) => selectedGoals = goals,
          selectedEquipment: const {EquipmentTag.dumbbell},
        ),
      ),
    );

    expect(find.byType(FilterChip), findsNothing);
    expect(find.text(AppStrings.onboardingEquipmentDumbbells), findsOneWidget);

    await tester.tap(find.text(AppStrings.strengthGoal));
    expect(
      selectedGoals,
      containsAll(<GoalTag>[GoalTag.buildMuscle, GoalTag.increaseStrength]),
    );
  });
  testWidgets('More goals and Notes keep borderless sections when expanded', (
    tester,
  ) async {
    final name = TextEditingController();
    final notes = TextEditingController();
    addTearDown(name.dispose);
    addTearDown(notes.dispose);
    await tester.pumpWidget(
      _wrap(
        ProgrammeDetailsSection(
          nameController: name,
          onNameChanged: (_) {},
          onGoalsChanged: (_) {},
          descriptionController: notes,
        ),
      ),
    );
    await tester.tap(find.text(AppStrings.moreGoals));
    await tester.pumpAndSettle();
    final notesLabel = find.text(AppStrings.notes);
    await tester.ensureVisible(notesLabel);
    await tester.tap(notesLabel);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.onboardingGoalLoseWeight), findsOneWidget);
    expect(find.text(AppStrings.optionalDescription), findsOneWidget);
    for (final section in tester.widgetList<ExpansionTile>(
      find.byType(ExpansionTile),
    )) {
      expect(section.shape!.dimensions, EdgeInsets.zero);
      expect(section.collapsedShape!.dimensions, EdgeInsets.zero);
    }
    expect(tester.takeException(), isNull);
  });
}
