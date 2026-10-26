import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodymapBucketChipBar extends StatelessWidget {
  const BodymapBucketChipBar({
    super.key,
    required this.selectedBucket,
    required this.onSelected,
    required this.onClear,
  });

  final BodymapBucket? selectedBucket;
  final ValueChanged<BodymapBucket> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          for (var index = 0; index < BodymapBucket.values.length; index++) ...[
            _BodymapBucketPill(
              bucket: BodymapBucket.values[index],
              selected: selectedBucket == BodymapBucket.values[index],
              onTap: selectedBucket == BodymapBucket.values[index]
                  ? onClear
                  : () => onSelected(BodymapBucket.values[index]),
            ),
            if (index != BodymapBucket.values.length - 1) AppWhiteSpace.wSm,
          ],
        ],
      ),
    );
  }
}

class _BodymapBucketPill extends StatelessWidget {
  const _BodymapBucketPill({
    required this.bucket,
    required this.selected,
    required this.onTap,
  });

  final BodymapBucket bucket;
  final bool selected;
  final VoidCallback onTap;

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
        : colorScheme.surfaceContainerLow;
    final foregroundColor = selected
        ? isDark
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      key: ValueKey<String>('bodymap_bucket_${bucket.name}'),
      button: true,
      selected: selected,
      label: bucket.label,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    SvgPicture.asset(
                      OutlinedSvgAssets.check,
                      width: AppSizing.iconXxs,
                      height: AppSizing.iconXxs,
                      colorFilter: ColorFilter.mode(
                        foregroundColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wXs,
                  ],
                  Text(
                    bucket.label,
                    style: AppTextStyles.labelMd.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
