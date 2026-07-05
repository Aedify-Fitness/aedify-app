import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomExerciseModalitySection extends StatelessWidget {
  const CustomExerciseModalitySection({
    super.key,
    required this.modality,
    required this.onChanged,
    required this.equipment,
    required this.onEquipmentChanged,
    required this.difficulty,
    required this.onDifficultyChanged,
  });

  final ExerciseModality modality;
  final ValueChanged<ExerciseModality> onChanged;
  final EquipmentTag? equipment;
  final ValueChanged<EquipmentTag?> onEquipmentChanged;
  final ExerciseDifficulty? difficulty;
  final ValueChanged<ExerciseDifficulty?> onDifficultyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.customExerciseModality, style: AppTextStyles.labelMd),
        AppWhiteSpace.hXs,
        SegmentedButton<ExerciseModality>(
          segments: ExerciseModality.values
              .map(
                (m) => ButtonSegment<ExerciseModality>(
                  value: m,
                  label: Text(_formatLabel(m.dbValue)),
                ),
              )
              .toList(),
          selected: {modality},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
        AppWhiteSpace.hMd,
        DropdownButtonFormField<EquipmentTag>(
          initialValue: equipment,
          decoration: InputDecoration(
            labelText: AppStrings.customExerciseEquipment,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          items: [
            DropdownMenuItem<EquipmentTag>(
              value: null,
              child: Text(AppStrings.filterAny),
            ),
            ...EquipmentTag.values.map(
              (tag) => DropdownMenuItem<EquipmentTag>(
                value: tag,
                child: Text(_formatLabel(tag.dbValue)),
              ),
            ),
          ],
          onChanged: onEquipmentChanged,
        ),
        AppWhiteSpace.hMd,
        DropdownButtonFormField<ExerciseDifficulty>(
          initialValue: difficulty,
          decoration: InputDecoration(
            labelText: AppStrings.customExerciseDifficulty,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          items: [
            DropdownMenuItem<ExerciseDifficulty>(
              value: null,
              child: Text(AppStrings.filterAny),
            ),
            ...ExerciseDifficulty.values.map(
              (d) => DropdownMenuItem<ExerciseDifficulty>(
                value: d,
                child: Text(_formatLabel(d.dbValue)),
              ),
            ),
          ],
          onChanged: onDifficultyChanged,
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
