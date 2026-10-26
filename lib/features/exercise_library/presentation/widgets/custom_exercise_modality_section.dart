import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class CustomExerciseModalitySection extends StatelessWidget {
  const CustomExerciseModalitySection({
    super.key,
    required this.modality,
    required this.onChanged,
    this.enabled = true,
  });

  final ExerciseModality modality;
  final ValueChanged<ExerciseModality> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            AppStrings.customExerciseModality,
            style: CustomExerciseEditorStyle.label(context),
          ),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: ExerciseModality.values.map((value) {
            final isSelected = value == modality;
            return MergeSemantics(
              child: Semantics(
                selected: isSelected,
                enabled: enabled,
                inMutuallyExclusiveGroup: true,
                child: TextButton(
                  key: ValueKey('custom_exercise_modality_${value.name}'),
                  onPressed: enabled ? () => onChanged(value) : null,
                  style: CustomExerciseEditorStyle.choiceStyle(
                    context,
                    selected: isSelected,
                  ),
                  child: Text(
                    CustomExerciseEditorStyle.formatLabel(value.dbValue),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
