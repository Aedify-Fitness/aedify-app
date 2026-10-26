import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_details_section.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:flutter/material.dart';

class ProgrammeBuilderDetailsPage extends StatelessWidget {
  const ProgrammeBuilderDetailsPage({
    super.key,
    required this.draft,
    required this.nameController,
    required this.descriptionController,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onGoalsChanged,
    this.nameError,
    this.goalsError,
  });

  final ProgrammeBuilderDraft draft;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<Set<GoalTag>> onGoalsChanged;
  final String? nameError;
  final String? goalsError;

  @override
  Widget build(BuildContext context) => ProgrammeDetailsSection(
    nameError: nameError,
    goalsError: goalsError,
    nameController: nameController,
    onNameChanged: onNameChanged,
    descriptionController: descriptionController,
    onDescriptionChanged: onDescriptionChanged,
    selectedGoals: draft.goalTags ?? {},
    onGoalsChanged: onGoalsChanged,
    selectedEquipment: draft.equipment ?? {},
  );
}
