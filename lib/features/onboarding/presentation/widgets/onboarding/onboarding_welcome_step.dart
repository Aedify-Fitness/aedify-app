import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_form_field.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_icon_badge.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_input_label.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _OnboardingWelcomeFeatureCard(
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
                child: _OnboardingWelcomeFeatureCard(
                  iconAsset: OutlinedSvgAssets.materialAutoAwesome,
                  title: AppStrings.onboardingByokBenefitOptional,
                  description: AppStrings.onboardingWelcomePrivacyBulletTwo,
                ),
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: _OnboardingWelcomeFeatureCard(
                  iconAsset: OutlinedSvgAssets.materialVisibilityOff,
                  title: AppStrings.onboardingPrivateControlTitle,
                  description: AppStrings.onboardingPrivateControlDescription,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingInputLabel(title: AppStrings.onboardingDisplayNamePrompt),
            AppWhiteSpace.hSm,
            OnboardingFormField(
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

class _OnboardingWelcomeFeatureCard extends StatelessWidget {
  const _OnboardingWelcomeFeatureCard({
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                OnboardingIconBadge(
                  iconAsset: iconAsset,
                  accent: context.colorScheme.surfaceContainerHighest,
                  iconColor: accent,
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: _OnboardingWelcomeFeatureCopy(
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
                _OnboardingWelcomeFeatureCopy(
                  title: title,
                  description: description,
                ),
              ],
            ),
    );
  }
}

class _OnboardingWelcomeFeatureCopy extends StatelessWidget {
  const _OnboardingWelcomeFeatureCopy({
    required this.title,
    required this.description,
  });

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
