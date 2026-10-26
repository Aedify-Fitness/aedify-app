import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_step_body.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';

class OnboardingStepView extends ConsumerWidget {
  const OnboardingStepView({super.key, required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.onboardingControllerProvider.notifier,
    );

    return OnboardingStepBody(
      state: state,
      onUpdateDraft: (draft) => controller.updateDraft(draft),
      onNext: () => controller.nextStep(),
      onBack: () => controller.previousStep(),
      onComplete: () => controller.completeOnboarding(),
      onJumpToStep: (step) => controller.jumpToStep(step),
    );
  }
}
