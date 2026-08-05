import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
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
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            AppStrings.customExercisePrimaryMuscleGroup.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(errorText!, style: AppTextStyles.labelSm),
          ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: BodymapBucket.values.map((bucket) {
            final isSelected = selected.contains(bucket);
            return Semantics(
              button: true,
              selected: isSelected,
              child: GestureDetector(
                onTap: () => onToggle(bucket),
                child: Container(
                  key: ValueKey('custom_exercise_muscle_${bucket.name}'),
                  constraints: const BoxConstraints(
                    minHeight: AppSizing.cardBadge,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.formChipHorizontal,
                    vertical: AppSpacing.formChipVertical,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.secondaryContainer
                        : cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? cs.secondary.withValues(alpha: 0.2)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Text(
                    bucket.label,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? cs.onSecondaryContainer
                          : cs.onSurfaceVariant,
                    ),
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
