import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

/// 48x48 SVG icon button with a semantic label. Replaces icon-only
/// [IconButton] usages so every icon control is accessible and uses the
/// project's SVG assets.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.asset,
    required this.onPressed,
    required this.semanticLabel,
    this.color,
    this.iconSize = AppSizing.iconMd,
    this.backgroundColor,
  });

  final String asset;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? color;
  final double iconSize;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          decoration: backgroundColor != null
              ? BoxDecoration(color: backgroundColor, shape: BoxShape.circle)
              : null,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            asset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              color ?? colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
