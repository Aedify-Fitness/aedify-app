import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.item,
    this.isSelected = false,
    required this.onTap,
  });

  final ExerciseListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppRadius.defaultRadius,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        SolidSvgAssets.checkCircle,
                        width: AppSizing.iconLg,
                        height: AppSizing.iconLg,
                        colorFilter: ColorFilter.mode(
                          colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: isSelected
                          ? colorScheme.secondary
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppWhiteSpace.hXs,
                  Row(
                    children: [
                      _TagChip(
                        label: item.muscleGroups.isNotEmpty
                            ? item.muscleGroups.first.label
                            : item.modality.dbValue,
                      ),
                      if (item.equipment != null) ...[
                        AppWhiteSpace.wSm,
                        _TagChip(
                          label: _formatEquipment(item.equipment!.dbValue),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AppWhiteSpace.wSm,
            _DifficultyBadge(difficulty: item.difficulty),
          ],
        ),
      ),
    );
  }
}

String _formatEquipment(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _formatLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.headlineXl.copyWith(
          fontSize: AppFontSizes.xxs,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final ExerciseDifficulty? difficulty;

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;

    final (Color bg, Color text) = switch (difficulty) {
      ExerciseDifficulty.novice => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyNoviceBg
            : AedifyDarkColors.difficultyNoviceBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyNoviceText
            : AedifyDarkColors.difficultyNoviceText,
      ),
      ExerciseDifficulty.intermediate => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyIntermediateBg
            : AedifyDarkColors.difficultyIntermediateBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyIntermediateText
            : AedifyDarkColors.difficultyIntermediateText,
      ),
      ExerciseDifficulty.advanced => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyAdvancedBg
            : AedifyDarkColors.difficultyAdvancedBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyAdvancedText
            : AedifyDarkColors.difficultyAdvancedText,
      ),
      _ => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyBeginnerBg
            : AedifyDarkColors.difficultyBeginnerBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyBeginnerText
            : AedifyDarkColors.difficultyBeginnerText,
      ),
    };

    return AppBadge(
      label: _formatLabel(difficulty?.dbValue ?? 'beginner'),
      backgroundColor: bg,
      foregroundColor: text,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      textStyle: AppTextStyles.headlineXl.copyWith(
        letterSpacing: 0.5,
        fontSize: AppFontSizes.xxs,
      ),
    );
  }
}
