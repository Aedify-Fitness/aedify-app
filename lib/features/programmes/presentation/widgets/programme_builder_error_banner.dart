import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeBuilderErrorBanner extends StatelessWidget {
  const ProgrammeBuilderErrorBanner({
    super.key,
    required this.errorCode,
    required this.errorMessage,
    this.onRetry,
  });

  final String? errorCode;
  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.brightness == Brightness.light
            ? AedifyLightColors.errorSurface
            : AedifyDarkColors.errorSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.error.withValues(alpha: 0.24),
          width: AppSizing.hairlineStrokeWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessage,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (errorCode?.trim().isNotEmpty == true) ...[
                    AppWhiteSpace.hXs,
                    Text(
                      errorCode!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onRetry != null) ...[
              AppWhiteSpace.wSm,
              TextButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
