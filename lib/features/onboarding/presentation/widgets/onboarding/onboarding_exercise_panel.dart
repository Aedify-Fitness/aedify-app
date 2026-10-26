import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_constraint_surface.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingExercisePanel extends ConsumerWidget {
  const OnboardingExercisePanel({
    super.key,
    required this.title,
    required this.iconAsset,
    required this.actionIconAsset,
    required this.placeholder,
    required this.selectedIds,
    required this.onRemove,
    required this.onTap,
    this.isWarning = false,
  });

  static const _visibleChipLimit = 8;

  final String title;
  final String iconAsset;
  final String actionIconAsset;
  final String placeholder;
  final List<int> selectedIds;
  final void Function(int id) onRemove;
  final VoidCallback onTap;
  final bool isWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = isWarning
        ? context.colorScheme.error
        : context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final visibleIds = selectedIds.take(_visibleChipLimit).toList();
    final visibleExercises = visibleIds
        .map(
          (id) => (
            id: id,
            detail: ref.watch(
              AppProviders.exerciseDetailControllerProvider(id),
            ),
          ),
        )
        .toList();
    final overflowCount = selectedIds.length - visibleIds.length;

    return OnboardingConstraintSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              AppWhiteSpace.wControlGap,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (selectedIds.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ...visibleExercises.map((exercise) {
                  return exercise.detail.when(
                    data: (detail) => _OnboardingSelectedExerciseChip(
                      label: detail?.name ?? AppStrings.exerciseNotFound,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                    loading: () => _OnboardingSelectedExerciseChip(
                      label: AppStrings.loading,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                    error: (_, _) => _OnboardingSelectedExerciseChip(
                      label: AppStrings.exerciseNotFound,
                      isWarning: isWarning,
                      onRemove: () => onRemove(exercise.id),
                    ),
                  );
                }),
                if (overflowCount > 0)
                  _OnboardingSelectedExerciseOverflowChip(
                    count: overflowCount,
                    isWarning: isWarning,
                  ),
              ],
            ),
          ],
          AppWhiteSpace.hLg,
          Semantics(
            button: true,
            label: placeholder,
            excludeSemantics: true,
            child: Material(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.controlGap,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          placeholder,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Container(
                        width: AppSizing.onboardingConstraintActionSize,
                        height: AppSizing.onboardingConstraintActionSize,
                        decoration: BoxDecoration(
                          color: isWarning
                              ? context.colorScheme.onSurfaceVariant
                              : accent,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          actionIconAsset,
                          width: AppSizing.iconXxs,
                          height: AppSizing.iconXxs,
                          colorFilter: ColorFilter.mode(
                            context.colorScheme.onSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSelectedExerciseChip extends StatelessWidget {
  const _OnboardingSelectedExerciseChip({
    required this.label,
    required this.isWarning,
    required this.onRemove,
  });

  final String label;
  final bool isWarning;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final background = isWarning
        ? context.colorScheme.errorContainer
        : context.colorScheme.surfaceContainerHigh;
    final foreground = isWarning
        ? context.colorScheme.onErrorContainer
        : context.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.inputHorizontal,
        horizontal: AppSpacing.controlGap,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(color: foreground),
            ),
          ),
          AppWhiteSpace.wSm,
          Semantics(
            button: true,
            label: AppStrings.removeExercise,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              child: Center(
                child: SvgPicture.asset(
                  OutlinedSvgAssets.materialClose,
                  width: AppSizing.iconXxs,
                  height: AppSizing.iconXxs,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSelectedExerciseOverflowChip extends StatelessWidget {
  const _OnboardingSelectedExerciseOverflowChip({
    required this.count,
    required this.isWarning,
  });

  final int count;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.inputHorizontal,
        horizontal: AppSpacing.controlGap,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? context.colorScheme.errorContainer
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        AppStrings.onboardingExerciseOverflow(count),
        style: AppTextStyles.labelSm.copyWith(
          color: isWarning
              ? context.colorScheme.onErrorContainer
              : context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
