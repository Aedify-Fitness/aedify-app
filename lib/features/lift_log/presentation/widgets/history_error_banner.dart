import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryErrorBanner extends StatelessWidget {
  const HistoryErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        top: AppSpacing.sm,
        right: AppSpacing.md,
        bottom: AppSpacing.xl,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colorScheme.error.withValues(alpha: 0.24),
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizing.iconXxl,
                  height: AppSizing.iconXxl,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.exclamationCircle,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      colorScheme.error,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodySm.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
