import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.onBack,
    required this.onNext,
    this.isPrimaryLoading = false,
    this.primaryLabel,
    this.secondaryLabel,
    this.description,
    this.header,
    this.hero,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isPrimaryLoading;
  final String? primaryLabel;
  final String? secondaryLabel;
  final String? description;
  final Widget? header;
  final Widget? hero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[header!, AppWhiteSpace.hXl],
                    if (hero != null) ...[
                      hero!,
                      AppWhiteSpace.hXl,
                    ] else ...[
                      Text(
                        title,
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      if (description != null) ...[
                        AppWhiteSpace.hSm,
                        Text(
                          description!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      AppWhiteSpace.hLg,
                    ],
                    child,
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: context.colorScheme.outlineVariant,
                    width: AppSizing.divider,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (onBack != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        child: Text(secondaryLabel ?? AppStrings.backLabel),
                      ),
                    ),
                  if (onBack != null) AppWhiteSpace.wSm,
                  Expanded(
                    child: FilledButton(
                      onPressed: onNext,
                      child: isPrimaryLoading
                          ? SizedBox(
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSizing.divider * 2,
                                color: context.colorScheme.onPrimary,
                              ),
                            )
                          : Text(primaryLabel ?? AppStrings.continueLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
