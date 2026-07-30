import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Accessible pill selector used for compact onboarding choices.
class OnboardingSelectionPill extends StatelessWidget {
  const OnboardingSelectionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconAsset,
    this.growthPillarStyle = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconAsset;
  final bool growthPillarStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor = selected
        ? isDark
              ? colorScheme.primaryContainer
              : colorScheme.secondary
        : isDark
        ? colorScheme.surfaceContainerHigh
        : growthPillarStyle
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;
    final foregroundColor = selected
        ? isDark
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondary
        : growthPillarStyle
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final iconColor = selected ? foregroundColor : colorScheme.onSurfaceVariant;

    return Semantics(
      key: ValueKey<String>('onboarding_selection_$label'),
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? backgroundColor : colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: growthPillarStyle ? AppSpacing.lg : AppSpacing.md,
                vertical: growthPillarStyle ? AppSpacing.md : AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconAsset != null) ...[
                    SvgPicture.asset(
                      iconAsset!,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                    growthPillarStyle
                        ? AppWhiteSpace.wControlGap
                        : AppWhiteSpace.wXs,
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMd.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ),
                  if (selected && !growthPillarStyle) ...[
                    AppWhiteSpace.wXs,
                    SvgPicture.asset(
                      OutlinedSvgAssets.materialCheck,
                      width: AppSizing.iconXxs,
                      height: AppSizing.iconXxs,
                      colorFilter: ColorFilter.mode(
                        foregroundColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
