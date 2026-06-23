import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (int i = 0; i < totalSteps; i++) ...[
            Expanded(
              child: Container(
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: i <= currentIndex
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            if (i < totalSteps - 1) const SizedBox(width: AppSpacing.xxs),
          ],
        ],
      ),
    );
  }
}
