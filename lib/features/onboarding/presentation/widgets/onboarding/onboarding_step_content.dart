import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_byok_optional_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_core_identity_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_equipment_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_experience_goals_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_limitations_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_review_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_schedule_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_units_metrics_step.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_welcome_step.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingStepContent extends StatelessWidget {
  const OnboardingStepContent({
    super.key,
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
        _OnboardingValidationMessage(state: state),
        switch (state.currentStep) {
          OnboardingStep.welcome => OnboardingWelcomeStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.coreIdentity => OnboardingCoreIdentityStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.experienceGoals => OnboardingExperienceGoalsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.schedule => OnboardingScheduleStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.equipment => OnboardingEquipmentStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.unitsMetrics => OnboardingUnitsMetricsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.limitations => OnboardingLimitationsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.byokOptional => OnboardingByokOptionalStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.review => OnboardingReviewStep(
            draft: state.draft,
            onJumpToStep: onJumpToStep,
          ),
        },
      ],
    );
  }
}

class _OnboardingValidationMessage extends StatelessWidget {
  const _OnboardingValidationMessage({required this.state});

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
      child: _OnboardingSurfacePanel(
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

class _OnboardingSurfacePanel extends StatelessWidget {
  const _OnboardingSurfacePanel({
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
