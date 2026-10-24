import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Visual roles for exercise browsing controls and status messages.
abstract final class ExerciseLibraryStyle {
  static bool _isDark(BuildContext context) =>
      context.theme.brightness == Brightness.dark;

  static TextStyle heading(BuildContext context) =>
      (_isDark(context)
              ? AppTextStylesDark.headlineMd
              : AppTextStyles.headlineMd)
          .copyWith(color: context.colorScheme.onSurface);

  static TextStyle title(BuildContext context) => heading(
    context,
  ).copyWith(fontSize: AppFontSizes.lg, fontWeight: FontWeight.w600);

  static TextStyle body(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.bodyMd : AppTextStyles.bodyMd)
          .copyWith(color: context.colorScheme.onSurface);

  static TextStyle small(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.bodySm : AppTextStyles.bodySm)
          .copyWith(color: context.colorScheme.onSurfaceVariant);

  static TextStyle label(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.labelMd : AppTextStyles.labelMd)
          .copyWith(color: context.colorScheme.onSurface);

  static TextStyle caption(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.labelSm : AppTextStyles.labelSm)
          .copyWith(color: context.colorScheme.onSurfaceVariant);

  static Color accent(BuildContext context) => _isDark(context)
      ? context.colorScheme.primary
      : context.colorScheme.secondary;

  static Color panel(BuildContext context) => _isDark(context)
      ? context.colorScheme.surfaceContainerLow
      : context.colorScheme.surfaceContainerLowest;

  static Color actionFill(BuildContext context) => _isDark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondary;

  static Color actionForeground(BuildContext context) => _isDark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondary;
}
