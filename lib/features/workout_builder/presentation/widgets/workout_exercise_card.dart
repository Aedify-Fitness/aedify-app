import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_prescription_list.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_actions_menu.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_group_badge.dart';

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
    required this.setTypeOptions,
    this.onOpenSupersetEditor,
    this.onRemoveFromSuperset,
    this.onDeleteSuperset,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final VoidCallback onRemove;
  final VoidCallback onDuplicate;
  final VoidCallback onAddSet;
  final void Function(String setId, SetPrescriptionDraft prescription)
  onUpdateSet;
  final void Function(String setId) onRemoveSet;
  final List<WorkoutBuilderValidationError> validationErrors;
  final List<SetTypeOption> setTypeOptions;
  final VoidCallback? onOpenSupersetEditor;
  final VoidCallback? onRemoveFromSuperset;
  final VoidCallback? onDeleteSuperset;

  @override
  Widget build(BuildContext context) {
    final isGrouped = exercise.supersetGroupId != null;

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
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.bars3,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isGrouped && exercise.supersetOrder != null) ...[
                  SupersetGroupBadge(
                    groupId: exercise.supersetGroupId!,
                    order: exercise.supersetOrder,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
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
                if (onOpenSupersetEditor != null ||
                    onRemoveFromSuperset != null ||
                    onDeleteSuperset != null)
                  SupersetActionsMenu(
                    isGrouped: isGrouped,
                    onCreateSuperset: onOpenSupersetEditor ?? () {},
                    onRemoveFromSuperset: onRemoveFromSuperset ?? () {},
                    onDeleteSuperset: onDeleteSuperset ?? () {},
                  ),
                IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.documentDuplicate,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                  onPressed: onDuplicate,
                  tooltip: AppStrings.duplicateExercise,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.trash,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                  onPressed: onRemove,
                  tooltip: AppStrings.removeExercise,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SetPrescriptionList(
              exerciseDraftId: exercise.id,
              sets: exercise.sets,
              setTypeOptions: setTypeOptions,
              onUpdateSet: onUpdateSet,
              onRemoveSet: onRemoveSet,
              validationErrors: validationErrors,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onAddSet,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              label: Text(AppStrings.addSet),
            ),
          ],
        ),
      ),
    );
  }
}
