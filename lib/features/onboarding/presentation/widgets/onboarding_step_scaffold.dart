import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
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
    this.bodyFooterLabel,
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
  final String? bodyFooterLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final primaryBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final primaryForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ?header,
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hero != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xl,
                        ),
                        color: context.colorScheme.surface,
                        child: hero!,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        top: AppSpacing.xl,
                        right: AppSpacing.md,
                        bottom: AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
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
                          if (title.isNotEmpty) AppWhiteSpace.hXl,
                          child,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: context.colorScheme.surface,
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppSizing.iconXxl,
                    child: FilledButton(
                      onPressed: onNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBackground,
                        foregroundColor: primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.defaultRadius,
                          ),
                        ),
                      ),
                      child: isPrimaryLoading
                          ? SizedBox(
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSizing.strokeWidth,
                                color: primaryForeground,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    primaryLabel ?? AppStrings.continueLabel,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppWhiteSpace.wXs,
                                SvgPicture.asset(
                                  OutlinedSvgAssets.materialArrowForward,
                                  width: AppSizing.iconSm,
                                  height: AppSizing.iconSm,
                                  colorFilter: ColorFilter.mode(
                                    primaryForeground,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (onBack != null) ...[
                    AppWhiteSpace.hSm,
                    SizedBox(
                      width: double.infinity,
                      height: AppSizing.iconXxl,
                      child: TextButton(
                        onPressed: onBack,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colorScheme.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.defaultRadius,
                            ),
                          ),
                        ),
                        child: Text(secondaryLabel ?? AppStrings.backLabel),
                      ),
                    ),
                  ],
                  if (bodyFooterLabel != null) ...[
                    AppWhiteSpace.hSm,
                    Container(
                      alignment: Alignment.center,
                      height: AppSizing.iconXxl,
                      child: Text(
                        bodyFooterLabel!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
