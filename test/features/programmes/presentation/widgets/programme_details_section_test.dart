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

    await tester.tap(find.text(AppStrings.onboardingGoalIncreaseStrength));
    expect(
      selectedGoals,
      containsAll(<GoalTag>[GoalTag.buildMuscle, GoalTag.increaseStrength]),
    );
  });
}
