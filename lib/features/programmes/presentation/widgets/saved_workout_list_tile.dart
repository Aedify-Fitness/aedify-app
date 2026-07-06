import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class SavedWorkoutListTile extends StatelessWidget {
  const SavedWorkoutListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onStart,
    required this.onArchive,
    required this.onDelete,
  });

  final SavedWorkoutListItem item;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.surfaceContainer,
            width: AppSizing.hairlineStrokeWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.focus.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Text(
                            item.focus.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: cs.secondary,
                              fontSize: AppFontSizes.xxs,
                              letterSpacing: AppFontSizes.xxs * 0.05,
                            ),
                          ),
                        ),
                      Text(
                        item.name,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: cs.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppWhiteSpace.hSm,
                      Row(
                        children: [
                          SvgPicture.asset(
                            OutlinedSvgAssets.listBullet,
                            width: AppSizing.iconS,
                            height: AppSizing.iconS,
                            colorFilter: ColorFilter.mode(
                              cs.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          AppWhiteSpace.wXs,
                          Text(
                            '${item.exerciseCount} ${AppStrings.exercisesLabel}',
                            style: AppTextStyles.labelMd.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          if (item.estimatedDurationMinutes != null) ...[
                            AppWhiteSpace.wMd,
                            SvgPicture.asset(
                              OutlinedSvgAssets.clock,
                              width: AppSizing.iconS,
                              height: AppSizing.iconS,
                              colorFilter: ColorFilter.mode(
                                cs.onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                            ),
                            AppWhiteSpace.wXs,
                            Text(
                              '${item.estimatedDurationMinutes} ${AppStrings.onboardingReviewMinutes}',
                              style: AppTextStyles.labelMd.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(AppSpacing.sm, 0),
                  child: PopupMenuButton<String>(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    offset: const Offset(0, AppSpacing.xl + AppSpacing.md),
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.defaultRadius,
                      ),
                    ),
                    icon: SvgPicture.asset(
                      OutlinedSvgAssets.ellipsisVertical,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      colorFilter: ColorFilter.mode(
                        cs.outline,
                        BlendMode.srcIn,
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'start',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              OutlinedSvgAssets.playCircle,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                            ),
                            AppWhiteSpace.wSm,
                            Text(AppStrings.startWorkout),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              OutlinedSvgAssets.archiveBox,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                            ),
                            AppWhiteSpace.wSm,
                            Text(AppStrings.archiveWorkout),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              OutlinedSvgAssets.trash,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              colorFilter: ColorFilter.mode(
                                context.colorScheme.error,
                                BlendMode.srcIn,
                              ),
                            ),
                            AppWhiteSpace.wSm,
                            Text(
                              AppStrings.deleteWorkout,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'start':
                          onStart();
                        case 'archive':
                          onArchive();
                        case 'delete':
                          onDelete();
                      }
                    },
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StackedCategoryIcons(modalities: item.modalities, cs: cs),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    width: AppSizing.iconXxl,
                    height: AppSizing.iconXxl,
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: cs.secondary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        SolidSvgAssets.play,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          cs.onSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedCategoryIcons extends StatelessWidget {
  const _StackedCategoryIcons({required this.modalities, required this.cs});

  final List<String> modalities;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final icons = _resolveIcons(modalities).take(3).toList();
    if (icons.isEmpty) {
      icons.add(_iconForModality(''));
    }

    final backgrounds = [
      cs.surfaceContainer,
      cs.surfaceContainerLow,
      cs.surfaceContainerLow,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(icons.length, (i) {
        final child = _CategoryIconCircle(
          assetPath: icons[i],
          backgroundColor: backgrounds[i],
          borderColor: cs.surfaceContainerLowest,
        );
        if (i == 0) return child;
        return Transform.translate(
          offset: Offset(-AppSpacing.sm * i, 0),
          child: child,
        );
      }),
    );
  }

  List<String> _resolveIcons(List<String> modalities) {
    final seen = <String>{};
    final icons = <String>[];
    for (final m in modalities) {
      final icon = _iconForModality(m);
      if (seen.add(icon)) icons.add(icon);
    }
    return icons;
  }

  String _iconForModality(String modality) {
    final lower = modality.toLowerCase();
    if (lower.contains('strength') || lower.contains('power')) {
      return SolidSvgAssets.dumbbell;
    }
    if (lower.contains('cardio') || lower.contains('endurance')) {
      return OutlinedSvgAssets.heart;
    }
    if (lower.contains('flexibility') ||
        lower.contains('mobility') ||
        lower.contains('recovery')) {
      return SolidSvgAssets.meditation;
    }
    return SolidSvgAssets.dumbbell;
  }
}

class _CategoryIconCircle extends StatelessWidget {
  const _CategoryIconCircle({
    required this.assetPath,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String assetPath;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: borderColor, width: AppSizing.strokeWidth),
      ),
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          width: AppSizing.iconXs + 2,
          height: AppSizing.iconXs + 2,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
