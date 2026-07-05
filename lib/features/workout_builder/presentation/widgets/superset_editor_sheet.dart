import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/superset_grouping_policy.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class SupersetEditorSheet extends StatelessWidget {
  const SupersetEditorSheet({
    super.key,
    required this.exercises,
    required this.selectedExerciseIds,
    required this.onToggleSelection,
    required this.onCreateSuperset,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final Set<String> selectedExerciseIds;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onCreateSuperset;

  @override
  Widget build(BuildContext context) {
    final policy = const SupersetGroupingPolicy();
    final canCreate = policy.canCreateGroup(selectedExerciseIds.length);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.createSuperset, style: AppTextStyles.headlineMd),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.supersetInvalidSelection,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hMd,
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                AppStrings.noExercisesAdded,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...exercises.map((exercise) {
              final isSelected = selectedExerciseIds.contains(exercise.id);
              return CheckboxListTile(
                title: Text(exercise.exercise.name),
                value: isSelected,
                onChanged: (_) => onToggleSelection(exercise.id),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
          AppWhiteSpace.hSm,
          FilledButton.icon(
            onPressed: canCreate ? onCreateSuperset : null,
            icon: const Icon(Icons.link),
            label: Text(AppStrings.createSuperset),
          ),
        ],
      ),
    );
  }
}
