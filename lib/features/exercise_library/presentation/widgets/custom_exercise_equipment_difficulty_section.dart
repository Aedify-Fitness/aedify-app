import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseEquipmentDifficultySection extends StatelessWidget {
  const CustomExerciseEquipmentDifficultySection({
    super.key,
    required this.equipment,
    required this.onEquipmentChanged,
    required this.difficulty,
    required this.onDifficultyChanged,
    this.enabled = true,
  });

  final EquipmentTag? equipment;
  final ValueChanged<EquipmentTag?> onEquipmentChanged;
  final ExerciseDifficulty? difficulty;
  final ValueChanged<ExerciseDifficulty?> onDifficultyChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            AppStrings.customExerciseEquipment,
            style: CustomExerciseEditorStyle.label(context),
          ),
        ),
        AppWhiteSpace.hMd,
        Material(
          key: const Key('custom_exercise_equipment_control'),
          color: CustomExerciseEditorStyle.panel(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppCustomExerciseEditorTokens.controlSize,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EquipmentTag>(
                  value: equipment,
                  isExpanded: true,
                  itemHeight: null,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  hint: Text(
                    AppStrings.customExerciseEquipmentSelect,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomExerciseEditorStyle.body(
                      context,
                    ).copyWith(color: cs.onSurfaceVariant),
                  ),
                  selectedItemBuilder: (context) => EquipmentTag.values
                      .map(
                        (tag) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            CustomExerciseEditorStyle.formatLabel(tag.dbValue),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomExerciseEditorStyle.body(context),
                          ),
                        ),
                      )
                      .toList(),
                  items: EquipmentTag.values
                      .map(
                        (tag) => DropdownMenuItem<EquipmentTag>(
                          value: tag,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.controlGap,
                            ),
                            child: Text(
                              CustomExerciseEditorStyle.formatLabel(
                                tag.dbValue,
                              ),
                              style: CustomExerciseEditorStyle.body(context),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: enabled ? onEquipmentChanged : null,
                  style: CustomExerciseEditorStyle.body(context),
                  dropdownColor: CustomExerciseEditorStyle.panel(context),
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.chevronDown,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      cs.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AppWhiteSpace.hLg,
        Semantics(
          header: true,
          child: Text(
            AppStrings.customExerciseDifficulty,
            style: CustomExerciseEditorStyle.label(context),
          ),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          key: const Key('custom_exercise_difficulty_control'),
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: ExerciseDifficulty.values.map((value) {
            final isSelected = difficulty == value;
            return MergeSemantics(
              child: Semantics(
                selected: isSelected,
                enabled: enabled,
                inMutuallyExclusiveGroup: true,
                child: TextButton(
                  key: ValueKey('custom_exercise_difficulty_${value.name}'),
                  onPressed: enabled ? () => onDifficultyChanged(value) : null,
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
