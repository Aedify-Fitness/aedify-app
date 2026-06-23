import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';

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
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isPrimaryLoading;
  final String? primaryLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    Text(title, style: AppTextStyles.headlineMd),
                    AppWhiteSpace.hLg,
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
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
