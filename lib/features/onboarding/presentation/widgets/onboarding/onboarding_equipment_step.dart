import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_equipment_visual_card.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/image_assets.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

class _EquipmentData {
  final String title;
  final String description;
  final String? eyebrow;
  final String imageAsset;
  final EquipmentTag equipmentTag;

  _EquipmentData({
    this.eyebrow,
    required this.title,
    required this.imageAsset,
    required this.description,
    required this.equipmentTag,
  });
}

class OnboardingEquipmentStep extends StatelessWidget {
  const OnboardingEquipmentStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  List<_EquipmentData> get _foundation => [
    _EquipmentData(
      title: AppStrings.onboardingEquipmentDumbbells,
      description: AppStrings.onboardingEquipmentDumbbellsDescription,
      eyebrow: AppStrings.onboardingEquipmentEssential,
      imageAsset: ImageAssets.onboardingDumbbells,
      equipmentTag: EquipmentTag.dumbbell,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentBarbell,
      description: AppStrings.onboardingEquipmentBarbellDescription,
      eyebrow: AppStrings.onboardingEquipmentHeavyLifts,
      imageAsset: ImageAssets.onboardingBarbell,
      equipmentTag: EquipmentTag.barbell,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentBench,
      description: AppStrings.onboardingEquipmentBenchDescription,
      eyebrow: AppStrings.onboardingEquipmentSupport,
      imageAsset: ImageAssets.onboardingBench,
      equipmentTag: EquipmentTag.bench,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentSquatRack,
      description: AppStrings.onboardingEquipmentSquatRackDescription,
      eyebrow: AppStrings.onboardingEquipmentHeavyLifts,
      imageAsset: ImageAssets.onboardingSquatRack,
      equipmentTag: EquipmentTag.squatRack,
    ),
  ];

  List<_EquipmentData> get _accessories => [
    _EquipmentData(
      title: AppStrings.onboardingEquipmentKettlebell,
      description: AppStrings.onboardingEquipmentKettlebellsDescription,
      imageAsset: ImageAssets.onboardingKettlebells,
      equipmentTag: EquipmentTag.kettlebell,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentResistanceBands,
      description: AppStrings.onboardingEquipmentBandsDescription,
      imageAsset: ImageAssets.onboardingResistanceBands,
      equipmentTag: EquipmentTag.bands,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentPullUpBar,
      description: AppStrings.onboardingEquipmentPullUpBarDescription,
      imageAsset: ImageAssets.onboardingPullUpBar,
      equipmentTag: EquipmentTag.pullUpBar,
    ),
  ];

  List<_EquipmentData> get _conditioning => [
    _EquipmentData(
      title: AppStrings.onboardingEquipmentCableMachine,
      description: AppStrings.onboardingEquipmentCableDescription,
      imageAsset: ImageAssets.onboardingCableMachine,
      equipmentTag: EquipmentTag.cable,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentSmithMachine,
      description: AppStrings.onboardingEquipmentSmithDescription,
      imageAsset: ImageAssets.onboardingSmithMachine,
      equipmentTag: EquipmentTag.smithMachine,
    ),
    _EquipmentData(
      title: AppStrings.onboardingEquipmentCardioMachine,
      description: AppStrings.onboardingEquipmentCardioDescription,
      imageAsset: ImageAssets.onboardingCardioMachine,
      equipmentTag: EquipmentTag.cardioMachine,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingGymEnvironmentTitle,
          description: AppStrings.onboardingGymEnvironmentDescription,
        ),
        const _OnboardingEquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialHome,
          title: AppStrings.onboardingEquipmentGroupNone,
        ),
        AppWhiteSpace.hLg,
        OnboardingEquipmentVisualCard(
          title: AppStrings.onboardingEquipmentBodyweightTitle,
          description: AppStrings.onboardingEquipmentBodyweightDescription,
          eyebrow: AppStrings.onboardingEquipmentBodyweightTitle,
          iconAsset: OutlinedSvgAssets.materialAccessibilityNew,
          selected: draft.equipmentAccess.contains(EquipmentTag.bodyweight),
          onTap: () => _toggleEquipment(EquipmentTag.bodyweight),
        ),
        AppWhiteSpace.hXl,
        const _OnboardingEquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialInventory2,
          title: AppStrings.onboardingEquipmentGroupFoundation,
        ),
        AppWhiteSpace.hMd,
        ListView.separated(
          shrinkWrap: true,
          itemCount: _foundation.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, i) => AppWhiteSpace.hMd,
          itemBuilder: (context, i) {
            final equipment = _foundation[i];
            return OnboardingEquipmentVisualCard(
              title: equipment.title,
              description: equipment.description,
              eyebrow: equipment.eyebrow,
              imageAsset: equipment.imageAsset,
              selected: draft.equipmentAccess.contains(equipment.equipmentTag),
              onTap: () => _toggleEquipment(equipment.equipmentTag),
            );
          },
        ),
        AppWhiteSpace.hXl,
        const _OnboardingEquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialAddCircle,
          title: AppStrings.onboardingEquipmentGroupAccessories,
        ),
        AppWhiteSpace.hMd,
        ListView.separated(
          shrinkWrap: true,
          itemCount: _accessories.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, i) => AppWhiteSpace.hMd,
          itemBuilder: (context, i) {
            final equipment = _accessories[i];
            return OnboardingEquipmentVisualCard.compact(
              title: equipment.title,
              description: equipment.description,
              imageAsset: equipment.imageAsset,
              selected: draft.equipmentAccess.contains(equipment.equipmentTag),
              onTap: () => _toggleEquipment(equipment.equipmentTag),
            );
          },
        ),
        AppWhiteSpace.hXl,
        const _OnboardingEquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialSettings,
          title: AppStrings.onboardingEquipmentGroupMachines,
        ),
        AppWhiteSpace.hMd,
        ListView.separated(
          shrinkWrap: true,
          itemCount: _conditioning.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, i) => AppWhiteSpace.hMd,
          itemBuilder: (context, i) {
            final equipment = _conditioning[i];
            return OnboardingEquipmentVisualCard.compact(
              title: equipment.title,
              description: equipment.description,
              imageAsset: equipment.imageAsset,
              selected: draft.equipmentAccess.contains(equipment.equipmentTag),
              onTap: () => _toggleEquipment(equipment.equipmentTag),
            );
          },
        ),
      ],
    );
  }

  void _toggleEquipment(EquipmentTag equipment) {
    final updated = Set<EquipmentTag>.from(draft.equipmentAccess);
    if (!updated.add(equipment)) {
      updated.remove(equipment);
    }
    onUpdateDraft(draft.copyWith(equipmentAccess: updated));
  }
}

class _OnboardingEquipmentSectionHeader extends StatelessWidget {
  const _OnboardingEquipmentSectionHeader({
    required this.iconAsset,
    required this.title,
  });

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
        ),
        AppWhiteSpace.wSm,
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
