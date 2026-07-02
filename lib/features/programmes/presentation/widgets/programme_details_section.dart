import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeDetailsSection extends StatelessWidget {
  const ProgrammeDetailsSection({
    super.key,
    required this.nameController,
    required this.onNameChanged,
    this.descriptionController,
    this.onDescriptionChanged,
    this.selectedGoals = const {},
    this.onGoalsChanged,
  });

  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final TextEditingController? descriptionController;
  final ValueChanged<String>? onDescriptionChanged;
  final Set<GoalTag> selectedGoals;
  final ValueChanged<Set<GoalTag>>? onGoalsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.programmeDetailsSectionTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: AppStrings.programmeName,
            hintText: AppStrings.programmeNameHint,
          ),
          onChanged: onNameChanged,
        ),
        if (descriptionController != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: AppStrings.notes,
              hintText: AppStrings.optionalDescription,
            ),
            onChanged: onDescriptionChanged,
            maxLines: 2,
          ),
        ],
        if (onGoalsChanged != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.onboardingGoalsHint,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: GoalTag.values.map((goal) {
              final isSelected = selectedGoals.contains(goal);
              return FilterChip(
                label: Text(_goalLabel(goal), style: AppTextStyles.labelSm),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<GoalTag>.from(selectedGoals);
                  if (selected) {
                    updated.add(goal);
                  } else {
                    updated.remove(goal);
                  }
                  onGoalsChanged!(updated);
                },
                selectedColor: context.colorScheme.secondaryContainer,
                checkmarkColor: context.colorScheme.onSecondaryContainer,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  String _goalLabel(GoalTag goal) {
    return switch (goal) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }
}
