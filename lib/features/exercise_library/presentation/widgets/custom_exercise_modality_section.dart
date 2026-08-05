import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomExerciseModalitySection extends StatelessWidget {
  const CustomExerciseModalitySection({
    super.key,
    required this.modality,
    required this.onChanged,
  });

  final ExerciseModality modality;
  final ValueChanged<ExerciseModality> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            AppStrings.customExerciseModality.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: ExerciseModality.values.map((m) {
            final isSelected = m == modality;
            return Semantics(
              button: true,
              selected: isSelected,
              child: GestureDetector(
                onTap: () => onChanged(m),
                child: Container(
                  key: ValueKey('custom_exercise_modality_${m.name}'),
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
                    _formatLabel(m.dbValue),
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

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
