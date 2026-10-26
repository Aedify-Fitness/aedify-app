import 'package:aedify/shared/constants/svg_assets_outlined.dart';

import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingEquipmentVisualCard extends StatelessWidget {
  const OnboardingEquipmentVisualCard({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.eyebrow,
    this.imageAsset,
    this.iconAsset,
  }) : assert(imageAsset != null || iconAsset != null),
       compact = false;

  const OnboardingEquipmentVisualCard.compact({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.imageAsset,
    this.iconAsset,
  }) : assert(imageAsset != null || iconAsset != null),
       eyebrow = null,
       compact = true;

  final String title;
  final String description;
  final String? eyebrow;
  final String? imageAsset;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerHigh
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: compact
              ? _CompactContent(
                  title: title,
                  accent: accent,
                  selected: selected,
                  iconAsset: iconAsset,
                  imageAsset: imageAsset,
                  description: description,
                )
              : _FullContent(
                  title: title,
                  accent: accent,
                  eyebrow: eyebrow,
                  selected: selected,
                  iconAsset: iconAsset,
                  imageAsset: imageAsset,
                  description: description,
                ),
        ),
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.title,
    required this.accent,
    required this.selected,
    required this.iconAsset,
    required this.imageAsset,
    required this.description,
  });

  final String title;
  final Color accent;
  final bool selected;
  final String? iconAsset;
  final String? imageAsset;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OnboardingEquipmentVisual(
          isCompact: true,
          iconAsset: iconAsset,
          imageAsset: imageAsset,
          width: AppSizing.onboardingEquipmentThumbnail,
          height: AppSizing.onboardingEquipmentThumbnail,
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.labelMd),
                AppWhiteSpace.hXs,
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppWhiteSpace.wSm,
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _OnboardingEquipmentSelectionIcon(
            selected: selected,
            accent: accent,
          ),
        ),
      ],
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent({
    required this.title,
    required this.accent,
    required this.eyebrow,
    required this.selected,
    required this.iconAsset,
    required this.imageAsset,
    required this.description,
  });

  final String title;
  final Color accent;
  final bool selected;
  final String? eyebrow;
  final String? iconAsset;
  final String? imageAsset;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OnboardingEquipmentVisual(
          imageAsset: imageAsset,
          iconAsset: iconAsset,
          height: AppSizing.onboardingEquipmentImageHeight,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!,
                        style: AppTextStyles.labelSm.copyWith(color: accent),
                      ),
                      AppWhiteSpace.hXs,
                    ],
                    Text(title, style: AppTextStyles.headlineMd),
                    AppWhiteSpace.hXs,
                    Text(
                      description,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppWhiteSpace.wMd,
              _OnboardingEquipmentSelectionIcon(
                selected: selected,
                accent: accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingEquipmentVisual extends StatelessWidget {
  const _OnboardingEquipmentVisual({
    required this.imageAsset,
    required this.iconAsset,
    required this.height,
    required this.width,
    this.isCompact = false,
  });

  final double width;
  final double height;
  final bool isCompact;
  final String? iconAsset;
  final String? imageAsset;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isCompact
          ? BorderRadiusGeometry.horizontal(
              left: Radius.circular(AppRadius.md - 1),
            )
          : BorderRadiusGeometry.vertical(
              top: Radius.circular(AppRadius.md - 1),
            ),
      child: imageAsset != null
          ? Image.asset(
              imageAsset!,
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
          : Container(
              width: width,
              height: height,
              color: context.colorScheme.surfaceContainer,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconAsset!,
                width: AppSizing.cardBadge,
                height: AppSizing.cardBadge,
                colorFilter: ColorFilter.mode(
                  context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
    );
  }
}

class _OnboardingEquipmentSelectionIcon extends StatelessWidget {
  const _OnboardingEquipmentSelectionIcon({
    required this.selected,
    required this.accent,
  });

  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      decoration: BoxDecoration(
        color: selected ? accent : context.colorScheme.surfaceContainerLowest,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : context.colorScheme.outline,
          width: AppSizing.strokeWidth,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? SvgPicture.asset(
              OutlinedSvgAssets.materialCheck,
              width: AppSizing.iconXs,
              height: AppSizing.iconXs,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSecondary,
                BlendMode.srcIn,
              ),
            )
          : null,
    );
  }
}
