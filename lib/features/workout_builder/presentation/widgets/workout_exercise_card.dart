import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_prescription_list.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
    required this.onRemove,
    required this.onDuplicate,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onRemoveSet,
    required this.validationErrors,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final VoidCallback onRemove;
  final VoidCallback onDuplicate;
  final VoidCallback onAddSet;
  final void Function(String setId, SetPrescriptionDraft prescription)
  onUpdateSet;
  final void Function(String setId) onRemoveSet;
  final List<WorkoutBuilderValidationError> validationErrors;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: exercise.sortOrder,
                  child: const Icon(Icons.drag_handle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    exercise.exercise.name.isNotEmpty
                        ? exercise.exercise.name
                        : AppStrings.exerciseNumberLabel(
                            exercise.sortOrder + 1,
                          ),
                    style: AppTextStyles.bodyMd,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: AppSpacing.md),
                  onPressed: onDuplicate,
                  tooltip: AppStrings.duplicateExercise,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: AppSpacing.md),
                  onPressed: onRemove,
                  tooltip: AppStrings.removeExercise,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SetPrescriptionList(
              exerciseDraftId: exercise.id,
              sets: exercise.sets,
              onUpdateSet: onUpdateSet,
              onRemoveSet: onRemoveSet,
              validationErrors: validationErrors,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: AppSpacing.md),
              label: Text(AppStrings.addSet),
            ),
          ],
        ),
      ),
    );
  }
}
