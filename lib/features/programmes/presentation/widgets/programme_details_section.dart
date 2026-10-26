import 'package:aedify/features/programmes/presentation/widgets/programme_builder_section.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.durationWeeks = 0,
    this.onDurationChanged,
    this.nameError,
    this.goalsError,
  });

  final String? nameError;
  final String? goalsError;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final TextEditingController? descriptionController;
  final String? description;
  final ValueChanged<String>? onDescriptionChanged;
  final Set<GoalTag> selectedGoals;
  final ValueChanged<Set<GoalTag>>? onGoalsChanged;
  final Set<EquipmentTag> selectedEquipment;
  final int durationWeeks;
  final ValueChanged<int>? onDurationChanged;

  static const _primaryGoals = [
    GoalTag.buildMuscle,
    GoalTag.increaseStrength,
    GoalTag.improveEndurance,
  ];

  @override
  Widget build(BuildContext context) => ProgrammeBuilderSection(
    title: AppStrings.programmeDetailsSectionTitle,
    asset: OutlinedSvgAssets.materialEditNote,
    child: ProgrammeBuilderPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            label: AppStrings.programmeName,
            child: AppTextField(
              key: const ValueKey('programme_name_field'),
              controller: nameController,
              hintText: AppStrings.programmeNameHint,
              errorText: nameError,
              onChanged: onNameChanged,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              fillColor: context.colorScheme.surfaceContainerLow,
              borderRadius: AppRadius.defaultRadius,
            ),
          ),
          if (onGoalsChanged != null) ...[
            AppWhiteSpace.hLg,
            _goalFields(context),
          ],
          if (onDurationChanged != null) ...[
            AppWhiteSpace.hLg,
            _durationField(context),
          ],
          if (descriptionController != null) ...[
            AppWhiteSpace.hSm,
            Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: descriptionController!.text
                    .trim()
                    .isNotEmpty,
                trailing: SvgPicture.asset(
                  OutlinedSvgAssets.chevronDown,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  AppStrings.notes,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                children: [
                  AppTextField(
                    controller: descriptionController!,
                    hintText: AppStrings.optionalDescription,
                    onChanged: onDescriptionChanged,
                    maxLines: 3,
                    fillColor: context.colorScheme.surfaceContainerLow,
                    borderRadius: AppRadius.defaultRadius,
                  ),
                ],
              ),
            ),
          ] else if (description?.isNotEmpty == true) ...[
            AppWhiteSpace.hLg,
            _Field(
              label: AppStrings.notes,
              child: Text(description ?? '', style: AppTextStyles.bodyMd),
            ),
          ],
          if (selectedEquipment.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            _Field(
              label: AppStrings.equipment,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: selectedEquipment
                    .map(
                      (equipment) => Chip(
                        label: Text(
                          _equipmentLabel(equipment),
                          style: AppTextStyles.labelSm,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _goalFields(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Field(
        label: AppStrings.primaryGoal,
        child: _goals(context, _primaryGoals),
      ),
      if (goalsError != null) ...[
        AppWhiteSpace.hSm,
        Semantics(
          liveRegion: true,
          child: Text(
            goalsError!,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ),
      ],
      ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: selectedGoals.any(
          (goal) => !_primaryGoals.contains(goal),
        ),
        trailing: SvgPicture.asset(
          OutlinedSvgAssets.chevronDown,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        title: Text(
          AppStrings.moreGoals,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          _goals(
            context,
            GoalTag.values
                .where((goal) => !_primaryGoals.contains(goal))
                .toList(),
          ),
        ],
      ),
    ],
  );

  Widget _durationField(BuildContext context) => _Field(
    label: AppStrings.duration,
    child: InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const ValueKey('programme_duration'),
          value: durationWeeks,
          isExpanded: true,
          icon: SvgPicture.asset(
            OutlinedSvgAssets.chevronDown,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          items:
              ({
                    durationWeeks,
                    ...AppProgrammeBuilderTokens.durationWeeks,
                  }.toList()..sort())
                  .map(
                    (count) => DropdownMenuItem(
                      value: count,
                      child: Text(
                        count == 0
                            ? AppStrings.selectProgrammeDuration
                            : AppStrings.programmeDurationWeeks(count),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null && value > 0) onDurationChanged!(value);
          },
        ),
      ),
    ),
  );

  Widget _goals(BuildContext context, List<GoalTag> goals) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: goals
        .map(
          (goal) => ChoiceChip(
            key: ValueKey('programme_goal_${goal.name}'),
            label: Text(_goalLabel(goal), style: AppTextStyles.labelMd),
            selected: selectedGoals.contains(goal),
            showCheckmark: false,
            selectedColor: context.colorScheme.secondaryContainer,
            labelStyle: AppTextStyles.labelMd.copyWith(
              color: selectedGoals.contains(goal)
                  ? context.colorScheme.onSecondaryContainer
                  : context.colorScheme.onSurface,
            ),
            backgroundColor: context.colorScheme.surfaceContainerLowest,
            shape: const StadiumBorder(),
            onSelected: onGoalsChanged == null
                ? null
                : (selected) {
                    final updated = Set<GoalTag>.from(selectedGoals);
                    selected ? updated.add(goal) : updated.remove(goal);
                    onGoalsChanged!(updated);
                  },
          ),
        )
        .toList(),
  );

  String _goalLabel(GoalTag goal) => switch (goal) {
    GoalTag.buildMuscle => AppStrings.hypertrophyGoal,
    GoalTag.increaseStrength => AppStrings.strengthGoal,
    GoalTag.improveEndurance => AppStrings.enduranceGoal,
    GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
    GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
    GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
  };

  String _equipmentLabel(EquipmentTag equipment) => switch (equipment) {
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      AppWhiteSpace.hSm,
      child,
    ],
  );
}
