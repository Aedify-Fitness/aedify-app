import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomExerciseMuscleGroupPicker extends StatelessWidget {
  const CustomExerciseMuscleGroupPicker({
    super.key,
    required this.selected,
    required this.onToggle,
    this.errorText,
  });

  final Set<BodymapBucket> selected;
  final ValueChanged<BodymapBucket> onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.customExerciseMuscleGroups,
          style: AppTextStyles.labelMd,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(errorText!, style: AppTextStyles.labelSm),
          ),
        AppWhiteSpace.hXs,
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: BodymapBucket.values
              .map(
                (bucket) => FilterChip(
                  label: Text(bucket.label),
                  selected: selected.contains(bucket),
                  onSelected: (_) => onToggle(bucket),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
