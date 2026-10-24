import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Shared visual roles for active exercise logging and session controls.
abstract final class WorkoutRunnerStyle {
  static bool _isDark(BuildContext context) =>
      context.theme.brightness == Brightness.dark;

  static TextStyle heading(BuildContext context) =>
      (_isDark(context)
              ? AppTextStylesDark.headlineMd
              : AppTextStyles.headlineMd)
          .copyWith(color: context.colorScheme.onSurface);

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

  static Color selectedFill(BuildContext context) => _isDark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondaryContainer;

  static Color selectedForeground(BuildContext context) => _isDark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondaryContainer;

  static Color actionFill(BuildContext context) => _isDark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondary;

  static Color actionForeground(BuildContext context) => _isDark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondary;

  static Duration motionDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context)
      ? Duration.zero
      : AppDurations.segmentedControl;
}
