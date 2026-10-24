import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Visual roles shared by saved workout cards and their library states.
abstract final class SavedWorkoutLibraryStyle {
  static bool _dark(BuildContext context) =>
      context.theme.brightness == Brightness.dark;

  static TextStyle heading(BuildContext context) =>
      (_dark(context) ? AppTextStylesDark.headlineMd : AppTextStyles.headlineMd)
          .copyWith(color: context.colorScheme.onSurface);

  static TextStyle title(BuildContext context) =>
      heading(context).copyWith(fontSize: AppFontSizes.xl);

  static TextStyle body(BuildContext context) =>
      (_dark(context) ? AppTextStylesDark.bodyMd : AppTextStyles.bodyMd)
          .copyWith(color: context.colorScheme.onSurfaceVariant);

  static TextStyle label(BuildContext context) =>
      (_dark(context) ? AppTextStylesDark.labelMd : AppTextStyles.labelMd)
          .copyWith(color: context.colorScheme.onSurface);

  static TextStyle small(BuildContext context) =>
      (_dark(context) ? AppTextStylesDark.bodySm : AppTextStyles.bodySm)
          .copyWith(color: context.colorScheme.onSurfaceVariant);

  static Color panel(BuildContext context) => _dark(context)
      ? context.colorScheme.surfaceContainerLow
      : context.colorScheme.surfaceContainerLowest;

  static Color accent(BuildContext context) => _dark(context)
      ? context.colorScheme.primary
      : context.colorScheme.secondary;

  static Color actionFill(BuildContext context) => _dark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondary;

  static Color actionForeground(BuildContext context) => _dark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondary;

  static String formatLabel(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
