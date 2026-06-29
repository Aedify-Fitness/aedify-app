import 'package:aedify/shared/constants/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({super.key, required this.currentStep});

  final OnboardingStep currentStep;

  static const _stepOrder = [
    OnboardingStep.welcome,
    OnboardingStep.experienceGoals,
    OnboardingStep.schedule,
    OnboardingStep.equipment,
    OnboardingStep.unitsMetrics,
    OnboardingStep.limitations,
    OnboardingStep.byokOptional,
    OnboardingStep.review,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stepOrder.indexOf(currentStep);
    final totalSteps = _stepOrder.length;
    final displayStep = currentIndex + 1;
    final progress = displayStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                ImageAssets.appLogo(context),
                height: AppSizing.iconLg,
              ),
              Text(
                AppStrings.onboardingStepLabel(displayStep, totalSteps),
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppWhiteSpace.hSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppSizing.progressBarHeight,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
