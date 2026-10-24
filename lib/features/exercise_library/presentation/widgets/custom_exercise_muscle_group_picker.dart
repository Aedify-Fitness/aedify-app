import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomExerciseMuscleGroupPicker extends StatelessWidget {
  const CustomExerciseMuscleGroupPicker({
    super.key,
    required this.selected,
    required this.onToggle,
    this.errorText,
    this.enabled = true,
  });

  final Set<BodymapBucket> selected;
  final ValueChanged<BodymapBucket> onToggle;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            AppStrings.customExerciseMuscleGroups,
            style: CustomExerciseEditorStyle.heading(context),
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.customExerciseMuscleGroupsHint,
          style: CustomExerciseEditorStyle.small(context),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText!,
                style: CustomExerciseEditorStyle.small(
                  context,
                ).copyWith(color: context.colorScheme.error),
              ),
            ),
          ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: BodymapBucket.values.map((bucket) {
            final isSelected = selected.contains(bucket);
            return MergeSemantics(
              child: Semantics(
                selected: isSelected,
                enabled: enabled,
                child: TextButton(
                  key: ValueKey('custom_exercise_muscle_${bucket.name}'),
                  onPressed: enabled ? () => onToggle(bucket) : null,
                  style: CustomExerciseEditorStyle.choiceStyle(
                    context,
                    selected: isSelected,
                  ),
                  child: Text(bucket.label),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
