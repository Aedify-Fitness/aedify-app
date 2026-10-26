import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_schedule_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_taxonomy.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingReviewStep extends StatelessWidget {
  const OnboardingReviewStep({
    super.key,
    required this.draft,
    required this.onJumpToStep,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;
    final experience =
        OnboardingTaxonomy.experienceLabel(draft.experienceLevel) ??
        AppStrings.onboardingReviewEmptyValue;
    final focus = draft.goals.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : draft.goals.map(OnboardingTaxonomy.goalLabel).join(', ');
    final schedule = draft.trainingDays.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : AppStrings.onboardingReviewScheduleValue(
            draft.trainingDays.length,
            draft.targetSessionLengthMinutes ??
                OnboardingScheduleStep.defaultDuration.toInt(),
          );
    final equipment = draft.equipmentAccess.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : draft.equipmentAccess
              .map(OnboardingTaxonomy.equipmentLabel)
              .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingFinalReviewTitle,
          description: AppStrings.onboardingReviewDescription,
          key: const ValueKey<String>('onboarding_review_intro'),
        ),
        AppWhiteSpace.hMd,
        _OnboardingReviewExperienceCard(
          tier: AppStrings.onboardingReviewExperienceTier(experience),
          focus: focus,
          duration: AppStrings.onboardingReviewExperienceDuration(experience),
          onModify: () => onJumpToStep(OnboardingStep.experienceGoals),
        ),
        AppWhiteSpace.hLg,
        _OnboardingReviewAiStatusCard(
          configured: !draft.byokSkipped,
          onTap: () => onJumpToStep(OnboardingStep.byokOptional),
        ),
        AppWhiteSpace.hLg,
        _OnboardingReviewSummaryCard(
          cardKey: const ValueKey<String>('onboarding_review_schedule_card'),
          title: AppStrings.onboardingReviewScheduleTitle,
          iconAsset: OutlinedSvgAssets.materialCalendarMonth,
          summary: schedule,
          onAction: () => onJumpToStep(OnboardingStep.schedule),
          footer: _OnboardingReviewWeekIndicators(
            selectedDays: draft.trainingDays,
          ),
        ),
        AppWhiteSpace.hLg,
        _OnboardingReviewSummaryCard(
          cardKey: const ValueKey<String>('onboarding_review_equipment_card'),
          title: AppStrings.onboardingReviewEquipmentTitle,
          iconAsset: OutlinedSvgAssets.materialFitnessCenter,
          summary: equipment,
          onAction: () => onJumpToStep(OnboardingStep.equipment),
        ),
        AppWhiteSpace.hLg,
        _OnboardingReviewMetricCard(
          preferredUnit: preferredUnit,
          draft: draft,
          onTap: () => onJumpToStep(OnboardingStep.unitsMetrics),
        ),
      ],
    );
  }
}

class _OnboardingReviewSurface extends StatelessWidget {
  const _OnboardingReviewSurface({required this.cardKey, required this.child});

  final Key cardKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OnboardingReviewExperienceCard extends StatelessWidget {
  const _OnboardingReviewExperienceCard({
    required this.tier,
    required this.focus,
    required this.duration,
    required this.onModify,
  });

  final String tier;
  final String focus;
  final String duration;
  final VoidCallback onModify;

  @override
  Widget build(BuildContext context) {
    return _OnboardingReviewSurface(
      cardKey: const ValueKey<String>('onboarding_review_experience_card'),
      child: InkWell(
        onTap: onModify,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.materialSchool,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.onboardingReviewExperienceTitle,
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hLg,
            _OnboardingReviewFactTile(
              tileKey: const ValueKey<String>('onboarding_review_tier_tile'),
              label: AppStrings.onboardingReviewTierLabel,
              value: tier,
              onTap: onModify,
            ),
            AppWhiteSpace.hMd,
            _OnboardingReviewFactTile(
              tileKey: const ValueKey<String>('onboarding_review_focus_tile'),
              label: AppStrings.onboardingReviewFocusLabel,
              value: focus,
              onTap: onModify,
            ),
            AppWhiteSpace.hMd,
            _OnboardingReviewFactTile(
              tileKey: const ValueKey<String>(
                'onboarding_review_duration_tile',
              ),
              label: AppStrings.onboardingReviewDurationLabel,
              value: duration,
              onTap: onModify,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingReviewFactTile extends StatelessWidget {
  const _OnboardingReviewFactTile({
    required this.tileKey,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final Key tileKey;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: tileKey,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hXs,
              Text(
                value,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingReviewAiStatusCard extends StatelessWidget {
  const _OnboardingReviewAiStatusCard({
    required this.configured,
    required this.onTap,
  });

  final bool configured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      child: Container(
        key: const ValueKey<String>('onboarding_review_ai_card'),
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -AppSpacing.xxl,
                bottom: -AppSpacing.xxl,
                child: Opacity(
                  opacity: 0.1,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.materialHub,
                    width: AppSizing.reviewDecorativeIcon,
                    height: AppSizing.reviewDecorativeIcon,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      OutlinedSvgAssets.materialAutoAwesome,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      alignment: Alignment.centerLeft,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    Text(
                      AppStrings.onboardingReviewAiIntelligenceTitle,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    AppWhiteSpace.hSm,
                    Text(
                      configured
                          ? AppStrings.onboardingReviewAiConfiguredDescription
                          : AppStrings.onboardingReviewAiOptionalDescription,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    AppWhiteSpace.hXl,
                    Row(
                      children: [
                        Container(
                          width: AppSizing.reviewStatusDot,
                          height: AppSizing.reviewStatusDot,
                          decoration: BoxDecoration(
                            color: configured
                                ? context.colorScheme.secondary
                                : context.colorScheme.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppWhiteSpace.wSm,
                        Expanded(
                          child: Text(
                            configured
                                ? AppStrings.onboardingReviewAiConfiguredStatus
                                : AppStrings
                                      .onboardingReviewAiNotConfiguredStatus,
                            style: AppTextStyles.labelMd.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
                              letterSpacing:
                                  AppSizing.reviewStatusLetterSpacing,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingReviewSummaryCard extends StatelessWidget {
  const _OnboardingReviewSummaryCard({
    required this.cardKey,
    required this.title,
    required this.iconAsset,
    required this.summary,
    required this.onAction,
    this.footer,
  });

  final Key cardKey;
  final String title;
  final String iconAsset;
  final String summary;
  final VoidCallback onAction;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _OnboardingReviewSurface(
      cardKey: cardKey,
      child: InkWell(
        onTap: onAction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              alignment: Alignment.centerLeft,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hXs,
            Text(
              title,
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hSm,
            Text(
              summary,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

class _OnboardingReviewMetricCard extends StatelessWidget {
  const _OnboardingReviewMetricCard({
    required this.preferredUnit,
    required this.draft,
    required this.onTap,
  });

  final PreferredUnit preferredUnit;
  final OnboardingDraft draft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = <String>[
      preferredUnit.displayLabel,
      if (draft.heightCm != null) preferredUnit.heightLabel,
      if (draft.bodyweightKg != null) preferredUnit.weightLabel,
      if (draft.bench1RmKg != null) AppStrings.bench1Rm,
      if (draft.squat1RmKg != null) AppStrings.squat1Rm,
      if (draft.deadlift1RmKg != null) AppStrings.deadlift1Rm,
    ];

    return Semantics(
      button: true,
      container: true,
      child: Container(
        key: const ValueKey<String>('onboarding_review_metric_card'),
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.colorScheme.surfaceContainerHighest,
            width: AppSizing.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: AppSizing.reviewMetricIcon,
                    height: AppSizing.reviewMetricIcon,
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      OutlinedSvgAssets.materialMonitoring,
                      width: AppSpacing.xl,
                      height: AppSpacing.xl,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSecondaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                AppWhiteSpace.hXl,
                Text(
                  AppStrings.onboardingReviewMetricTitle,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hSm,
                Text(
                  AppStrings.onboardingReviewMetricDescription,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppWhiteSpace.hMd,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: metrics.map((metric) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.buttonVertical,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        metric,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingReviewWeekIndicators extends StatelessWidget {
  const _OnboardingReviewWeekIndicators({required this.selectedDays});

  final Iterable<TrainingDay> selectedDays;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: TrainingDay.values.map((day) {
          return Container(
            width: AppSizing.reviewDayIndicatorWidth,
            height: AppSizing.reviewDayIndicatorHeight,
            decoration: BoxDecoration(
              color: selectedDays.contains(day)
                  ? context.colorScheme.secondary
                  : context.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          );
        }).toList(),
      ),
    );
  }
}
