import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

/// Rich list row on a tonal surface. Replaces default [ListTile] usages so
/// list rows across settings, libraries, and history share the design
/// system's surfaces, typography, and spacing.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingAsset,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final String? leadingAsset;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                AppWhiteSpace.custom(width: AppSpacing.sm + AppSpacing.xs),
              ] else if (leadingAsset != null) ...[
                Container(
                  width: AppSpacing.xl + AppSpacing.xs,
                  height: AppSpacing.xl + AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      leadingAsset!,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                AppWhiteSpace.custom(width: AppSpacing.sm + AppSpacing.xs),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppWhiteSpace.hXxs,
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[AppWhiteSpace.wSm, trailing!],
              if (showChevron && trailing == null) ...[
                AppWhiteSpace.wSm,
                SvgPicture.asset(
                  OutlinedSvgAssets.chevronRight,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
