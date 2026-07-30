import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';

/// Dashed-border empty state with an icon, title, optional message, and an
/// optional call-to-action. Used when a list or section has no content.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.iconAsset,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String iconAsset;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      height: AppSizing.emptyStateHeight,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: colorScheme.outlineVariant,
          strokeWidth: AppSizing.strokeWidth,
          dashWidth: AppSpacing.sm,
          gapWidth: AppSpacing.sm,
          borderRadius: AppRadius.md,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.xxl,
                  height: AppSpacing.xxl,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        colorScheme.outline,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                AppWhiteSpace.hMd,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (message != null) ...[
                  AppWhiteSpace.hXs,
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  AppWhiteSpace.hMd,
                  FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
