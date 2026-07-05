import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.fontWeight,
    this.letterSpacing,
    super.key,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? context.textTheme.labelSmall;

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
      child: Text(
        label,
        style: baseStyle?.copyWith(
          color: foregroundColor ?? context.colorScheme.onSecondary,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
