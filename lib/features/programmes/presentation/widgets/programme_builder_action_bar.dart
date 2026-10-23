import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Floating action treatment shared by every manual programme builder step.
class ProgrammeBuilderActionBar extends StatelessWidget {
  const ProgrammeBuilderActionBar({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.asset,
    required this.onPressed,
    this.actionKey,
    this.isSaving = false,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final String asset;
  final VoidCallback? onPressed;
  final Key? actionKey;
  final bool isSaving;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        key: const ValueKey('programme_builder_action_surface'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.secondary.withValues(
                alpha: AppProgrammeBuilderTokens.actionShadowOpacity,
              ),
              blurRadius: AppProgrammeBuilderTokens.actionShadowBlur,
              offset: const Offset(0, AppSpacing.xs),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSizing.reviewCardIcon,
              height: AppSizing.reviewCardIcon,
              decoration: BoxDecoration(
                color: context.colorScheme.onSecondary.withValues(
                  alpha: AppProgrammeBuilderTokens.actionIconOpacity,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                asset,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.onSecondary,
                      ),
                    ),
                    AppWhiteSpace.hXs,
                  ],
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AppWhiteSpace.wSm,
            Flexible(
              flex: 2,
              child: FilledButton(
                key: actionKey,
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.onSecondary,
                  foregroundColor: context.colorScheme.secondary,
                  disabledBackgroundColor: context.colorScheme.onSecondary
                      .withValues(
                        alpha: AppProgrammeBuilderTokens.actionDisabledOpacity,
                      ),
                  disabledForegroundColor: context.colorScheme.onSecondary,
                  minimumSize: const Size(0, AppSizing.iconXxl),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.buttonVertical,
                    horizontal: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSaving) ...[
                      SizedBox(
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizing.strokeWidth,
                          color: context.colorScheme.onSecondary,
                        ),
                      ),
                      AppWhiteSpace.wSm,
                    ],
                    Flexible(
                      child: Text(
                        actionLabel,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!isSaving) ...[
                      AppWhiteSpace.wSm,
                      SvgPicture.asset(
                        OutlinedSvgAssets.arrowRight,
                        width: AppSizing.iconXxs,
                        height: AppSizing.iconXxs,
                        colorFilter: ColorFilter.mode(
                          onPressed == null
                              ? context.colorScheme.onSecondary
                              : context.colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
