import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_card.dart';

class WorkoutExerciseList extends StatelessWidget {
  const WorkoutExerciseList({
    super.key,
    required this.exercises,
    required this.onReorder,
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
    this.onRestChanged,
  });

  final List<WorkoutBuilderExerciseDraft> exercises;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onDuplicate;
  final ValueChanged<String> onAddSet;
  final void Function(
    String exerciseDraftId,
    String setId,
    SetPrescriptionDraft prescription,
  )
  onUpdateSet;
  final void Function(String exerciseDraftId, String setId) onRemoveSet;
  final List<WorkoutBuilderValidationError> validationErrors;
  final List<SetTypeOption> setTypeOptions;
  final VoidCallback? onOpenSupersetEditor;
  final ValueChanged<String>? onRemoveFromSuperset;
  final ValueChanged<String>? onDeleteSuperset;
  final void Function(String exerciseDraftId, int? restSeconds)? onRestChanged;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppStrings.noExercisesAdded, style: AppTextStyles.bodyMd),
            AppWhiteSpace.hSm,
            Text(AppStrings.noExercisesAddedHint, style: AppTextStyles.labelSm),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: exercises.length,
      onReorderItem: onReorder,
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final exerciseErrors = validationErrors
            .where((e) => e.exerciseId == exercise.id)
            .toList();
        return WorkoutExerciseCard(
          key: ValueKey(exercise.id),
          exercise: exercise,
          setTypeOptions: setTypeOptions,
          onRemove: () => onRemove(exercise.id),
          onDuplicate: () => onDuplicate(exercise.id),
          onAddSet: () => onAddSet(exercise.id),
          onUpdateSet: (setId, prescription) =>
              onUpdateSet(exercise.id, setId, prescription),
          onRemoveSet: (setId) => onRemoveSet(exercise.id, setId),
          validationErrors: exerciseErrors,
          onOpenSupersetEditor: onOpenSupersetEditor,
          onRemoveFromSuperset: onRemoveFromSuperset != null
              ? () => onRemoveFromSuperset!(exercise.id)
              : null,
          onDeleteSuperset:
              exercise.supersetGroupId != null && onDeleteSuperset != null
              ? () => onDeleteSuperset!(exercise.supersetGroupId!)
              : null,
          onRestChanged: onRestChanged != null
              ? (rest) => onRestChanged!(exercise.id, rest)
              : null,
        );
      },
    );
  }
}
