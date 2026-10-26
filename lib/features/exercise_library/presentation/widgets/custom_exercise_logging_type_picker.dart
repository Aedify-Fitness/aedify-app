import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseLoggingTypePicker extends StatelessWidget {
  const CustomExerciseLoggingTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final ExerciseLoggingType? selected;
  final ValueChanged<ExerciseLoggingType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('custom_exercise_logging_type_panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            AppStrings.customExerciseLoggingType,
            style: CustomExerciseEditorStyle.heading(context),
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.customExerciseLoggingTypeDesc,
          style: CustomExerciseEditorStyle.small(context),
        ),
        AppWhiteSpace.hMd,
        _LoggingTypeChoice(
          key: const Key('custom_exercise_logging_reps_only'),
          iconAsset: OutlinedSvgAssets.numberedList,
          title: AppStrings.customExerciseLoggingTypeRepsOnly,
          description: AppStrings.customExerciseLoggingTypeRepsOnlyDesc,
          isSelected: selected == ExerciseLoggingType.repsOnly,
          enabled: enabled,
          onTap: () => onChanged(ExerciseLoggingType.repsOnly),
        ),
        AppWhiteSpace.hSm,
        _LoggingTypeChoice(
          key: const Key('custom_exercise_logging_weight_reps'),
          iconAsset: OutlinedSvgAssets.materialFitnessCenter,
          title: AppStrings.customExerciseLoggingTypeWeightReps,
          description: AppStrings.customExerciseLoggingTypeWeightRepsDesc,
          isSelected: selected == ExerciseLoggingType.repsWeight,
          enabled: enabled,
          onTap: () => onChanged(ExerciseLoggingType.repsWeight),
        ),
        AppWhiteSpace.hSm,
        _LoggingTypeChoice(
          key: const Key('custom_exercise_logging_duration'),
          iconAsset: OutlinedSvgAssets.materialTimer,
          title: AppStrings.customExerciseLoggingTypeDuration,
          description: AppStrings.customExerciseLoggingTypeDurationDesc,
          isSelected: selected == ExerciseLoggingType.duration,
          enabled: enabled,
          onTap: () => onChanged(ExerciseLoggingType.duration),
        ),
      ],
    );
  }
}

class _LoggingTypeChoice extends StatelessWidget {
  const _LoggingTypeChoice({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final foreground = !enabled
        ? cs.outline
        : isSelected
        ? CustomExerciseEditorStyle.selectedForeground(context)
        : cs.onSurface;
    final secondaryForeground = !enabled
        ? cs.outline
        : isSelected
        ? CustomExerciseEditorStyle.selectedForeground(context)
        : cs.onSurfaceVariant;

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: isSelected,
        enabled: enabled,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: !enabled
              ? cs.surfaceContainer
              : isSelected
              ? CustomExerciseEditorStyle.selectedFill(context)
              : CustomExerciseEditorStyle.panel(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppCustomExerciseEditorTokens.controlSize,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: SvgPicture.asset(
                        iconAsset,
                        width: AppSizing.iconMd,
                        height: AppSizing.iconMd,
                        colorFilter: ColorFilter.mode(
                          !enabled || isSelected
                              ? foreground
                              : CustomExerciseEditorStyle.accent(context),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    AppWhiteSpace.wMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: CustomExerciseEditorStyle.label(
                              context,
                            ).copyWith(color: foreground),
                          ),
                          AppWhiteSpace.hXs,
                          Text(
                            description,
                            style: CustomExerciseEditorStyle.small(
                              context,
                            ).copyWith(color: secondaryForeground),
                          ),
                        ],
                      ),
                    ),
                    AppWhiteSpace.wSm,
                    ExcludeSemantics(
                      child: SizedBox(
                        width: AppSizing.iconMd,
                        height: AppSizing.iconMd,
                        child: isSelected
                            ? SvgPicture.asset(
                                OutlinedSvgAssets.checkCircle,
                                colorFilter: ColorFilter.mode(
                                  foreground,
                                  BlendMode.srcIn,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
