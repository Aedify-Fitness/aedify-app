import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeDetailsSection extends StatelessWidget {
  const ProgrammeDetailsSection({
    super.key,
    required this.nameController,
    required this.onNameChanged,
    this.descriptionController,
    this.description,
    this.onDescriptionChanged,
    this.selectedGoals = const {},
    this.onGoalsChanged,
    this.selectedEquipment = const {},
  });

  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final TextEditingController? descriptionController;
  final String? description;
  final ValueChanged<String>? onDescriptionChanged;
  final Set<GoalTag> selectedGoals;
  final ValueChanged<Set<GoalTag>>? onGoalsChanged;
  final Set<EquipmentTag> selectedEquipment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.programmeDetailsSectionTitle,
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hLg,
            _UtilityPanel(
              label: AppStrings.programmeName,
              child: AppTextField(
                controller: nameController,
                hintText: AppStrings.programmeNameHint,
                onChanged: onNameChanged,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                fillColor: context.colorScheme.surfaceContainerLowest,
                borderRadius: AppRadius.md,
                style: AppTextStyles.bodyLg,
              ),
            ),
            AppWhiteSpace.hSm,
            _UtilityPanel(
              label: AppStrings.notes,
              child: descriptionController != null
                  ? AppTextField(
                      controller: descriptionController!,
                      hintText: AppStrings.optionalDescription,
                      onChanged: onDescriptionChanged,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      fillColor: context.colorScheme.surfaceContainerLowest,
                      borderRadius: AppRadius.md,
                    )
                  : Text(
                      description?.trim().isNotEmpty == true
                          ? description!
                          : AppStrings.optionalDescription,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: description?.trim().isNotEmpty == true
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            if (onGoalsChanged != null) ...[
              AppWhiteSpace.hSm,
              _UtilityPanel(
                label: AppStrings.goals,
                supportingText: AppStrings.onboardingGoalsHint,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: GoalTag.values.map((goal) {
                    final isSelected = selectedGoals.contains(goal);
                    return _SelectionPill(
                      label: _goalLabel(goal),
                      isSelected: isSelected,
                      onTap: () {
                        final updated = Set<GoalTag>.from(selectedGoals);
                        isSelected ? updated.remove(goal) : updated.add(goal);
                        onGoalsChanged!(updated);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            AppWhiteSpace.hSm,
            _UtilityPanel(
              label: AppStrings.equipment,
              child: selectedEquipment.isEmpty
                  ? Text(
                      AppStrings.onboardingReviewNotConfigured,
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: selectedEquipment
                          .map(
                            (equipment) => _SelectionPill(
                              label: _equipmentLabel(equipment),
                              isSelected: true,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _goalLabel(GoalTag goal) {
    return switch (goal) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  String _equipmentLabel(EquipmentTag equipment) {
    return switch (equipment) {
      EquipmentTag.bodyweight => AppStrings.onboardingEquipmentNone,
      EquipmentTag.dumbbell => AppStrings.onboardingEquipmentDumbbells,
      EquipmentTag.barbell => AppStrings.onboardingEquipmentBarbell,
      EquipmentTag.kettlebell => AppStrings.onboardingEquipmentKettlebell,
      EquipmentTag.bands => AppStrings.onboardingEquipmentResistanceBands,
      EquipmentTag.cable => AppStrings.onboardingEquipmentCableMachine,
      EquipmentTag.machine => AppStrings.onboardingEquipmentMachine,
      EquipmentTag.smithMachine => AppStrings.onboardingEquipmentSmithMachine,
      EquipmentTag.pullUpBar => AppStrings.onboardingEquipmentPullUpBar,
      EquipmentTag.bench => AppStrings.onboardingEquipmentBench,
      EquipmentTag.squatRack => AppStrings.onboardingEquipmentSquatRack,
      EquipmentTag.cardioMachine => AppStrings.onboardingEquipmentCardioMachine,
      EquipmentTag.ezBar => AppStrings.onboardingEquipmentEzBar,
      EquipmentTag.bosuBall => AppStrings.onboardingEquipmentBosuBall,
      EquipmentTag.medicineBall => AppStrings.onboardingEquipmentMedicineBall,
      EquipmentTag.plate => AppStrings.onboardingEquipmentPlate,
      EquipmentTag.trx => AppStrings.onboardingEquipmentTrx,
      EquipmentTag.vitruvian => AppStrings.onboardingEquipmentVitruvian,
      EquipmentTag.other => AppStrings.onboardingEquipmentOther,
    };
  }
}

class _UtilityPanel extends StatelessWidget {
  const _UtilityPanel({
    required this.label,
    required this.child,
    this.supportingText,
  });

  final String label;
  final String? supportingText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            if (supportingText != null) ...[
              AppWhiteSpace.hXs,
              Text(
                supportingText!,
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            AppWhiteSpace.hSm,
            child,
          ],
        ),
      ),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    SvgPicture.asset(
                      OutlinedSvgAssets.check,
                      width: AppSizing.iconXs,
                      height: AppSizing.iconXs,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSecondaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wXs,
                  ],
                  Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
