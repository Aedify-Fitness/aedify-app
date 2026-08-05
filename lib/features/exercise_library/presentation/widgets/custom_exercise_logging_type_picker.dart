import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
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
      key: const Key('custom_exercise_logging_type_panel'),
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      offset: const Offset(0, AppSpacing.xxs),
                      blurRadius: AppRadius.defaultRadius,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  OutlinedSvgAssets.calculator,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
                ),
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: Column(
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
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth >=
                      AppSizing.customExerciseLoggingThreeColumnMinWidth
                  ? 3
                  : 2;
              final cardWidth =
                  (constraints.maxWidth - (AppSpacing.md * (columnCount - 1))) /
                  columnCount;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _LoggingTypeCard(
                    cardKey: const Key('custom_exercise_logging_reps_only'),
                    width: cardWidth,
                    iconAsset: OutlinedSvgAssets.numberedList,
                    title: AppStrings.customExerciseLoggingTypeRepsOnly,
                    description:
                        AppStrings.customExerciseLoggingTypeRepsOnlyDesc,
                    isSelected: selected == ExerciseLoggingType.repsOnly,
                    onTap: () => onChanged(ExerciseLoggingType.repsOnly),
                  ),
                  _LoggingTypeCard(
                    cardKey: const Key('custom_exercise_logging_weight_reps'),
                    width: cardWidth,
                    iconAsset: OutlinedSvgAssets.materialFitnessCenter,
                    title: AppStrings.customExerciseLoggingTypeWeightReps,
                    description:
                        AppStrings.customExerciseLoggingTypeWeightRepsDesc,
                    isSelected: selected == ExerciseLoggingType.repsWeight,
                    onTap: () => onChanged(ExerciseLoggingType.repsWeight),
                  ),
                  _LoggingTypeCard(
                    cardKey: const Key('custom_exercise_logging_duration'),
                    width: cardWidth,
                    iconAsset: OutlinedSvgAssets.materialTimer,
                    title: AppStrings.customExerciseLoggingTypeDuration,
                    description:
                        AppStrings.customExerciseLoggingTypeDurationDesc,
                    isSelected: selected == ExerciseLoggingType.duration,
                    onTap: () => onChanged(ExerciseLoggingType.duration),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoggingTypeCard extends StatelessWidget {
  const _LoggingTypeCard({
    required this.cardKey,
    required this.width,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final Key cardKey;
  final double width;
  final String iconAsset;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: cardKey,
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? cs.surfaceContainerLowest : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? cs.secondary
                  : cs.surfaceContainer.withValues(alpha: 0),
              width: AppSizing.strokeWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.04),
                offset: const Offset(0, AppSpacing.xxs),
                blurRadius: AppSpacing.sm,
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
                      width: AppSizing.iconXs,
                      height: AppSizing.iconXs,
                      colorFilter: ColorFilter.mode(
                        cs.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
              AppWhiteSpace.hSm,
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
              ),
              AppWhiteSpace.hSm,
              Text(
                description,
                style: AppTextStyles.labelSm.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
