import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Primary action roles from DESIGN.md, shared across feature surfaces.
abstract final class AppButtonStyles {
  static bool _isDark(BuildContext context) =>
      context.theme.brightness == Brightness.dark;

  static Color primaryBackground(BuildContext context) => _isDark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondary;

  static Color primaryForeground(BuildContext context) => _isDark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondary;

  static ButtonStyle primary(
    BuildContext context, {
    required double minimumHeight,
  }) => FilledButton.styleFrom(
    backgroundColor: primaryBackground(context),
    foregroundColor: primaryForeground(context),
    minimumSize: Size.fromHeight(minimumHeight),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.buttonVertical,
    ),
    shape: const StadiumBorder(),
    textStyle:
        (_isDark(context) ? AppTextStylesDark.labelMd : AppTextStyles.labelMd)
            .copyWith(inherit: false),
  );
}
