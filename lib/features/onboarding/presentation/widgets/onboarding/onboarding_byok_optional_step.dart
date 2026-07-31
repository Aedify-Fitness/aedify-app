import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_byok_form.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_byok_setup_surface.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingByokOptionalStep extends ConsumerStatefulWidget {
  const OnboardingByokOptionalStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  ConsumerState<OnboardingByokOptionalStep> createState() =>
      _ByokOptionalStepState();
}

class _ByokOptionalStepState extends ConsumerState<OnboardingByokOptionalStep> {
  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(OnboardingProviders.byokOptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingByokIntro(),
        AppWhiteSpace.hXl,
        optionsAsync.when(
          loading: () => const OnboardingByokSetupSurface(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => OnboardingByokSetupSurface(
            child: Text(
              AppErrorStrings.byokLoadFailedMessage,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          data: (options) {
            if (options.isEmpty) {
              return OnboardingByokSetupSurface(
                child: Text(
                  AppErrorStrings.byokLoadFailedMessage,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return OnboardingByokForm(
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

class OnboardingByokIntro extends StatelessWidget {
  const OnboardingByokIntro({super.key});

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
        OnboardingIntroHeader(
          title: AppStrings.onboardingIntelligenceLayerTitle,
          description: AppStrings.onboardingIntelligenceLayerDescription,
        ),
        const _OnboardingByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_private'),
          iconAsset: OutlinedSvgAssets.materialVerifiedUser,
          title: AppStrings.onboardingByokBenefitPrivate,
          description: AppStrings.onboardingByokBenefitPrivateDescription,
          emphasized: true,
        ),
        AppWhiteSpace.hMd,
        const _OnboardingByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_byok'),
          iconAsset: OutlinedSvgAssets.materialKey,
          title: AppStrings.onboardingByokBenefitBringYourOwnKey,
          description:
              AppStrings.onboardingByokBenefitBringYourOwnKeyDescription,
        ),
        AppWhiteSpace.hMd,
        const _OnboardingByokBenefitRow(
          key: ValueKey<String>('onboarding_byok_benefit_optional'),
          iconAsset: OutlinedSvgAssets.materialToggleOff,
          title: AppStrings.onboardingByokBenefitOptional,
          description: AppStrings.onboardingByokBenefitOptionalDescription,
        ),
      ],
    );
  }
}

class _OnboardingByokBenefitRow extends StatelessWidget {
  const _OnboardingByokBenefitRow({
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
