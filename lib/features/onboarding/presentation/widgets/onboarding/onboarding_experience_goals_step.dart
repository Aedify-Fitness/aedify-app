import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_icon_badge.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_taxonomy.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

class _ExperienceLevel {
  final String icon;
  final String label;
  final String description;
  final ExperienceLevel level;

  const _ExperienceLevel({
    required this.icon,
    required this.label,
    required this.level,
    required this.description,
  });
}

class _GoalOptions {
  final String icon;
  final String label;

  const _GoalOptions({required this.icon, required this.label});
}

class OnboardingExperienceGoalsStep extends StatelessWidget {
  const OnboardingExperienceGoalsStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _experienceLevels = [
    _ExperienceLevel(
      level: ExperienceLevel.beginner,
      label: AppStrings.onboardingExperienceNovice,
      description: AppStrings.onboardingExperienceNoviceDescription,
      icon: OutlinedSvgAssets.materialChildCare,
    ),
    _ExperienceLevel(
      level: ExperienceLevel.intermediate,
      label: AppStrings.onboardingExperienceAdept,
      description: AppStrings.onboardingExperienceAdeptDescription,
      icon: OutlinedSvgAssets.materialFitnessCenter,
    ),
    _ExperienceLevel(
      level: ExperienceLevel.advanced,
      label: AppStrings.onboardingExperienceElite,
      description: AppStrings.onboardingExperienceEliteDescription,
      icon: OutlinedSvgAssets.materialMilitaryTech,
    ),
  ];

  static const _goalOptions = [
    _GoalOptions(
      label: AppStrings.onboardingGoalBuildMuscle,
      icon: OutlinedSvgAssets.materialWorkspacePremium,
    ),
    _GoalOptions(
      label: AppStrings.onboardingGoalLoseWeight,
      icon: OutlinedSvgAssets.materialQueryStats,
    ),
    _GoalOptions(
      label: AppStrings.onboardingGoalGeneralFitness,
      icon: OutlinedSvgAssets.materialAccessibilityNew,
    ),
    _GoalOptions(
      label: AppStrings.onboardingGoalFlexibility,
      icon: OutlinedSvgAssets.materialSelfImprovement,
    ),
    _GoalOptions(
      label: AppStrings.onboardingGoalIncreaseStrength,
      icon: OutlinedSvgAssets.materialFitnessCenter,
    ),
    _GoalOptions(
      label: AppStrings.onboardingGoalImproveEndurance,
      icon: OutlinedSvgAssets.materialBolt,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingExperiencePathDisplayTitle,
          description: AppStrings.onboardingExperiencePathDescription,
        ),
        Text(
          AppStrings.experienceLevel,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hMd,
        ...List.generate(_experienceLevels.length, (i) {
          final level = _experienceLevels[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: level != _experienceLevels.last ? AppSpacing.lg : 0,
            ),
            child: _OnboardingSelectionCard(
              title: level.label,
              description: level.description,
              iconAsset: level.icon,
              selected: draft.experienceLevel == level.level,
              onTap: () {
                onUpdateDraft(draft.copyWith(experienceLevel: level.level));
              },
            ),
          );
        }),
        AppWhiteSpace.hXxl,
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.onboardingGrowthPillarsTitle,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            AppWhiteSpace.wSm,
            const _OnboardingStatusBadge(
              label: AppStrings.onboardingMultiSelectEnabled,
            ),
          ],
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.onboardingGrowthPillarsVisionHelper,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hLg,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _goalOptions.map((goal) {
            final goalTag = OnboardingTaxonomy.goalFromLabel(goal.label);
            final selected = draft.goals.contains(goalTag);
            return _OnboardingSelectionPill(
              label: goal.label,
              iconAsset: goal.icon,
              selected: selected,
              onTap: () {
                final updated = !selected
                    ? {...draft.goals, goalTag}
                    : (Set<GoalTag>.from(draft.goals)..remove(goalTag));
                onUpdateDraft(draft.copyWith(goals: updated));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _OnboardingSelectionCard extends StatelessWidget {
  const _OnboardingSelectionCard({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? accent
                : context.colorScheme.surfaceContainerLowest,
            width: AppSizing.strokeWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.secondary.withValues(alpha: 0.06),
              blurRadius: AppSpacing.lg,
              offset: const Offset(0, AppSpacing.xs),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingIconBadge(
                    iconAsset: iconAsset,
                    accent: selected
                        ? context.colorScheme.secondaryContainer
                        : context.colorScheme.surfaceContainerLow,
                    iconColor: selected
                        ? context.colorScheme.onSecondaryContainer
                        : accent,
                  ),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      OutlinedSvgAssets.materialCheckCircle,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hLg,
              Text(
                title,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hSm,
              Text(
                description,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStatusBadge extends StatelessWidget {
  const _OnboardingStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accessible pill selector used for compact onboarding choices.
class _OnboardingSelectionPill extends StatelessWidget {
  const _OnboardingSelectionPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconAsset,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.onPrimary;

    final foregroundColor = selected
        ? colorScheme.secondary
        : colorScheme.onSurface;

    final iconColor = selected ? foregroundColor : colorScheme.onSurfaceVariant;

    return Semantics(
      key: ValueKey<String>('onboarding_selection_$label'),
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconAsset != null) ...[
                  SvgPicture.asset(
                    iconAsset!,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                  AppWhiteSpace.wControlGap,
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
