import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class BodymapSideSelector extends StatelessWidget {
  const BodymapSideSelector({
    super.key,
    required this.side,
    required this.onSelected,
  });

  final BodymapViewSide side;
  final ValueChanged<BodymapViewSide> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: _BodymapSideButton(
                semanticKey: const ValueKey<String>('bodymap_side_front'),
                label: AppStrings.bodymapFront,
                selected: side == BodymapViewSide.front,
                onTap: () => onSelected(BodymapViewSide.front),
              ),
            ),
            AppWhiteSpace.wXs,
            Expanded(
              child: _BodymapSideButton(
                semanticKey: const ValueKey<String>('bodymap_side_back'),
                label: AppStrings.bodymapBack,
                selected: side == BodymapViewSide.back,
                onTap: () => onSelected(BodymapViewSide.back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodymapSideButton extends StatelessWidget {
  const _BodymapSideButton({
    required this.semanticKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key semanticKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final activeBackground = isDark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
    final activeForeground = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;

    return Semantics(
      key: semanticKey,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: selected ? activeBackground : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: selected
                        ? activeForeground
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
