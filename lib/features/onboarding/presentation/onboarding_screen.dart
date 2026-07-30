import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_selection_pill.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_step_scaffold.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/image_assets.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(
      AppProviders.onboardingControllerProvider,
    );

    return onboardingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.onboardingLoadFailed,
                style: AppTextStyles.bodyMd,
              ),
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: () => ref
                    .read(AppProviders.onboardingControllerProvider.notifier)
                    .loadExistingDraft(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      data: (state) => _OnboardingStepView(state: state),
    );
  }
}

class _OnboardingStepView extends ConsumerWidget {
  const _OnboardingStepView({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.onboardingControllerProvider.notifier,
    );

    return _StepBody(
      state: state,
      onUpdateDraft: (draft) => controller.updateDraft(draft),
      onNext: () => controller.nextStep(),
      onBack: () => controller.previousStep(),
      onComplete: () => controller.completeOnboarding(),
      onJumpToStep: (step) => controller.jumpToStep(step),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.state,
    required this.onUpdateDraft,
    required this.onNext,
    required this.onBack,
    required this.onComplete,
    required this.onJumpToStep,
  });

  final OnboardingState state;
  final void Function(OnboardingDraft draft) onUpdateDraft;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final isReview = state.currentStep == OnboardingStep.review;
    final stepTitle = _titleForStep(state.currentStep);

    return OnboardingStepScaffold(
      title: stepTitle,
      description: _descriptionForStep(state.currentStep),
      header: OnboardingProgressHeader(
        currentStep: state.currentStep,
        stepTitle: _stepLabelForStep(state.currentStep),
      ),
      hero: state.currentStep == OnboardingStep.welcome
          ? const _WelcomeHero()
          : null,
      onBack: state.currentStep == OnboardingStep.welcome ? null : onBack,
      onNext: isReview ? onComplete : onNext,
      isPrimaryLoading: state.isSaving,
      primaryLabel: switch (state.currentStep) {
        OnboardingStep.welcome => AppStrings.onboardingInitializeSpace,
        OnboardingStep.experienceGoals => AppStrings.continueLabel,
        OnboardingStep.schedule => AppStrings.continueLabel,
        OnboardingStep.limitations => AppStrings.onboardingNextStep,
        OnboardingStep.unitsMetrics => AppStrings.continueLabel,
        OnboardingStep.review => AppStrings.onboardingInitializeWorkspace,
        _ => null,
      },
      secondaryLabel:
          state.currentStep == OnboardingStep.schedule ||
              state.currentStep == OnboardingStep.limitations ||
              state.currentStep == OnboardingStep.unitsMetrics
          ? AppStrings.backLabel
          : null,
      bodyFooterLabel: switch (state.currentStep) {
        OnboardingStep.welcome => AppStrings.onboardingWelcomePrivacyFooter,
        _ => null,
      },
      child: _StepContent(
        state: state,
        onUpdateDraft: onUpdateDraft,
        onJumpToStep: onJumpToStep,
      ),
    );
  }

  String _titleForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
      case OnboardingStep.coreIdentity:
      case OnboardingStep.experienceGoals:
      case OnboardingStep.schedule:
      case OnboardingStep.equipment:
      case OnboardingStep.limitations:
      case OnboardingStep.unitsMetrics:
      case OnboardingStep.byokOptional:
      case OnboardingStep.review:
        return '';
    }
  }

  String? _descriptionForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
      case OnboardingStep.coreIdentity:
      case OnboardingStep.experienceGoals:
      case OnboardingStep.schedule:
      case OnboardingStep.equipment:
      case OnboardingStep.limitations:
      case OnboardingStep.unitsMetrics:
      case OnboardingStep.byokOptional:
      case OnboardingStep.review:
        return null;
    }
  }

  String _stepLabelForStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => AppStrings.onboardingWelcomeStepName,
      OnboardingStep.coreIdentity => AppStrings.onboardingCoreIdentityTitle,
      OnboardingStep.experienceGoals =>
        AppStrings.onboardingExperiencePathTitle,
      OnboardingStep.schedule => AppStrings.onboardingRhythmTitle,
      OnboardingStep.equipment => AppStrings.onboardingGymEnvironmentTitle,
      OnboardingStep.limitations =>
        AppStrings.onboardingPrecisionConstraintsTitle,
      OnboardingStep.unitsMetrics => AppStrings.onboardingEliteBaselineTitle,
      OnboardingStep.byokOptional =>
        AppStrings.onboardingIntelligenceLayerTitle,
      OnboardingStep.review => AppStrings.onboardingFinalReviewTitle,
    };
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.state,
    required this.onUpdateDraft,
    required this.onJumpToStep,
  });

  final OnboardingState state;
  final void Function(OnboardingDraft) onUpdateDraft;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValidationMessage(state: state),
        switch (state.currentStep) {
          OnboardingStep.welcome => _WelcomeStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.coreIdentity => _CoreIdentityStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.experienceGoals => _ExperienceGoalsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.schedule => _ScheduleStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.equipment => _EquipmentStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.unitsMetrics => _UnitsMetricsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.limitations => _LimitationsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.byokOptional => _ByokOptionalStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.review => _ReviewStep(
            draft: state.draft,
            onJumpToStep: onJumpToStep,
          ),
        },
      ],
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final message = state.hasValidationMessage
        ? state.validationMessage
        : state.hasError
        ? state.errorMessage
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _SurfacePanel(
        backgroundColor: context.colorScheme.errorContainer,
        borderColor: context.colorScheme.error,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.materialWarning,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onErrorContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.maxLines,
  });

  final String initialValue;
  final void Function(String) onChanged;
  final String? hintText;
  final int? maxLines;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hintText: widget.hintText,
      maxLines: widget.maxLines ?? 1,
      onChanged: widget.onChanged,
      fillColor: context.colorScheme.surfaceContainerLowest,
      borderRadius: AppRadius.md,
      style: AppTextStyles.bodyMd,
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.headlineXl.copyWith(
              color: context.colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: AppStrings.onboardingWelcomeHeroLineOne),
              const TextSpan(text: '\n'),
              TextSpan(
                text: AppStrings.onboardingWelcomeHeroLineTwo,
                style: AppTextStyles.headlineXl.copyWith(
                  color: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingWelcomeHeroDescription,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WelcomeFeatureCard(
          iconAsset: OutlinedSvgAssets.materialSecurity,
          title: AppStrings.onboardingWelcomePrivacyTitle,
          description: AppStrings.onboardingWelcomePrivacyBulletOne,
          emphasized: true,
        ),
        AppWhiteSpace.hMd,
        IntrinsicHeight(
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WelcomeFeatureCard(
                  iconAsset: OutlinedSvgAssets.materialAutoAwesome,
                  title: AppStrings.onboardingByokBenefitOptional,
                  description: AppStrings.onboardingWelcomePrivacyBulletTwo,
                ),
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: _WelcomeFeatureCard(
                  iconAsset: OutlinedSvgAssets.materialVisibilityOff,
                  title: AppStrings.onboardingPrivateControlTitle,
                  description: AppStrings.onboardingPrivateControlDescription,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXxl,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InputLabel(title: AppStrings.onboardingDisplayNamePrompt),
            AppWhiteSpace.hSm,
            _FormField(
              initialValue: draft.displayName ?? '',
              hintText: AppStrings.onboardingDisplayNameHint,
              onChanged: (value) {
                onUpdateDraft(
                  draft.copyWith(displayName: value.isEmpty ? null : value),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeFeatureCard extends StatelessWidget {
  const _WelcomeFeatureCard({
    required this.iconAsset,
    required this.title,
    required this.description,
    this.emphasized = false,
  });

  final String iconAsset;
  final String title;
  final String description;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: emphasized
            ? context.colorScheme.surfaceContainerLow
            : context.colorScheme.surfaceContainerLowest,
        border: emphasized
            ? Border(
                left: BorderSide(color: accent, width: AppSpacing.xs),
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: emphasized
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(
                  iconAsset: iconAsset,
                  accent: context.colorScheme.surfaceContainerHighest,
                  iconColor: accent,
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: _WelcomeFeatureCopy(
                    title: title,
                    description: description,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
                AppWhiteSpace.hSm,
                _WelcomeFeatureCopy(title: title, description: description),
              ],
            ),
    );
  }
}

class _WelcomeFeatureCopy extends StatelessWidget {
  const _WelcomeFeatureCopy({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMd),
        AppWhiteSpace.hXs,
        Text(
          description,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CoreIdentityStep extends StatelessWidget {
  const _CoreIdentityStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.08),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.onboardingCoreIdentityTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineXl.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.onboardingCoreIdentityCardDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hXl,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InputLabel(
                title: AppStrings.onboardingCoreIdentitySexLabel,
              ),
              AppWhiteSpace.hMd,
              Row(
                children: [
                  Expanded(
                    child: _IdentityChoiceCard(
                      label: AppStrings.sexMale,
                      iconAsset: OutlinedSvgAssets.materialMale,
                      selected: draft.sex == Sex.male,
                      onTap: () {
                        onUpdateDraft(draft.copyWith(sex: Sex.male));
                      },
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Expanded(
                    child: _IdentityChoiceCard(
                      label: AppStrings.sexFemale,
                      iconAsset: OutlinedSvgAssets.materialFemale,
                      selected: draft.sex == Sex.female,
                      onTap: () {
                        onUpdateDraft(draft.copyWith(sex: Sex.female));
                      },
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Expanded(
                    child: _IdentityChoiceCard(
                      label: AppStrings.sexNotSpecified,
                      iconAsset: OutlinedSvgAssets.materialTransgender,
                      selected: draft.sex == Sex.notSpecified,
                      onTap: () {
                        onUpdateDraft(draft.copyWith(sex: Sex.notSpecified));
                      },
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hXl,
              const _InputLabel(title: AppStrings.onboardingMeasurementSystem),
              AppWhiteSpace.hMd,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _UnitChoiceButton(
                        label: AppStrings.onboardingMetricChoice,
                        selected: preferredUnit == PreferredUnit.metric,
                        onTap: () {
                          onUpdateDraft(
                            draft.copyWith(
                              preferredUnits: PreferredUnit.metric,
                            ),
                          );
                        },
                      ),
                    ),
                    AppWhiteSpace.wXs,
                    Expanded(
                      child: _UnitChoiceButton(
                        label: AppStrings.onboardingImperialChoice,
                        selected: preferredUnit == PreferredUnit.imperial,
                        onTap: () {
                          onUpdateDraft(
                            draft.copyWith(
                              preferredUnits: PreferredUnit.imperial,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AppWhiteSpace.hXl,
              const _InputLabel(title: AppStrings.dateOfBirth),
              AppWhiteSpace.hMd,
              Semantics(
                button: true,
                label: AppStrings.selectDate,
                child: Material(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: draft.dateOfBirth ?? now,
                        firstDate: DateTime(1925),
                        lastDate: now,
                      );
                      if (picked != null) {
                        onUpdateDraft(draft.copyWith(dateOfBirth: picked));
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppSizing.iconXxl,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.buttonVertical,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              draft.dateOfBirth != null
                                  ? '${draft.dateOfBirth!.year}-'
                                        '${draft.dateOfBirth!.month.toString().padLeft(2, '0')}-'
                                        '${draft.dateOfBirth!.day.toString().padLeft(2, '0')}'
                                  : AppStrings.dateOfBirth,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: draft.dateOfBirth != null
                                    ? context.colorScheme.onSurface
                                    : context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            OutlinedSvgAssets.materialCalendarToday,
                            width: AppSizing.iconSm,
                            height: AppSizing.iconSm,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.onboardingDateOfBirthHelper,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperienceGoalsStep extends StatelessWidget {
  const _ExperienceGoalsStep({
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _experienceLevels = [
    (
      ExperienceLevel.beginner,
      AppStrings.onboardingExperienceNovice,
      AppStrings.onboardingExperienceNoviceDescription,
      OutlinedSvgAssets.materialChildCare,
    ),
    (
      ExperienceLevel.intermediate,
      AppStrings.onboardingExperienceAdept,
      AppStrings.onboardingExperienceAdeptDescription,
      OutlinedSvgAssets.materialFitnessCenter,
    ),
    (
      ExperienceLevel.advanced,
      AppStrings.onboardingExperienceElite,
      AppStrings.onboardingExperienceEliteDescription,
      OutlinedSvgAssets.materialMilitaryTech,
    ),
  ];

  static const _goalOptions = [
    (
      AppStrings.onboardingGoalBuildMuscle,
      OutlinedSvgAssets.materialWorkspacePremium,
    ),
    (AppStrings.onboardingGoalLoseWeight, OutlinedSvgAssets.materialQueryStats),
    (
      AppStrings.onboardingGoalIncreaseStrength,
      OutlinedSvgAssets.materialFitnessCenter,
    ),
    (AppStrings.onboardingGoalImproveEndurance, OutlinedSvgAssets.materialBolt),
    (
      AppStrings.onboardingGoalGeneralFitness,
      OutlinedSvgAssets.materialAccessibilityNew,
    ),
    (
      AppStrings.onboardingGoalFlexibility,
      OutlinedSvgAssets.materialSelfImprovement,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                AppStrings.onboardingExperiencePathDisplayTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineXl.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.onboardingExperiencePathDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        Center(
          child: Text(
            AppStrings.experienceLevel,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        for (final level in _experienceLevels) ...[
          _SelectionCard(
            title: level.$2,
            description: level.$3,
            iconAsset: level.$4,
            selected: draft.experienceLevel == level.$1,
            onTap: () {
              onUpdateDraft(draft.copyWith(experienceLevel: level.$1));
            },
          ),
          if (level != _experienceLevels.last) AppWhiteSpace.hLg,
        ],
        AppWhiteSpace.hXxxl,
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
            const _StatusBadge(label: AppStrings.onboardingMultiSelectEnabled),
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
            final goalTag = _OnboardingTaxonomy.goalFromLabel(goal.$1);
            final selected = draft.goals.contains(goalTag);
            return OnboardingSelectionPill(
              label: goal.$1,
              iconAsset: goal.$2,
              selected: selected,
              growthPillarStyle: true,
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

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const double _minimumDuration = 45;
  static const double _maximumDuration = 90;
  static const double _defaultDuration = 60;
  static const int _durationDivisions = 9;

  @override
  Widget build(BuildContext context) {
    final selectedDuration =
        (draft.targetSessionLengthMinutes?.toDouble() ?? _defaultDuration)
            .clamp(_minimumDuration, _maximumDuration)
            .toDouble();
    final weeklyHours =
        draft.trainingDays.length * selectedDuration / _defaultDuration;
    final fatigueRisk = weeklyHours > 7
        ? AppStrings.onboardingFatigueHigh
        : weeklyHours > 5
        ? AppStrings.onboardingFatigueModerate
        : AppStrings.onboardingFatigueLow;
    final durationScaleStyle = AppTextStyles.labelSm.copyWith(
      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontWeight: FontWeight.w700,
      letterSpacing: AppSizing.reviewStatusLetterSpacing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                AppStrings.onboardingRhythmDisplayTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineXl.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.onboardingRhythmDisplayDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXxl,
        _SchedulePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _SectionTitle(
                      title: AppStrings.onboardingWeeklyFrequency,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialCalendarToday,
                    width: AppSizing.iconLg,
                    height: AppSizing.iconLg,
                    colorFilter: ColorFilter.mode(
                      context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hXs,
              Text(
                AppStrings.onboardingWeeklyFrequencyDescription,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hLg,
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                mainAxisExtent: AppSizing.onboardingWeekdayChoiceHeight,
                children: TrainingDay.values.map((day) {
                  final isSelected = draft.trainingDays.contains(day);
                  return _WeekdayChoice(
                    label: day.displayLabel,
                    selected: isSelected,
                    onTap: () {
                      final updated = List<TrainingDay>.from(
                        draft.trainingDays,
                      );
                      if (isSelected) {
                        updated.remove(day);
                      } else {
                        updated.add(day);
                      }
                      updated.sort(
                        (first, second) => first.index.compareTo(second.index),
                      );
                      onUpdateDraft(
                        draft.copyWith(
                          trainingDays: updated,
                          trainingDaysPerWeek: updated.length,
                          targetSessionLengthMinutes:
                              draft.targetSessionLengthMinutes ??
                              _defaultDuration.toInt(),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              AppWhiteSpace.hLg,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  border: Border(
                    left: BorderSide(
                      color: context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      width: AppSpacing.xs,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
                child: _FeatureBullet(
                  iconAsset: OutlinedSvgAssets.materialLightBulb,
                  message: AppStrings.onboardingScheduleTip,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        _SchedulePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _SectionTitle(
                      title: AppStrings.onboardingSessionDuration,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialTimer,
                    width: AppSizing.iconLg,
                    height: AppSizing.iconLg,
                    colorFilter: ColorFilter.mode(
                      context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hXs,
              Text(
                AppStrings.onboardingSessionDurationDescription,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hXl,
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.headlineMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: selectedDuration.round().toString(),
                        style: AppTextStyles.headlineXl.copyWith(
                          color: context.theme.brightness == Brightness.dark
                              ? context.colorScheme.primary
                              : context.colorScheme.secondary,
                          fontSize: AppFontSizes.displayLg,
                        ),
                      ),
                      const TextSpan(
                        text: ' ${AppStrings.onboardingReviewMinutes}',
                      ),
                    ],
                  ),
                ),
              ),
              AppWhiteSpace.hMd,
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppSpacing.sm,
                  activeTrackColor: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                  inactiveTrackColor: context.colorScheme.surfaceContainerHigh,
                  overlayColor: context.colorScheme.secondary.withValues(
                    alpha: 0.12,
                  ),
                  thumbColor: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                  thumbShape: _ScheduleSliderThumbShape(
                    ringColor: context.colorScheme.surfaceContainerLowest,
                  ),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: selectedDuration,
                  min: _minimumDuration,
                  max: _maximumDuration,
                  divisions: _durationDivisions,
                  onChanged: (value) {
                    onUpdateDraft(
                      draft.copyWith(targetSessionLengthMinutes: value.round()),
                    );
                  },
                ),
              ),
              AppWhiteSpace.hMd,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleEndurance.toUpperCase(),
                      textAlign: TextAlign.start,
                      style: durationScaleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleOptimal.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: durationScaleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleIntensity.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: durationScaleStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        _SchedulePanel(
          child: Stack(
            children: [
              Positioned(
                right: -AppSpacing.xl,
                bottom: -AppSpacing.xl,
                child: Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.materialAnalytics,
                    width: AppSizing.decorativeIcon,
                    height: AppSizing.decorativeIcon,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: AppStrings.onboardingTotalWeeklyLoad,
                  ),
                  AppWhiteSpace.hLg,
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ScheduleSummaryTile(
                            label: AppStrings.onboardingEstimatedTrainingVolume
                                .toUpperCase(),
                            value: AppStrings.onboardingScheduleHours(
                              weeklyHours,
                            ),
                            accent: true,
                          ),
                        ),
                        AppWhiteSpace.wSm,
                        Expanded(
                          child: _ScheduleSummaryTile(
                            label: AppStrings.onboardingFatigueRisk
                                .toUpperCase(),
                            value: fatigueRisk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppWhiteSpace.hXl,
                  SizedBox(
                    height: AppSizing.onboardingWeeklyLoadChartHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: TrainingDay.values.map((day) {
                        final selected = draft.trainingDays.contains(day);
                        final heightProgress =
                            (selectedDuration - _minimumDuration) /
                            (_maximumDuration - _minimumDuration);
                        final selectedBarHeight =
                            AppSizing.onboardingScheduleBarMinHeight +
                            (AppSizing.onboardingWeeklyLoadChartHeight -
                                    AppSizing.onboardingScheduleBarMinHeight) *
                                heightProgress;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.inputHorizontal,
                            ),
                            child: AnimatedContainer(
                              key: ValueKey<String>(
                                'onboarding_schedule_bar_${day.name}',
                              ),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              height: selected
                                  ? selectedBarHeight
                                  : AppSizing.onboardingScheduleBarMinHeight,
                              decoration: BoxDecoration(
                                color: selected
                                    ? context.theme.brightness ==
                                              Brightness.dark
                                          ? context.colorScheme.primary
                                          : context.colorScheme.secondary
                                    : context.colorScheme.surfaceContainer,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(
                                    AppRadius.defaultRadius,
                                  ),
                                  topRight: Radius.circular(
                                    AppRadius.defaultRadius,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.onboardingGymEnvironmentTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineXl,
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.onboardingGymEnvironmentDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxl,
        const _EquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialHome,
          title: AppStrings.onboardingEquipmentGroupNone,
        ),
        AppWhiteSpace.hLg,
        _EquipmentVisualCard(
          title: AppStrings.onboardingEquipmentBodyweightTitle,
          description: AppStrings.onboardingEquipmentBodyweightDescription,
          eyebrow: AppStrings.onboardingEquipmentBodyweightTitle,
          iconAsset: OutlinedSvgAssets.materialAccessibilityNew,
          selected: draft.equipmentAccess.contains(EquipmentTag.bodyweight),
          onTap: () => _toggleEquipment(EquipmentTag.bodyweight),
        ),
        AppWhiteSpace.hXl,
        const _EquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialInventory2,
          title: AppStrings.onboardingEquipmentGroupFoundation,
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard(
          title: AppStrings.onboardingEquipmentDumbbells,
          description: AppStrings.onboardingEquipmentDumbbellsDescription,
          eyebrow: AppStrings.onboardingEquipmentEssential,
          imageAsset: ImageAssets.onboardingDumbbells,
          selected: draft.equipmentAccess.contains(EquipmentTag.dumbbell),
          onTap: () => _toggleEquipment(EquipmentTag.dumbbell),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard(
          title: AppStrings.onboardingEquipmentBarbell,
          description: AppStrings.onboardingEquipmentBarbellDescription,
          eyebrow: AppStrings.onboardingEquipmentHeavyLifts,
          imageAsset: ImageAssets.onboardingBarbell,
          selected: draft.equipmentAccess.contains(EquipmentTag.barbell),
          onTap: () => _toggleEquipment(EquipmentTag.barbell),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard(
          title: AppStrings.onboardingEquipmentBench,
          description: AppStrings.onboardingEquipmentBenchDescription,
          eyebrow: AppStrings.onboardingEquipmentSupport,
          imageAsset: ImageAssets.onboardingBench,
          selected: draft.equipmentAccess.contains(EquipmentTag.bench),
          onTap: () => _toggleEquipment(EquipmentTag.bench),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard(
          title: AppStrings.onboardingEquipmentSquatRack,
          description: AppStrings.onboardingEquipmentSquatRackDescription,
          eyebrow: AppStrings.onboardingEquipmentHeavyLifts,
          imageAsset: ImageAssets.onboardingSquatRack,
          selected: draft.equipmentAccess.contains(EquipmentTag.squatRack),
          onTap: () => _toggleEquipment(EquipmentTag.squatRack),
        ),
        AppWhiteSpace.hXl,
        const _EquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialAddCircle,
          title: AppStrings.onboardingEquipmentGroupAccessories,
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentKettlebell,
          description: AppStrings.onboardingEquipmentKettlebellsDescription,
          imageAsset: ImageAssets.onboardingKettlebells,
          selected: draft.equipmentAccess.contains(EquipmentTag.kettlebell),
          onTap: () => _toggleEquipment(EquipmentTag.kettlebell),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentResistanceBands,
          description: AppStrings.onboardingEquipmentBandsDescription,
          imageAsset: ImageAssets.onboardingResistanceBands,
          selected: draft.equipmentAccess.contains(EquipmentTag.bands),
          onTap: () => _toggleEquipment(EquipmentTag.bands),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentPullUpBar,
          description: AppStrings.onboardingEquipmentPullUpBarDescription,
          imageAsset: ImageAssets.onboardingPullUpBar,
          selected: draft.equipmentAccess.contains(EquipmentTag.pullUpBar),
          onTap: () => _toggleEquipment(EquipmentTag.pullUpBar),
        ),
        AppWhiteSpace.hXl,
        const _EquipmentSectionHeader(
          iconAsset: OutlinedSvgAssets.materialSettings,
          title: AppStrings.onboardingEquipmentGroupMachines,
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentCableMachine,
          description: AppStrings.onboardingEquipmentCableDescription,
          imageAsset: ImageAssets.onboardingCableMachine,
          selected: draft.equipmentAccess.contains(EquipmentTag.cable),
          onTap: () => _toggleEquipment(EquipmentTag.cable),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentSmithMachine,
          description: AppStrings.onboardingEquipmentSmithDescription,
          imageAsset: ImageAssets.onboardingSmithMachine,
          selected: draft.equipmentAccess.contains(EquipmentTag.smithMachine),
          onTap: () => _toggleEquipment(EquipmentTag.smithMachine),
        ),
        AppWhiteSpace.hMd,
        _EquipmentVisualCard.compact(
          title: AppStrings.onboardingEquipmentCardioMachine,
          description: AppStrings.onboardingEquipmentCardioDescription,
          imageAsset: ImageAssets.onboardingCardioMachine,
          selected: draft.equipmentAccess.contains(EquipmentTag.cardioMachine),
          onTap: () => _toggleEquipment(EquipmentTag.cardioMachine),
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

class _OnboardingTaxonomy {
  _OnboardingTaxonomy._();

  static GoalTag goalFromLabel(String value) {
    return switch (value) {
      AppStrings.onboardingGoalBuildMuscle => GoalTag.buildMuscle,
      AppStrings.onboardingGoalLoseWeight => GoalTag.loseWeight,
      AppStrings.onboardingGoalIncreaseStrength => GoalTag.increaseStrength,
      AppStrings.onboardingGoalImproveEndurance => GoalTag.improveEndurance,
      AppStrings.onboardingGoalGeneralFitness => GoalTag.generalFitness,
      _ => GoalTag.flexibility,
    };
  }

  static String goalLabel(GoalTag value) {
    return switch (value) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  static String? experienceLabel(ExperienceLevel? value) {
    return switch (value) {
      ExperienceLevel.novice => AppStrings.onboardingExperienceBeginner,
      ExperienceLevel.beginner => AppStrings.onboardingExperienceBeginner,
      ExperienceLevel.intermediate =>
        AppStrings.onboardingExperienceIntermediate,
      ExperienceLevel.advanced => AppStrings.onboardingExperienceAdvanced,
      null => null,
    };
  }

  static String equipmentLabel(EquipmentTag value) {
    return switch (value) {
      EquipmentTag.bodyweight => AppStrings.onboardingEquipmentNone,
      EquipmentTag.dumbbell => AppStrings.onboardingEquipmentDumbbells,
      EquipmentTag.barbell => AppStrings.onboardingEquipmentBarbell,
      EquipmentTag.bench => AppStrings.onboardingEquipmentBench,
      EquipmentTag.squatRack => AppStrings.onboardingEquipmentSquatRack,
      EquipmentTag.kettlebell => AppStrings.onboardingEquipmentKettlebell,
      EquipmentTag.bands => AppStrings.onboardingEquipmentResistanceBands,
      EquipmentTag.pullUpBar => AppStrings.onboardingEquipmentPullUpBar,
      EquipmentTag.cable => AppStrings.onboardingEquipmentCableMachine,
      EquipmentTag.smithMachine => AppStrings.onboardingEquipmentSmithMachine,
      EquipmentTag.cardioMachine => AppStrings.onboardingEquipmentCardioMachine,
      EquipmentTag.machine => AppStrings.onboardingEquipmentMachine,
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

class _UnitsMetricsStep extends StatelessWidget {
  const _UnitsMetricsStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _minimumWeightKg = 40.0;
  static const _maximumWeightKg = 180.0;
  static const _defaultWeightKg = 78.5;
  static const _metricWeightStep = 0.5;
  static const _imperialWeightStep = 1.0;
  static const _minimumHeightCm = 100.0;
  static const _maximumHeightCm = 230.0;
  static const _defaultHeightCm = 182.0;
  static const _heightStep = 1.0;

  static String _formatDisplayValue(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;
    final heightValue = draft.heightCm == null
        ? ''
        : _formatDisplayValue(preferredUnit.toDisplayHeight(draft.heightCm!));
    final weightValue = draft.bodyweightKg == null
        ? ''
        : _formatDisplayValue(
            preferredUnit.toDisplayWeight(draft.bodyweightKg!),
          );

    return Column(
      children: [
        Text(
          AppStrings.onboardingEliteBaselineEyebrow.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: context.theme.brightness == Brightness.dark
                ? context.colorScheme.primary
                : context.colorScheme.secondary,
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.onboardingEliteBaselineTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineXl,
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingEliteBaselineDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxl,
        _BaselineMetricCard(
          key: const ValueKey<String>('onboarding_baseline_weight_card'),
          title: AppStrings.weight,
          selectedUnit: preferredUnit,
          metricUnitLabel: AppStrings.metricWeightUnit,
          imperialUnitLabel: AppStrings.imperialWeightUnit,
          value: weightValue,
          numericValue: draft.bodyweightKg == null
              ? null
              : preferredUnit.toDisplayWeight(draft.bodyweightKg!),
          minimumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_minimumWeightKg).roundToDouble()
              : _minimumWeightKg,
          maximumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_maximumWeightKg).roundToDouble()
              : _maximumWeightKg,
          defaultValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_defaultWeightKg).roundToDouble()
              : _defaultWeightKg,
          step: preferredUnit.isImperial
              ? _imperialWeightStep
              : _metricWeightStep,
          hintText: preferredUnit.weightHint,
          displayUnit: preferredUnit.weightUnit,
          onSelectUnit: (unit) {
            onUpdateDraft(draft.copyWith(preferredUnits: unit));
          },
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed == null) {
              onUpdateDraft(draft.copyWith(clearBodyweightKg: true));
              return;
            }
            onUpdateDraft(
              draft.copyWith(
                bodyweightKg: preferredUnit.toCanonicalWeight(parsed),
              ),
            );
          },
        ),
        AppWhiteSpace.hLg,
        _BaselineMetricCard(
          key: const ValueKey<String>('onboarding_baseline_height_card'),
          title: AppStrings.height,
          selectedUnit: preferredUnit,
          metricUnitLabel: AppStrings.metricHeightUnit,
          imperialUnitLabel: AppStrings.imperialHeightUnit,
          value: heightValue,
          numericValue: draft.heightCm == null
              ? null
              : preferredUnit.toDisplayHeight(draft.heightCm!),
          minimumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_minimumHeightCm).roundToDouble()
              : _minimumHeightCm,
          maximumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_maximumHeightCm).roundToDouble()
              : _maximumHeightCm,
          defaultValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_defaultHeightCm).roundToDouble()
              : _defaultHeightCm,
          step: _heightStep,
          hintText: preferredUnit.heightHint,
          displayUnit: preferredUnit.heightUnit,
          onSelectUnit: (unit) {
            onUpdateDraft(draft.copyWith(preferredUnits: unit));
          },
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed == null) {
              onUpdateDraft(draft.copyWith(clearHeightCm: true));
              return;
            }
            onUpdateDraft(
              draft.copyWith(heightCm: preferredUnit.toCanonicalHeight(parsed)),
            );
          },
        ),
        AppWhiteSpace.hXl,
        AppWhiteSpace.hSm,
        _BaselineMaxLiftsSurface(
          key: const ValueKey<String>('onboarding_baseline_max_lifts_card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.onboardingMaxLiftsTitle,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                AppStrings.onboardingMaxLiftsHelper,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hMd,
              const _BaselineAccuracyBadge(),
              AppWhiteSpace.hXl,
              _BaselineLiftField(
                key: ValueKey('bench1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_bench_press_1rm_input',
                ),
                label: AppStrings.onboardingBenchPressLabel,
                initialValue: draft.bench1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.bench1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        bench1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearBench1RmKg: true));
                  }
                },
              ),
              AppWhiteSpace.hLg,
              _BaselineLiftField(
                key: ValueKey('squat1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_back_squat_1rm_input',
                ),
                label: AppStrings.onboardingBackSquatLabel,
                initialValue: draft.squat1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.squat1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        squat1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearSquat1RmKg: true));
                  }
                },
              ),
              AppWhiteSpace.hLg,
              _BaselineLiftField(
                key: ValueKey('deadlift1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_deadlift_1rm_input',
                ),
                label: AppStrings.onboardingDeadliftLabel,
                initialValue: draft.deadlift1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.deadlift1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        deadlift1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearDeadlift1RmKg: true));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BaselineMetricCard extends StatefulWidget {
  const _BaselineMetricCard({
    super.key,
    required this.title,
    required this.selectedUnit,
    required this.metricUnitLabel,
    required this.imperialUnitLabel,
    required this.value,
    required this.numericValue,
    required this.minimumValue,
    required this.maximumValue,
    required this.defaultValue,
    required this.step,
    required this.hintText,
    required this.displayUnit,
    required this.onSelectUnit,
    required this.onChanged,
  });

  final String title;
  final PreferredUnit selectedUnit;
  final String metricUnitLabel;
  final String imperialUnitLabel;
  final String value;
  final double? numericValue;
  final double minimumValue;
  final double maximumValue;
  final double defaultValue;
  final double step;
  final String hintText;
  final String displayUnit;
  final void Function(PreferredUnit unit) onSelectUnit;
  final void Function(String value) onChanged;

  @override
  State<_BaselineMetricCard> createState() => _BaselineMetricCardState();
}

class _BaselineMetricCardState extends State<_BaselineMetricCard> {
  final _valueFieldKey = GlobalKey<_MetricValueFieldState>();

  @override
  void didUpdateWidget(_BaselineMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUnit != widget.selectedUnit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _valueFieldKey.currentState?.setValue(widget.value);
      });
    }
  }

  String _formatRulerValue(double value) {
    return widget.step < 1
        ? value.toStringAsFixed(1)
        : value.round().toString();
  }

  void _handleRulerChanged(double value) {
    final formatted = _formatRulerValue(value);
    _valueFieldKey.currentState?.setValue(formatted);
    widget.onChanged(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final rulerKeyPrefix = 'onboarding_${widget.title.toLowerCase()}_ruler';

    return _ConstraintSurface(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              AppWhiteSpace.wMd,
              _BaselineUnitToggle(
                selectedUnit: widget.selectedUnit,
                metricLabel: widget.metricUnitLabel,
                imperialLabel: widget.imperialUnitLabel,
                onSelect: widget.onSelectUnit,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          _MetricValueField(
            key: _valueFieldKey,
            initialValue: widget.value,
            hintText: widget.hintText,
            suffixText: widget.displayUnit,
            onChanged: widget.onChanged,
          ),
          AppWhiteSpace.hMd,
          _MetricRuler(
            key: ValueKey<String>(rulerKeyPrefix),
            keyPrefix: rulerKeyPrefix,
            label: AppStrings.onboardingMetricRulerLabel(widget.title),
            value: widget.numericValue,
            defaultValue: widget.defaultValue,
            minimumValue: widget.minimumValue,
            maximumValue: widget.maximumValue,
            step: widget.step,
            onChanged: _handleRulerChanged,
          ),
        ],
      ),
    );
  }
}

class _MetricValueField extends StatefulWidget {
  const _MetricValueField({
    super.key,
    required this.initialValue,
    required this.hintText,
    required this.suffixText,
    required this.onChanged,
  });

  final String initialValue;
  final String hintText;
  final String suffixText;
  final void Function(String value) onChanged;

  @override
  State<_MetricValueField> createState() => _MetricValueFieldState();
}

class _MetricValueFieldState extends State<_MetricValueField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setValue(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return SizedBox(
      width: AppSizing.onboardingMetricValueWidth,
      child: AppTextField(
        controller: _controller,
        hintText: widget.hintText,
        suffixText: widget.suffixText,
        suffixStyle: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onChanged,
        filled: false,
        borderOverride: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        style: AppTextStyles.headlineXl.copyWith(color: accent),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BaselineUnitToggle extends StatelessWidget {
  const _BaselineUnitToggle({
    required this.selectedUnit,
    required this.metricLabel,
    required this.imperialLabel,
    required this.onSelect,
  });

  final PreferredUnit selectedUnit;
  final String metricLabel;
  final String imperialLabel;
  final void Function(PreferredUnit unit) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BaselineUnitButton(
            label: metricLabel,
            selected: selectedUnit == PreferredUnit.metric,
            onTap: () => onSelect(PreferredUnit.metric),
          ),
          _BaselineUnitButton(
            label: imperialLabel,
            selected: selectedUnit == PreferredUnit.imperial,
            onTap: () => onSelect(PreferredUnit.imperial),
          ),
        ],
      ),
    );
  }
}

class _BaselineUnitButton extends StatelessWidget {
  const _BaselineUnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? context.theme.brightness == Brightness.dark
              ? context.colorScheme.primary
              : context.colorScheme.secondary
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? context.colorScheme.surfaceContainerLowest
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.controlGap,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRuler extends StatefulWidget {
  const _MetricRuler({
    super.key,
    required this.keyPrefix,
    required this.label,
    required this.value,
    required this.defaultValue,
    required this.minimumValue,
    required this.maximumValue,
    required this.step,
    required this.onChanged,
  });

  static const _tickCount = 41;
  static const _settleDuration = Duration(milliseconds: 240);
  static const _velocityProjectionSeconds = 0.18;
  static const _maximumProjectedSteps = 8.0;
  static const _positionEpsilon = 0.001;

  final String keyPrefix;
  final String label;
  final double? value;
  final double defaultValue;
  final double minimumValue;
  final double maximumValue;
  final double step;
  final void Function(double value) onChanged;

  @override
  State<_MetricRuler> createState() => _MetricRulerState();
}

class _MetricRulerState extends State<_MetricRuler>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;
  late double _positionInSteps;
  double? _localValue;
  late int _lastEmittedStep;
  bool _isDragging = false;
  bool _disableAnimations = false;

  double get _effectiveValue =>
      (_localValue ?? widget.value ?? widget.defaultValue)
          .clamp(widget.minimumValue, widget.maximumValue)
          .toDouble();

  int get _maximumStep =>
      ((widget.maximumValue - widget.minimumValue) / widget.step).floor();

  @override
  void initState() {
    super.initState();
    _positionInSteps = _positionForValue(_effectiveValue);
    _lastEmittedStep = _stepForPosition(_positionInSteps);
    _settleController = AnimationController(
      vsync: this,
      duration: _MetricRuler._settleDuration,
    )..addListener(_handleSettleTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  @override
  void didUpdateWidget(_MetricRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scaleChanged =
        oldWidget.minimumValue != widget.minimumValue ||
        oldWidget.maximumValue != widget.maximumValue ||
        oldWidget.step != widget.step;
    final valueChanged =
        oldWidget.value != widget.value ||
        oldWidget.defaultValue != widget.defaultValue;
    if (!scaleChanged && !valueChanged) return;

    _localValue = widget.value;
    final nextPosition = _positionForValue(_effectiveValue);
    final nextStep = _stepForPosition(nextPosition);
    final reflectsRulerChange =
        !scaleChanged &&
        (_isDragging || _settleController.isAnimating) &&
        nextStep == _lastEmittedStep;

    if (!reflectsRulerChange) {
      _settleController.stop();
      _settleAnimation = null;
      _isDragging = false;
      _positionInSteps = nextPosition;
      _lastEmittedStep = nextStep;
    }
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  double _positionForValue(double value) {
    return ((value - widget.minimumValue) / widget.step)
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
  }

  int _stepForPosition(double position) {
    return position.round().clamp(0, _maximumStep).toInt();
  }

  double _valueForStep(int step) {
    return (widget.minimumValue + (step * widget.step))
        .clamp(widget.minimumValue, widget.maximumValue)
        .toDouble();
  }

  void _applyPosition(double position, {required bool notify}) {
    final nextPosition = position
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
    final nextStep = _stepForPosition(nextPosition);

    setState(() {
      _positionInSteps = nextPosition;
    });

    if (!notify || nextStep == _lastEmittedStep) return;

    _lastEmittedStep = nextStep;
    final nextValue = _valueForStep(nextStep);
    _localValue = nextValue;
    widget.onChanged(nextValue);
  }

  void _handleSettleTick() {
    final animation = _settleAnimation;
    if (animation == null) return;
    _applyPosition(animation.value, notify: true);
  }

  void _animateToPosition(double target) {
    final snappedTarget = target
        .roundToDouble()
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
    _settleController.stop();

    if (_disableAnimations ||
        (snappedTarget - _positionInSteps).abs() <
            _MetricRuler._positionEpsilon) {
      _settleAnimation = null;
      _applyPosition(snappedTarget, notify: true);
      return;
    }

    _settleAnimation =
        Tween<double>(begin: _positionInSteps, end: snappedTarget).animate(
          CurvedAnimation(
            parent: _settleController,
            curve: Curves.easeOutCubic,
          ),
        );
    _settleController.forward(from: 0);
  }

  void _handleDragStart(DragStartDetails details) {
    _settleController.stop();
    _settleAnimation = null;
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _applyPosition(
      _positionInSteps - (details.delta.dx / AppSpacing.controlGap),
      notify: true,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final projectedSteps =
        (-(velocity / AppSpacing.controlGap) *
                _MetricRuler._velocityProjectionSeconds)
            .clamp(
              -_MetricRuler._maximumProjectedSteps,
              _MetricRuler._maximumProjectedSteps,
            )
            .toDouble();
    _animateToPosition(_positionInSteps + projectedSteps);
  }

  void _handleDragCancel() {
    _isDragging = false;
    _animateToPosition(_positionInSteps);
  }

  void _handleTap(TapUpDetails details, double width) {
    final tappedStepOffset =
        (details.localPosition.dx - (width / 2)) / AppSpacing.controlGap;
    _animateToPosition(_positionInSteps + tappedStepOffset);
  }

  void _increase() {
    _animateToPosition((_lastEmittedStep + 1).toDouble());
  }

  void _decrease() {
    _animateToPosition((_lastEmittedStep - 1).toDouble());
  }

  String _semanticValue(double value) {
    return widget.step < 1
        ? value.toStringAsFixed(1)
        : value.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final value = _effectiveValue;
    final centerTick = _positionInSteps.floor();
    final fractionalPosition = _positionInSteps - centerTick;
    final firstTick = centerTick - (_MetricRuler._tickCount ~/ 2);
    final tickStripWidth = _MetricRuler._tickCount * AppSpacing.controlGap;

    return Semantics(
      slider: true,
      label: widget.label,
      value: _semanticValue(value),
      increasedValue: _semanticValue(
        (value + widget.step)
            .clamp(widget.minimumValue, widget.maximumValue)
            .toDouble(),
      ),
      decreasedValue: _semanticValue(
        (value - widget.step)
            .clamp(widget.minimumValue, widget.maximumValue)
            .toDouble(),
      ),
      onIncrease: _increase,
      onDecrease: _decrease,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            onHorizontalDragCancel: _handleDragCancel,
            onTapUp: (details) => _handleTap(details, constraints.maxWidth),
            child: SizedBox(
              height: AppSizing.onboardingMetricRulerHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minWidth: tickStripWidth,
                        maxWidth: tickStripWidth,
                        minHeight: AppSizing.onboardingMetricRulerHeight,
                        maxHeight: AppSizing.onboardingMetricRulerHeight,
                        child: Transform.translate(
                          key: ValueKey<String>(
                            '${widget.keyPrefix}_tick_strip',
                          ),
                          offset: Offset(
                            -fractionalPosition * AppSpacing.controlGap,
                            0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List<Widget>.generate(
                              _MetricRuler._tickCount,
                              (index) {
                                final tick = firstTick + index;
                                final isInRange =
                                    tick >= 0 && tick <= _maximumStep;
                                final major = tick % 5 == 0;

                                return SizedBox(
                                  width: AppSpacing.controlGap,
                                  child: isInRange
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            key: ValueKey<String>(
                                              '${widget.keyPrefix}_tick_$tick',
                                            ),
                                            width: major
                                                ? AppSizing.strokeWidth
                                                : AppSizing.divider,
                                            height: major
                                                ? AppSizing
                                                      .onboardingMetricRulerMajorTick
                                                : AppSizing
                                                      .onboardingMetricRulerMinorTick,
                                            color: major
                                                ? context.colorScheme.outline
                                                : context
                                                      .colorScheme
                                                      .outlineVariant,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: AppSizing.strokeWidth,
                      height: AppSizing.onboardingMetricRulerHeight,
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.dark
                            ? context.colorScheme.primary
                            : context.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BaselineMaxLiftsSurface extends StatelessWidget {
  const _BaselineMaxLiftsSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return DecoratedBox(
      key: const ValueKey<String>('onboarding_max_lifts_glass_surface'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: AppSizing.onboardingGlassCardShadowBlur,
            spreadRadius: AppSizing.onboardingGlassCardShadowSpread,
            offset: const Offset(0, AppSizing.onboardingGlassCardShadowOffset),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.controlGap,
            sigmaY: AppSpacing.controlGap,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest.withValues(
                alpha: 0.7,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color:
                    (isDark
                            ? context.colorScheme.outlineVariant
                            : context.colorScheme.surfaceContainerLowest)
                        .withValues(alpha: 0.4),
                width: AppSizing.divider,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BaselineAccuracyBadge extends StatelessWidget {
  const _BaselineAccuracyBadge();

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final badgeColor = context.colorScheme.surfaceContainerHighest;

    return Container(
      key: const ValueKey<String>('onboarding_max_lifts_accuracy_badge'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: AppSizing.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.materialInfoFilled,
            width: AppSizing.iconS,
            height: AppSizing.iconS,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          AppWhiteSpace.wSm,
          Flexible(
            child: Text(
              AppStrings.onboardingImprovesAccuracy,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BaselineLiftField extends StatefulWidget {
  const _BaselineLiftField({
    super.key,
    required this.surfaceKey,
    required this.label,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
  });

  final Key surfaceKey;
  final String label;
  final String initialValue;
  final String unit;
  final void Function(String value) onChanged;

  @override
  State<_BaselineLiftField> createState() => _BaselineLiftFieldState();
}

class _BaselineLiftFieldState extends State<_BaselineLiftField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: AppTextStyles.labelMd.copyWith(
            color: _hasFocus ? accent : context.colorScheme.onSurface,
          ),
          child: Text(widget.label),
        ),
        AppWhiteSpace.hControlGap,
        Semantics(
          textField: true,
          label: widget.label,
          child: AnimatedContainer(
            key: widget.surfaceKey,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: AppSizing.onboardingMaxLiftFieldHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _hasFocus
                  ? context.colorScheme.surfaceContainerLowest
                  : context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: _hasFocus
                  ? Border.all(color: accent, width: AppSizing.strokeWidth)
                  : null,
            ),
            child: AppTextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              hintText: AppStrings.onboardingMetricZeroHint,
              suffixText: widget.unit,
              suffixStyle: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              filled: false,
              isDense: true,
              borderOverride: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.buttonVertical,
              ),
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _LimitationsStep extends StatelessWidget {
  const _LimitationsStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _limitationOptions = [
    (
      AppStrings.onboardingLimitationNone,
      OutlinedSvgAssets.materialDoNotDisturbOn,
    ),
    (
      AppStrings.onboardingLimitationLowerBack,
      OutlinedSvgAssets.materialPersonalInjury,
    ),
    (
      AppStrings.onboardingLimitationKnee,
      OutlinedSvgAssets.materialDirectionsWalk,
    ),
    (
      AppStrings.onboardingLimitationShoulder,
      OutlinedSvgAssets.materialExercise,
    ),
    (AppStrings.onboardingLimitationWrist, OutlinedSvgAssets.materialBackHand),
    (
      AppStrings.onboardingLimitationHip,
      OutlinedSvgAssets.materialSettingsAccessibility,
    ),
    (
      AppStrings.onboardingLimitationNeck,
      OutlinedSvgAssets.materialAccessibilityNew,
    ),
    (AppStrings.onboardingLimitationElbow, OutlinedSvgAssets.materialExercise),
    (AppStrings.onboardingLimitationAnkle, OutlinedSvgAssets.materialSteps),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Column(
      children: [
        Text(
          AppStrings.onboardingPrecisionConstraintsTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineXl,
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.onboardingPrecisionConstraintsDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxl,
        Container(
          key: const ValueKey<String>('onboarding_safety_first_section'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.materialVerifiedUser,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.onboardingSafetyFirst,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.onboardingSafetyFirstDescription,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hLg,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialEncrypted,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                  AppWhiteSpace.wSm,
                  Expanded(
                    child: Text(
                      AppStrings.onboardingSensitiveDataLocal,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        _ConstraintSurface(
          key: const ValueKey<String>('onboarding_injury_flags_section'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.onboardingInjuryFlagsTitle.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                ),
              ),
              AppWhiteSpace.hLg,
              Text(
                AppStrings.onboardingInjuryFlagsDescription,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hXl,
              GridView.builder(
                itemCount: _limitationOptions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: AppSizing.onboardingLimitationTileHeight,
                ),
                itemBuilder: (context, index) {
                  final limitation = _limitationOptions[index];
                  final selected = draft.limitations.contains(limitation.$1);
                  return _LimitationOptionCard(
                    label: limitation.$1,
                    iconAsset: limitation.$2,
                    selected: selected,
                    onTap: () {
                      final updated = !selected
                          ? [...draft.limitations, limitation.$1]
                          : draft.limitations
                                .where((item) => item != limitation.$1)
                                .toList();
                      onUpdateDraft(draft.copyWith(limitations: updated));
                    },
                  );
                },
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        Consumer(
          builder: (context, ref, child) {
            return _ExercisePanel(
              key: const ValueKey<String>(
                'onboarding_favorite_exercises_section',
              ),
              title: AppStrings.favoriteExercises.toUpperCase(),
              iconAsset: OutlinedSvgAssets.materialFavorite,
              actionIconAsset: OutlinedSvgAssets.materialAdd,
              placeholder: AppStrings.onboardingFavoriteExercisesPlaceholder,
              selectedIds: draft.favoriteExerciseIds,
              onRemove: (id) {
                onUpdateDraft(
                  draft.copyWith(
                    favoriteExerciseIds: draft.favoriteExerciseIds
                        .where((exerciseId) => exerciseId != id)
                        .toList(),
                  ),
                );
              },
              onTap: () => _OnboardingExerciseMultiSelect.show(
                context: context,
                ref: ref,
                currentIds: draft.favoriteExerciseIds,
                onDone: (ids) {
                  onUpdateDraft(draft.copyWith(favoriteExerciseIds: ids));
                },
              ),
            );
          },
        ),
        AppWhiteSpace.hXl,
        Consumer(
          builder: (context, ref, child) {
            return _ExercisePanel(
              key: const ValueKey<String>('onboarding_avoid_exercises_section'),
              title: AppStrings.onboardingAvoidListTitle.toUpperCase(),
              iconAsset: OutlinedSvgAssets.materialWarning,
              actionIconAsset: OutlinedSvgAssets.materialBlock,
              placeholder: AppStrings.onboardingAvoidExercisesPlaceholder,
              isWarning: true,
              selectedIds: draft.substitutedExerciseIds,
              onRemove: (id) {
                onUpdateDraft(
                  draft.copyWith(
                    substitutedExerciseIds: draft.substitutedExerciseIds
                        .where((exerciseId) => exerciseId != id)
                        .toList(),
                  ),
                );
              },
              onTap: () => _OnboardingExerciseMultiSelect.show(
                context: context,
                ref: ref,
                currentIds: draft.substitutedExerciseIds,
                onDone: (ids) {
                  onUpdateDraft(draft.copyWith(substitutedExerciseIds: ids));
                },
              ),
            );
          },
        ),
        AppWhiteSpace.hXl,
        _ConstraintSurface(
          key: const ValueKey<String>('onboarding_other_notes_section'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialEditNote,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wControlGap,
                  Expanded(
                    child: Text(
                      AppStrings.onboardingOtherNotesTitle.toUpperCase(),
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hMd,
              _FormField(
                initialValue: draft.notes ?? '',
                maxLines: 4,
                hintText: AppStrings.onboardingOtherNotesPlaceholder,
                onChanged: (value) {
                  onUpdateDraft(
                    draft.copyWith(notes: value.isEmpty ? null : value),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConstraintSurface extends StatelessWidget {
  const _ConstraintSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: child,
    );
  }
}

class _LimitationOptionCard extends StatelessWidget {
  const _LimitationOptionCard({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBackground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryContainer;
    final selectedForeground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryContainer;
    final foreground = selected
        ? selectedForeground
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? selectedBackground
                : context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    width: AppSizing.iconLg,
                    height: AppSizing.iconLg,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                  AppWhiteSpace.hControlGap,
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(color: foreground),
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

// ---- BYOK Form State (file-private, auto-dispose) ----

class _ByokFormState {
  const _ByokFormState({
    this.selectedProvider,
    this.selectedModel,
    this.validationMessage,
    this.isSaving = false,
    this.hasSaved = false,
  });

  final AiProviderName? selectedProvider;
  final String? selectedModel;
  final String? validationMessage;
  final bool isSaving;
  final bool hasSaved;

  _ByokFormState copyWith({
    AiProviderName? selectedProvider,
    String? selectedModel,
    String? validationMessage,
    bool? isSaving,
    bool? hasSaved,
    bool clearProvider = false,
    bool clearModel = false,
    bool clearValidationMessage = false,
  }) {
    return _ByokFormState(
      selectedProvider: clearProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      selectedModel: clearModel ? null : (selectedModel ?? this.selectedModel),
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
    );
  }
}

class _ByokFormNotifier extends Notifier<_ByokFormState> {
  @override
  _ByokFormState build() => const _ByokFormState();

  void selectProvider(
    AiProviderName providerName,
    List<ByokProviderOption> options,
  ) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    state = state.copyWith(
      selectedProvider: providerName,
      selectedModel: _cheapestModelId(option),
      clearModel: option.models.isEmpty,
      clearValidationMessage: true,
    );
  }

  void selectModel(String? modelId) {
    state = state.copyWith(
      selectedModel: modelId,
      clearValidationMessage: true,
    );
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving, clearValidationMessage: saving);
  }

  void setFailure(String message) {
    state = state.copyWith(isSaving: false, validationMessage: message);
  }

  void clearValidationMessage() {
    if (state.validationMessage == null) return;
    state = state.copyWith(clearValidationMessage: true);
  }

  void markSaved() {
    state = state.copyWith(
      hasSaved: true,
      isSaving: false,
      clearValidationMessage: true,
    );
  }

  String? _cheapestModelId(ByokProviderOption option) {
    if (option.models.isEmpty) return null;
    var cheapest = option.models.first;
    for (final model in option.models.skip(1)) {
      if (model.totalCostPer1kTokens < cheapest.totalCostPer1kTokens) {
        cheapest = model;
      }
    }
    return cheapest.id;
  }
}

class _OnboardingProviders {
  _OnboardingProviders._();

  static final byokOptionsProvider =
      FutureProvider.autoDispose<List<ByokProviderOption>>((ref) {
        return ref
            .read(AppProviders.byokRepositoryProvider)
            .getProviderOptions();
      });

  static final byokFormProvider =
      NotifierProvider.autoDispose<_ByokFormNotifier, _ByokFormState>(
        _ByokFormNotifier.new,
      );
}

// ---- BYOK Optional Step ----

class _ByokOptionalStep extends ConsumerStatefulWidget {
  const _ByokOptionalStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  _ByokOptionalStepState createState() => _ByokOptionalStepState();
}

class _ByokOptionalStepState extends ConsumerState<_ByokOptionalStep> {
  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(_OnboardingProviders.byokOptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ByokIntro(),
        AppWhiteSpace.hXl,
        optionsAsync.when(
          loading: () => const _ByokSetupSurface(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => _ByokSetupSurface(
            child: Text(
              AppErrorStrings.byokLoadFailedMessage,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          data: (options) {
            if (options.isEmpty) {
              return _ByokSetupSurface(
                child: Text(
                  AppErrorStrings.byokLoadFailedMessage,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return _ByokForm(
              options: options,
              draft: widget.draft,
              onUpdateDraft: widget.onUpdateDraft,
            );
          },
        ),
      ],
    );
  }
}

class _ByokIntro extends StatelessWidget {
  const _ByokIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('onboarding_byok_intro'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.controlGap,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            AppStrings.configLabel.toUpperCase(),
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.secondary,
              letterSpacing: AppSizing.onboardingEyebrowLetterSpacing,
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingIntelligenceLayerTitle,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.primaryContainer,
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingIntelligenceLayerDescription,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxl,
        const _ByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_private'),
          iconAsset: OutlinedSvgAssets.materialVerifiedUser,
          title: AppStrings.onboardingByokBenefitPrivate,
          description: AppStrings.onboardingByokBenefitPrivateDescription,
          emphasized: true,
        ),
        AppWhiteSpace.hMd,
        const _ByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_byok'),
          iconAsset: OutlinedSvgAssets.materialKey,
          title: AppStrings.onboardingByokBenefitBringYourOwnKey,
          description:
              AppStrings.onboardingByokBenefitBringYourOwnKeyDescription,
        ),
        AppWhiteSpace.hMd,
        const _ByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_optional'),
          iconAsset: OutlinedSvgAssets.materialToggleOff,
          title: AppStrings.onboardingByokBenefitOptional,
          description: AppStrings.onboardingByokBenefitOptionalDescription,
        ),
      ],
    );
  }
}

class _ByokBenefitRow extends StatelessWidget {
  const _ByokBenefitRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    this.emphasized = false,
  });

  final String iconAsset;
  final String title;
  final String description;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Container(
            width: AppSizing.onboardingByokBenefitIcon,
            height: AppSizing.onboardingByokBenefitIcon,
            decoration: BoxDecoration(
              color: emphasized
                  ? context.colorScheme.secondaryFixed
                  : context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              iconAsset,
              width: AppSizing.iconS,
              height: AppSizing.iconS,
              colorFilter: ColorFilter.mode(
                emphasized
                    ? context.colorScheme.onSecondaryFixedVariant
                    : context.colorScheme.onPrimaryFixedVariant,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hXs,
              Text(
                description,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ByokSetupSurface extends StatelessWidget {
  const _ByokSetupSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          width: AppSizing.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }
}

class _ByokForm extends ConsumerStatefulWidget {
  const _ByokForm({
    required this.options,
    required this.draft,
    required this.onUpdateDraft,
  });

  final List<ByokProviderOption> options;
  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  ConsumerState<_ByokForm> createState() => _ByokFormWidgetState();
}

class _ByokFormWidgetState extends ConsumerState<_ByokForm> {
  final _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final formState = ref.read(_OnboardingProviders.byokFormProvider);
      if (formState.selectedProvider != null || widget.options.isEmpty) return;
      final openAiIndex = widget.options.indexWhere(
        (option) => option.providerName == AiProviderName.openai,
      );
      final initialOption = openAiIndex == -1
          ? widget.options.first
          : widget.options[openAiIndex];
      ref
          .read(_OnboardingProviders.byokFormProvider.notifier)
          .selectProvider(initialOption.providerName, widget.options);
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final formState = ref.read(_OnboardingProviders.byokFormProvider);
    final provider = formState.selectedProvider;
    final apiKey = _keyController.text.trim();
    if (provider == null || apiKey.isEmpty) return;

    final notifier = ref.read(_OnboardingProviders.byokFormProvider.notifier);
    notifier.setSaving(true);

    final repository = ref.read(AppProviders.byokRepositoryProvider);
    try {
      final isValid = await repository.validateKey(
        providerName: provider,
        apiKey: apiKey,
      );
      if (!mounted) return;
      if (!isValid) {
        notifier.setFailure(AppErrorStrings.byokKeyValidationFailed);
        return;
      }
    } catch (_) {
      if (!mounted) return;
      notifier.setFailure(AppErrorStrings.byokValidationNetworkError);
      return;
    }

    try {
      await repository.saveConfig(
        ByokEditDraft(
          providerName: provider,
          selectedModel: formState.selectedModel,
          apiKey: apiKey,
          makeActive: true,
        ),
      );
      if (!mounted) return;
      widget.onUpdateDraft(widget.draft.copyWith(byokSkipped: false));
      _keyController.clear();
      notifier.markSaved();
    } catch (_) {
      if (!mounted) return;
      notifier.setFailure(AppErrorStrings.byokSaveFailedMessage);
    }
  }

  String _apiKeyLabelFor(AiProviderName? provider) {
    return switch (provider) {
      AiProviderName.openai => AppStrings.onboardingOpenAiApiKeyLabel,
      AiProviderName.anthropic => AppStrings.onboardingAnthropicApiKeyLabel,
      AiProviderName.google => AppStrings.onboardingGoogleApiKeyLabel,
      AiProviderName.otherSupported || null => AppStrings.apiKey,
    };
  }

  String _apiKeyHintFor(AiProviderName? provider) {
    return switch (provider) {
      AiProviderName.anthropic => AppStrings.onboardingAnthropicApiKeyHint,
      AiProviderName.google => AppStrings.onboardingGoogleApiKeyHint,
      AiProviderName.openai ||
      AiProviderName.otherSupported ||
      null => AppStrings.apiKeyHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_OnboardingProviders.byokFormProvider);
    final isDark = context.theme.brightness == Brightness.dark;
    final savedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryFixed;
    final savedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryFixed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!formState.hasSaved)
          _ByokSetupSurface(
            key: const ValueKey<String>('onboarding_byok_setup_card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.onboardingSelectProvider,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hLg,
                Column(
                  children: [
                    for (
                      var index = 0;
                      index < widget.options.length;
                      index++
                    ) ...[
                      if (index != 0) AppWhiteSpace.hMd,
                      Builder(
                        builder: (context) {
                          final option = widget.options[index];
                          final isSelected =
                              formState.selectedProvider == option.providerName;
                          return _ByokProviderCard(
                            option: option,
                            selected: isSelected,
                            onTap: () {
                              ref
                                  .read(
                                    _OnboardingProviders
                                        .byokFormProvider
                                        .notifier,
                                  )
                                  .selectProvider(
                                    option.providerName,
                                    widget.options,
                                  );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
                if (formState.selectedProvider != null) ...[
                  AppWhiteSpace.hXl,
                  const _InputLabel(title: AppStrings.model),
                  AppWhiteSpace.hSm,
                  _OnboardingModelSelector(
                    options: widget.options,
                    providerName: formState.selectedProvider!,
                    selectedModelId: formState.selectedModel,
                    onChanged: (value) {
                      ref
                          .read(_OnboardingProviders.byokFormProvider.notifier)
                          .selectModel(value);
                    },
                  ),
                ],
                AppWhiteSpace.hLg,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    _apiKeyLabelFor(formState.selectedProvider),
                    key: const ValueKey<String>(
                      'onboarding_byok_api_key_label',
                    ),
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppWhiteSpace.hSm,
                _ByokApiKeyField(
                  controller: _keyController,
                  hintText: _apiKeyHintFor(formState.selectedProvider),
                  onChanged: (_) {
                    ref
                        .read(_OnboardingProviders.byokFormProvider.notifier)
                        .clearValidationMessage();
                  },
                ),
                AppWhiteSpace.hSm,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    AppStrings.onboardingApiKeySecureHelper,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ),
                if (formState.validationMessage != null) ...[
                  AppWhiteSpace.hSm,
                  Text(
                    formState.validationMessage!,
                    key: const ValueKey<String>(
                      'onboarding_byok_validation_message',
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
                AppWhiteSpace.hXl,
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _keyController,
                  builder: (context, value, child) {
                    final canSave =
                        formState.selectedProvider != null &&
                        value.text.trim().isNotEmpty &&
                        !formState.isSaving;
                    return SizedBox(
                      width: double.infinity,
                      height: AppSizing.onboardingByokFieldHeight,
                      child: FilledButton(
                        key: const ValueKey<String>(
                          'onboarding_byok_secure_connection',
                        ),
                        onPressed: canSave ? _saveKey : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.secondary,
                          foregroundColor: context.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.defaultRadius,
                            ),
                          ),
                        ),
                        child: formState.isSaving
                            ? SizedBox(
                                width: AppSizing.iconSm,
                                height: AppSizing.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSizing.strokeWidth,
                                  color: context.colorScheme.onSecondary,
                                ),
                              )
                            : const Text(AppStrings.onboardingSecureConnection),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

        if (formState.hasSaved)
          Container(
            key: const ValueKey<String>('onboarding_byok_saved'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: savedBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.materialCheckCircle,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    savedForeground,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.byokOnboardingSaved,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: savedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (!formState.hasSaved) ...[
          AppWhiteSpace.hXl,
          const _ByokSecureDivider(),
        ],
      ],
    );
  }
}

class _ByokProviderCard extends StatelessWidget {
  const _ByokProviderCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ByokProviderOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: true,
      selected: selected,
      label: option.displayName,
      excludeSemantics: true,
      child: AnimatedContainer(
        key: ValueKey<String>('onboarding_byok_provider_${option.id}'),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: AppSizing.onboardingByokProviderCardMinHeight,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerLow
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSizing.iconXxl,
                    height: AppSizing.iconXxl,
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppRadius.defaultRadius,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      _iconForProvider(option.providerName),
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppWhiteSpace.hControlGap,
                  Text(
                    option.displayName,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSurface,
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

  String _iconForProvider(AiProviderName provider) {
    return switch (provider) {
      AiProviderName.openai => OutlinedSvgAssets.materialBolt,
      AiProviderName.anthropic => OutlinedSvgAssets.materialAutoAwesome,
      AiProviderName.google => OutlinedSvgAssets.materialCloud,
      AiProviderName.otherSupported => OutlinedSvgAssets.materialKey,
    };
  }
}

class _ByokApiKeyField extends StatefulWidget {
  const _ByokApiKeyField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_ByokApiKeyField> createState() => _ByokApiKeyFieldState();
}

class _ByokApiKeyFieldState extends State<_ByokApiKeyField> {
  late final FocusNode _focusNode;
  final ValueNotifier<bool> _obscured = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _obscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          key: const ValueKey<String>('onboarding_byok_api_key_field'),
          duration: const Duration(milliseconds: 200),
          height: AppSizing.onboardingByokFieldHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? focusColor
                  : context.colorScheme.surface,
              width: AppSizing.strokeWidth,
            ),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: _obscured,
            builder: (context, obscured, child) {
              return AppTextField(
                controller: widget.controller,
                focusNode: _focusNode,
                hintText: widget.hintText,
                obscureText: obscured,
                filled: true,
                fillColor: context.colorScheme.surface,
                borderRadius: AppRadius.defaultRadius,
                borderOverride: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.inputVertical,
                ),
                onChanged: widget.onChanged,
                suffixIcon: IconButton(
                  tooltip: obscured
                      ? AppStrings.showApiKey
                      : AppStrings.hideApiKey,
                  onPressed: () => _obscured.value = !obscured,
                  icon: SvgPicture.asset(
                    obscured
                        ? OutlinedSvgAssets.materialVisibility
                        : OutlinedSvgAssets.materialVisibilityOff,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.outline,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ByokSecureDivider extends StatelessWidget {
  const _ByokSecureDivider();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: 0.3,
        child: Row(
          key: const ValueKey<String>('onboarding_byok_secure_divider'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizing.reviewStatusDot,
              height: AppSizing.reviewStatusDot,
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.fieldWidthSm,
              height: AppSizing.divider,
              color: context.colorScheme.outlineVariant,
            ),
            AppWhiteSpace.wSm,
            SvgPicture.asset(
              OutlinedSvgAssets.materialEncrypted,
              width: AppSizing.iconXxs,
              height: AppSizing.iconXxs,
              colorFilter: ColorFilter.mode(
                context.colorScheme.outline,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.fieldWidthSm,
              height: AppSizing.divider,
              color: context.colorScheme.outlineVariant,
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.reviewStatusDot,
              height: AppSizing.reviewStatusDot,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingModelSelector extends StatelessWidget {
  const _OnboardingModelSelector({
    required this.options,
    required this.providerName,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<ByokProviderOption> options;
  final AiProviderName providerName;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    final focusColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      borderSide: BorderSide(
        color: context.colorScheme.outlineVariant,
        width: AppSizing.divider,
      ),
    );
    return SizedBox(
      height: AppSizing.onboardingByokFieldHeight,
      child: DropdownButtonFormField<String>(
        key: ValueKey<AiProviderName>(providerName),
        initialValue: selectedModelId,
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
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colorScheme.surface,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: focusColor,
              width: AppSizing.strokeWidth,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonVertical,
          ),
        ),
        items: option.models.map<DropdownMenuItem<String>>((model) {
          return DropdownMenuItem(
            value: model.id,
            child: Text(model.displayName, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        style: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurface,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.draft, required this.onJumpToStep});

  final OnboardingDraft draft;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;
    final experience =
        _OnboardingTaxonomy.experienceLabel(draft.experienceLevel) ??
        AppStrings.onboardingReviewEmptyValue;
    final focus = draft.goals.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : draft.goals.map(_OnboardingTaxonomy.goalLabel).join(', ');
    final schedule = draft.trainingDays.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : AppStrings.onboardingReviewScheduleValue(
            draft.trainingDays.length,
            draft.targetSessionLengthMinutes ??
                _ScheduleStep._defaultDuration.toInt(),
          );
    final equipment = draft.equipmentAccess.isEmpty
        ? AppStrings.onboardingReviewEmptyValue
        : draft.equipmentAccess
              .map(_OnboardingTaxonomy.equipmentLabel)
              .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ReviewIntro(),
        AppWhiteSpace.hXxl,
        _ReviewExperienceCard(
          tier: experience,
          focus: focus,
          duration: AppStrings.onboardingReviewExperienceDuration(experience),
          onModify: () => onJumpToStep(OnboardingStep.experienceGoals),
        ),
        AppWhiteSpace.hLg,
        _ReviewAiStatusCard(
          configured: !draft.byokSkipped,
          onTap: () => onJumpToStep(OnboardingStep.byokOptional),
        ),
        AppWhiteSpace.hLg,
        _ReviewSummaryCard(
          cardKey: const ValueKey<String>('onboarding_review_schedule_card'),
          title: AppStrings.onboardingReviewScheduleTitle,
          iconAsset: OutlinedSvgAssets.materialCalendarMonth,
          actionLabel: AppStrings.edit,
          summary: schedule,
          onAction: () => onJumpToStep(OnboardingStep.schedule),
          footer: _ReviewWeekIndicators(selectedDays: draft.trainingDays),
        ),
        AppWhiteSpace.hLg,
        _ReviewSummaryCard(
          cardKey: const ValueKey<String>('onboarding_review_equipment_card'),
          title: AppStrings.onboardingReviewEquipmentTitle,
          iconAsset: OutlinedSvgAssets.materialFitnessCenter,
          actionLabel: AppStrings.update,
          summary: equipment,
          onAction: () => onJumpToStep(OnboardingStep.equipment),
        ),
        AppWhiteSpace.hLg,
        _ReviewMetricCard(
          preferredUnit: preferredUnit,
          draft: draft,
          onTap: () => onJumpToStep(OnboardingStep.unitsMetrics),
        ),
      ],
    );
  }
}

class _ReviewIntro extends StatelessWidget {
  const _ReviewIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('onboarding_review_intro'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.onboardingFinalReviewTitle,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingReviewDescription,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ReviewExperienceCard extends StatelessWidget {
  const _ReviewExperienceCard({
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
    return _ReviewSurface(
      cardKey: const ValueKey<String>('onboarding_review_experience_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                  ],
                ),
              ),
              TextButton(
                onPressed: onModify,
                child: const Text(AppStrings.modify),
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          _ReviewFactTile(
            tileKey: const ValueKey<String>('onboarding_review_tier_tile'),
            label: AppStrings.onboardingReviewTierLabel,
            value: tier,
            onTap: onModify,
          ),
          AppWhiteSpace.hMd,
          _ReviewFactTile(
            tileKey: const ValueKey<String>('onboarding_review_focus_tile'),
            label: AppStrings.onboardingReviewFocusLabel,
            value: focus,
            onTap: onModify,
          ),
          AppWhiteSpace.hMd,
          _ReviewFactTile(
            tileKey: const ValueKey<String>('onboarding_review_duration_tile'),
            label: AppStrings.onboardingReviewDurationLabel,
            value: duration,
            onTap: onModify,
          ),
        ],
      ),
    );
  }
}

class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard({
    required this.cardKey,
    required this.title,
    required this.iconAsset,
    required this.actionLabel,
    required this.summary,
    required this.onAction,
    this.footer,
  });

  final Key cardKey;
  final String title;
  final String iconAsset;
  final String actionLabel;
  final String summary;
  final VoidCallback onAction;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _ReviewSurface(
      cardKey: cardKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  iconAsset,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  alignment: Alignment.centerLeft,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
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
    );
  }
}

class _ReviewSurface extends StatelessWidget {
  const _ReviewSurface({required this.cardKey, required this.child});

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

class _ReviewFactTile extends StatelessWidget {
  const _ReviewFactTile({
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
    return Material(
      key: tileKey,
      color: context.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
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

class _ReviewAiStatusCard extends StatelessWidget {
  const _ReviewAiStatusCard({required this.configured, required this.onTap});

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
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
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
                  Column(
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
                                  ? AppStrings
                                        .onboardingReviewAiConfiguredStatus
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewWeekIndicators extends StatelessWidget {
  const _ReviewWeekIndicators({required this.selectedDays});

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

class _ReviewMetricCard extends StatelessWidget {
  const _ReviewMetricCard({
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
        child: Material(
          type: MaterialType.transparency,
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
      ),
    );
  }
}

class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizing.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScheduleSliderThumbShape extends SliderComponentShape {
  const _ScheduleSliderThumbShape({required this.ringColor});

  final Color ringColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.square(AppSpacing.lg);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final outerPath = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: AppSpacing.buttonVertical),
      );
    canvas.drawShadow(
      outerPath,
      sliderTheme.thumbColor ?? ringColor,
      AppSpacing.xs,
      true,
    );
    canvas.drawCircle(
      center,
      AppSpacing.buttonVertical,
      Paint()..color = ringColor,
    );
    canvas.drawCircle(
      center,
      AppSpacing.sm,
      Paint()..color = sliderTheme.thumbColor ?? ringColor,
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: AppSizing.divider),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.bodyLg.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMd.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.iconAsset, required this.message});

  final String iconAsset;
  final String message;

  @override
  Widget build(BuildContext context) {
    final iconColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        AppWhiteSpace.wSm,
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityChoiceCard extends StatelessWidget {
  const _IdentityChoiceCard({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final foreground = selected ? accent : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minHeight: AppSizing.onboardingIdentityChoiceHeight,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerHigh
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                  AppWhiteSpace.hSm,
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm.copyWith(color: foreground),
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

class _UnitChoiceButton extends StatelessWidget {
  const _UnitChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBackground = context.colorScheme.surfaceContainerLowest;
    final selectedForeground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: AppSizing.iconXxl,
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : context.colorScheme.surfaceContainer.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.colorScheme.onSurface.withValues(
                      alpha: 0.06,
                    ),
                    blurRadius: AppSpacing.sm,
                    offset: const Offset(0, AppSpacing.xxs),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm.copyWith(
                  color: selected
                      ? selectedForeground
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final foreground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

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
              style: AppTextStyles.labelSm.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayChoice extends StatelessWidget {
  const _WeekdayChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final selectedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryContainer;
    final selectedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryContainer;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: AppSizing.onboardingWeekdayChoiceHeight,
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.surfaceContainerLow,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: selected
                      ? selectedForeground
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleSummaryTile extends StatelessWidget {
  const _ScheduleSummaryTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: accent
            ? context.colorScheme.secondaryContainer.withValues(alpha: 0.2)
            : context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: accent
                  ? context.colorScheme.secondary
                  : context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppWhiteSpace.hXs,
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              color: accent
                  ? context.colorScheme.secondary
                  : context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentSectionHeader extends StatelessWidget {
  const _EquipmentSectionHeader({required this.iconAsset, required this.title});

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

class _EquipmentVisualCard extends StatelessWidget {
  const _EquipmentVisualCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.eyebrow,
    this.imageAsset,
    this.iconAsset,
  }) : assert(imageAsset != null || iconAsset != null),
       compact = false;

  const _EquipmentVisualCard.compact({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.imageAsset,
    this.iconAsset,
  }) : assert(imageAsset != null || iconAsset != null),
       eyebrow = null,
       compact = true;

  final String title;
  final String description;
  final String? eyebrow;
  final String? imageAsset;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

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
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerHigh
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: compact
                ? _buildCompactContent(context, accent)
                : _buildFullContent(context, accent),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EquipmentVisual(
          imageAsset: imageAsset,
          iconAsset: iconAsset,
          height: AppSizing.onboardingEquipmentImageHeight,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: AppTextStyles.labelSm.copyWith(color: accent),
                      ),
                      AppWhiteSpace.hXs,
                    ],
                    Text(title, style: AppTextStyles.headlineMd),
                    AppWhiteSpace.hXs,
                    Text(
                      description,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppWhiteSpace.wMd,
              _EquipmentSelectionIcon(selected: selected, accent: accent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, Color accent) {
    return Row(
      children: [
        _EquipmentVisual(
          imageAsset: imageAsset,
          iconAsset: iconAsset,
          height: AppSizing.onboardingEquipmentThumbnail,
          width: AppSizing.onboardingEquipmentThumbnail,
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.labelMd),
                AppWhiteSpace.hXs,
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppWhiteSpace.wSm,
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _EquipmentSelectionIcon(selected: selected, accent: accent),
        ),
      ],
    );
  }
}

class _EquipmentVisual extends StatelessWidget {
  const _EquipmentVisual({
    required this.imageAsset,
    required this.iconAsset,
    required this.height,
    required this.width,
  });

  final String? imageAsset;
  final String? iconAsset;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (imageAsset != null) {
      return ExcludeSemantics(
        child: Image.asset(
          imageAsset!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: context.colorScheme.surfaceContainer,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        iconAsset!,
        width: AppSizing.cardBadge,
        height: AppSizing.cardBadge,
        colorFilter: ColorFilter.mode(
          context.theme.brightness == Brightness.dark
              ? context.colorScheme.primary
              : context.colorScheme.secondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _EquipmentSelectionIcon extends StatelessWidget {
  const _EquipmentSelectionIcon({required this.selected, required this.accent});

  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      decoration: BoxDecoration(
        color: selected ? accent : context.colorScheme.surfaceContainerLowest,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : context.colorScheme.outline,
          width: AppSizing.strokeWidth,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? SvgPicture.asset(
              OutlinedSvgAssets.materialCheck,
              width: AppSizing.iconXs,
              height: AppSizing.iconXs,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSecondary,
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
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
        constraints: const BoxConstraints(
          minHeight: AppSizing.optionCardMinHeight,
        ),
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
        child: Material(
          type: MaterialType.transparency,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IconBadge(
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
                          colorFilter: ColorFilter.mode(
                            accent,
                            BlendMode.srcIn,
                          ),
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
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.iconAsset,
    required this.accent,
    this.iconColor,
  });

  final String iconAsset;
  final Color accent;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Container(
      width: AppSizing.cardBadge,
      height: AppSizing.cardBadge,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        iconAsset,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(
          iconColor ?? defaultIconColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _ExercisePanel extends ConsumerWidget {
  const _ExercisePanel({
    super.key,
    required this.title,
    required this.iconAsset,
    required this.actionIconAsset,
    required this.placeholder,
    required this.selectedIds,
    required this.onRemove,
    required this.onTap,
    this.isWarning = false,
  });

  static const _visibleChipLimit = 8;

  final String title;
  final String iconAsset;
  final String actionIconAsset;
  final String placeholder;
  final List<int> selectedIds;
  final void Function(int id) onRemove;
  final VoidCallback onTap;
  final bool isWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = isWarning
        ? context.colorScheme.error
        : context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final visibleIds = selectedIds.take(_visibleChipLimit).toList();
    final visibleExercises = visibleIds
        .map(
          (id) => (
            id: id,
            detail: ref.watch(
              AppProviders.exerciseDetailControllerProvider(id),
            ),
          ),
        )
        .toList();
    final overflowCount = selectedIds.length - visibleIds.length;

    return _ConstraintSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              AppWhiteSpace.wControlGap,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (selectedIds.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ...visibleExercises.map((exercise) {
                  return exercise.detail.when(
                    data: (detail) => _SelectedExerciseChip(
                      label: detail?.name ?? AppStrings.exerciseNotFound,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                    loading: () => _SelectedExerciseChip(
                      label: AppStrings.loading,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                    error: (_, _) => _SelectedExerciseChip(
                      label: AppStrings.exerciseNotFound,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                  );
                }),
                if (overflowCount > 0)
                  _SelectedExerciseOverflowChip(
                    count: overflowCount,
                    isWarning: isWarning,
                  ),
              ],
            ),
          ],
          AppWhiteSpace.hLg,
          Semantics(
            button: true,
            label: placeholder,
            excludeSemantics: true,
            child: Material(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.controlGap,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          placeholder,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Container(
                        width: AppSizing.onboardingConstraintActionSize,
                        height: AppSizing.onboardingConstraintActionSize,
                        decoration: BoxDecoration(
                          color: isWarning
                              ? context.colorScheme.onSurfaceVariant
                              : accent,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          actionIconAsset,
                          width: AppSizing.iconXxs,
                          height: AppSizing.iconXxs,
                          colorFilter: ColorFilter.mode(
                            context.colorScheme.onSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedExerciseChip extends StatelessWidget {
  const _SelectedExerciseChip({
    required this.label,
    required this.isWarning,
    required this.onRemove,
  });

  final String label;
  final bool isWarning;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final background = isWarning
        ? context.colorScheme.errorContainer
        : context.colorScheme.surfaceContainerHigh;
    final foreground = isWarning
        ? context.colorScheme.onErrorContainer
        : context.colorScheme.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
      padding: const EdgeInsets.only(left: AppSpacing.controlGap),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(color: foreground),
            ),
          ),
          Semantics(
            button: true,
            label: AppStrings.removeExercise,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              child: SizedBox(
                width: AppSizing.cardBadge,
                height: AppSizing.cardBadge,
                child: Center(
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.materialClose,
                    width: AppSizing.iconXxs,
                    height: AppSizing.iconXxs,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedExerciseOverflowChip extends StatelessWidget {
  const _SelectedExerciseOverflowChip({
    required this.count,
    required this.isWarning,
  });

  final int count;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? context.colorScheme.errorContainer
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        AppStrings.onboardingExerciseOverflow(count),
        style: AppTextStyles.labelSm.copyWith(
          color: isWarning
              ? context.colorScheme.onErrorContainer
              : context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _OnboardingExerciseMultiSelect {
  _OnboardingExerciseMultiSelect._();

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required List<int> currentIds,
    required void Function(List<int> ids) onDone,
  }) async {
    if (!context.mounted) return;
    final exercises = await ref
        .read(AppProviders.exerciseDaoProvider)
        .getAllExercises();

    if (!context.mounted) return;
    if (exercises.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.exerciseLibrarySyncUnavailableOffline),
          ),
        );
      }
      return;
    }
    final tempIds = Set<int>.from(currentIds);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.favoriteExercises,
                            style: AppTextStyles.headlineMd,
                          ),
                          FilledButton(
                            onPressed: () {
                              onDone(tempIds.toList());
                              ctx.pop();
                            },
                            child: const Text(AppStrings.onboardingDoneLabel),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: AppSizing.hairlineStrokeWidth),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: exercises.length,
                        itemBuilder: (_, index) {
                          final exercise = exercises[index];
                          final selected = tempIds.contains(exercise.id);
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              bottom: AppSpacing.sm,
                            ),
                            child: Semantics(
                              selected: selected,
                              child: AppListTile(
                                title: exercise.name,
                                trailing: selected
                                    ? SvgPicture.asset(
                                        OutlinedSvgAssets.materialCheckCircle,
                                        width: AppSizing.iconMd,
                                        height: AppSizing.iconMd,
                                        colorFilter: ColorFilter.mode(
                                          context.colorScheme.secondary,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : Container(
                                        width: AppSizing.iconMd,
                                        height: AppSizing.iconMd,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context
                                                .colorScheme
                                                .outlineVariant,
                                            width: AppSizing.strokeWidth,
                                          ),
                                        ),
                                      ),
                                onTap: () {
                                  setSheetState(() {
                                    if (!selected) {
                                      tempIds.add(exercise.id);
                                    } else {
                                      tempIds.remove(exercise.id);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
