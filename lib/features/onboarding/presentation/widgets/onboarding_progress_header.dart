import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/image_assets.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.stepTitle,
  });

  final OnboardingStep currentStep;
  final String stepTitle;

  static const _stepOrder = [
    OnboardingStep.welcome,
    OnboardingStep.coreIdentity,
    OnboardingStep.experienceGoals,
    OnboardingStep.schedule,
    OnboardingStep.equipment,
    OnboardingStep.limitations,
    OnboardingStep.unitsMetrics,
    OnboardingStep.byokOptional,
    OnboardingStep.review,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stepOrder.indexOf(currentStep);
    final totalSteps = _stepOrder.length;
    final displayStep = currentIndex + 1;

    final progressColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      container: true,
      label: AppStrings.onboardingStepLabel(displayStep, totalSteps),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                ImageAssets.appLogo(context),
                height: AppSizing.iconLg,
              ),
              AppWhiteSpace.hLg,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.onboardingStepLabel(displayStep, totalSteps),
                      style: AppTextStyles.labelMd.copyWith(
                        color: progressColor,
                      ),
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Text(
                    stepTitle,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hMd,
              Row(
                children: [
                  for (var index = 0; index < totalSteps; index++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        key: ValueKey<String>(
                          'onboarding_progress_segment_$index',
                        ),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        height: AppSizing.progressBarHeight,
                        decoration: BoxDecoration(
                          color: index <= currentIndex
                              ? progressColor
                              : context.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                    if (index != totalSteps - 1) AppWhiteSpace.wSm,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
