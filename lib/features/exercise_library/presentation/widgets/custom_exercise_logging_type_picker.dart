import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseLoggingTypePicker extends StatelessWidget {
  const CustomExerciseLoggingTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ExerciseLoggingType? selected;
  final ValueChanged<ExerciseLoggingType> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: AppRadius.defaultRadius,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  SolidSvgAssets.dumbbell,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
                ),
              ),
              AppWhiteSpace.wSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.customExerciseLoggingType,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    AppStrings.customExerciseLoggingTypeDesc,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _LoggingTypeCard(
                iconAsset: OutlinedSvgAssets.numberedList,
                title: AppStrings.customExerciseLoggingTypeRepsOnly,
                description: AppStrings.customExerciseLoggingTypeRepsOnlyDesc,
                isSelected: selected == ExerciseLoggingType.repsOnly,
                onTap: () => onChanged(ExerciseLoggingType.repsOnly),
              ),
              _LoggingTypeCard(
                iconAsset: SolidSvgAssets.dumbbell,
                title: AppStrings.customExerciseLoggingTypeWeightReps,
                description: AppStrings.customExerciseLoggingTypeWeightRepsDesc,
                isSelected: selected == ExerciseLoggingType.repsWeight,
                onTap: () => onChanged(ExerciseLoggingType.repsWeight),
              ),
              _LoggingTypeCard(
                iconAsset: OutlinedSvgAssets.clock,
                title: AppStrings.customExerciseLoggingTypeDuration,
                description: AppStrings.customExerciseLoggingTypeDurationDesc,
                isSelected: selected == ExerciseLoggingType.duration,
                onTap: () => onChanged(ExerciseLoggingType.duration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoggingTypeCard extends StatelessWidget {
  const _LoggingTypeCard({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? cs.surfaceContainerLowest : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? cs.secondary : Colors.transparent,
            width: AppSizing.strokeWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    isSelected ? cs.secondary : cs.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                if (isSelected)
                  SvgPicture.asset(
                    OutlinedSvgAssets.checkCircle,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      cs.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
            ),
            Text(
              description,
              style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
