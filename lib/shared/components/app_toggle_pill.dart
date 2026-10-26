import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

/// Animated on/off pill toggle. Replaces the default [Switch] so toggles
/// across settings surfaces share the design system's accent colors and
/// pill shape language.
class AppTogglePill extends StatelessWidget {
  const AppTogglePill({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const double _trackWidth = 52;
  static const double _trackHeight = 32;
  static const double _thumbSize = 24;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final enabled = onChanged != null;

    final activeTrack = isDark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
    final activeThumb = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;

    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _trackWidth,
          height: _trackHeight,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: value ? activeTrack : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: value
                ? null
                : Border.all(
                    color: colorScheme.outlineVariant,
                    width: AppSizing.strokeWidth,
                  ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                color: value ? activeThumb : colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
