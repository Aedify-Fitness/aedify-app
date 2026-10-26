import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_step_content.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_step_scaffold.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class OnboardingStepBody extends StatelessWidget {
  const OnboardingStepBody({
    super.key,
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
      scrollResetKey: state.currentStep,
      header: OnboardingProgressHeader(
        currentStep: state.currentStep,
        stepTitle: _stepLabelForStep(state.currentStep),
      ),
      hero: state.currentStep == OnboardingStep.welcome
          ? const _OnboardingWelcomeHero()
          : null,
      onBack: state.currentStep == OnboardingStep.welcome ? null : onBack,
      onNext: isReview ? onComplete : onNext,
      isPrimaryLoading: state.isSaving,
      primaryLabel: switch (state.currentStep) {
        OnboardingStep.welcome => AppStrings.onboardingInitializeSpace,
        OnboardingStep.review => AppStrings.finishSetup,
        _ => AppStrings.continueLabel,
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
      child: OnboardingStepContent(
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

class _OnboardingWelcomeHero extends StatelessWidget {
  const _OnboardingWelcomeHero();

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
