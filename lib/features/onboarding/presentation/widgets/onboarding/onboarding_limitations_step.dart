import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_constraint_surface.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_exercise_panel.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_form_field.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingLimitationsStep extends StatelessWidget {
  const OnboardingLimitationsStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _limitationOptions = [
    (
      AppStrings.onboardingLimitationNone,
      OutlinedSvgAssets.materialDoNotDisturbOn,
    ),
    (
      AppStrings.onboardingLimitationLowerBack,
      OutlinedSvgAssets.materialPersonalInjury,
    ),
    (
      AppStrings.onboardingLimitationKnee,
      OutlinedSvgAssets.materialDirectionsWalk,
    ),
    (
      AppStrings.onboardingLimitationShoulder,
      OutlinedSvgAssets.materialExercise,
    ),
    (AppStrings.onboardingLimitationWrist, OutlinedSvgAssets.materialBackHand),
    (
      AppStrings.onboardingLimitationHip,
      OutlinedSvgAssets.materialSettingsAccessibility,
    ),
    (
      AppStrings.onboardingLimitationNeck,
      OutlinedSvgAssets.materialAccessibilityNew,
    ),
    (AppStrings.onboardingLimitationElbow, OutlinedSvgAssets.materialExercise),
    (AppStrings.onboardingLimitationAnkle, OutlinedSvgAssets.materialSteps),
  ];

  Future<void> _showExerciseSelection({
    required BuildContext context,
    required WidgetRef ref,
    required List<int> currentIds,
    required Iterable<int> excludedIds,
    required ValueChanged<List<int>> onDone,
  }) async {
    final items = await ref
        .read(AppProviders.exerciseRepositoryProvider)
        .searchExercises(const ExerciseFilterState());
    if (!context.mounted) return;

    final currentIdSet = currentIds.toSet();
    final initialSelections = items
        .where((item) => currentIdSet.contains(item.id))
        .map(
          (item) => ExerciseReference(
            exerciseId: item.id,
            name: item.name,
            modality: item.modality.dbValue,
            loggingType: item.loggingType.dbValue,
            equipment: item.equipment?.dbValue,
            isCustom: item.isCustom,
          ),
        )
        .toList(growable: false);

    await ref
        .read(AppProviders.exerciseSearchControllerProvider.notifier)
        .clearFilters();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExerciseBottomSheet(
        initialSelections: initialSelections,
        excludedExerciseIds: excludedIds,
        onSelectExercises: (exercises) {
          onDone(
            exercises
                .map((exercise) => exercise.exerciseId)
                .toList(growable: false),
          );
        },
      ),
    );

    await ref
        .read(AppProviders.exerciseSearchControllerProvider.notifier)
        .clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Column(
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingPrecisionConstraintsTitle,
          description: AppStrings.onboardingPrecisionConstraintsDescription,
        ),
        Container(
          key: const ValueKey<String>('onboarding_safety_first_section'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.materialVerifiedUser,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.onboardingSafetyFirst,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.onboardingSafetyFirstDescription,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hLg,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialEncrypted,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                  AppWhiteSpace.wSm,
                  Expanded(
                    child: Text(
                      AppStrings.onboardingSensitiveDataLocal,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        OnboardingConstraintSurface(
          key: const ValueKey<String>('onboarding_injury_flags_section'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.onboardingInjuryFlagsTitle.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                ),
              ),
              AppWhiteSpace.hLg,
              Text(
                AppStrings.onboardingInjuryFlagsDescription,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hXl,
              GridView.builder(
                itemCount: _limitationOptions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: AppSizing.onboardingLimitationTileHeight,
                ),
                itemBuilder: (context, index) {
                  final limitation = _limitationOptions[index];
                  final selected = draft.limitations.contains(limitation.$1);
                  return _OnboardingLimitationOptionCard(
                    label: limitation.$1,
                    iconAsset: limitation.$2,
                    selected: selected,
                    onTap: () {
                      final updated = !selected
                          ? [...draft.limitations, limitation.$1]
                          : draft.limitations
                                .where((item) => item != limitation.$1)
                                .toList();
                      onUpdateDraft(draft.copyWith(limitations: updated));
                    },
                  );
                },
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        Consumer(
          builder: (context, ref, child) {
            return OnboardingExercisePanel(
              key: const ValueKey<String>(
                'onboarding_favorite_exercises_section',
              ),
              title: AppStrings.favoriteExercises.toUpperCase(),
              iconAsset: OutlinedSvgAssets.materialFavorite,
              actionIconAsset: OutlinedSvgAssets.materialAdd,
              placeholder: AppStrings.onboardingFavoriteExercisesPlaceholder,
              selectedIds: draft.favoriteExerciseIds,
              onRemove: (id) {
                onUpdateDraft(
                  draft.copyWith(
                    favoriteExerciseIds: draft.favoriteExerciseIds
                        .where((exerciseId) => exerciseId != id)
                        .toList(),
                  ),
                );
              },
              onTap: () => _showExerciseSelection(
                context: context,
                ref: ref,
                currentIds: draft.favoriteExerciseIds,
                excludedIds: draft.substitutedExerciseIds,
                onDone: (ids) {
                  onUpdateDraft(draft.copyWith(favoriteExerciseIds: ids));
                },
              ),
            );
          },
        ),
        AppWhiteSpace.hXl,
        Consumer(
          builder: (context, ref, child) {
            return OnboardingExercisePanel(
              key: const ValueKey<String>('onboarding_avoid_exercises_section'),
              title: AppStrings.onboardingAvoidListTitle.toUpperCase(),
              iconAsset: OutlinedSvgAssets.materialWarning,
              actionIconAsset: OutlinedSvgAssets.materialBlock,
              placeholder: AppStrings.onboardingAvoidExercisesPlaceholder,
              isWarning: true,
              selectedIds: draft.substitutedExerciseIds,
              onRemove: (id) {
                onUpdateDraft(
                  draft.copyWith(
                    substitutedExerciseIds: draft.substitutedExerciseIds
                        .where((exerciseId) => exerciseId != id)
                        .toList(),
                  ),
                );
              },
              onTap: () => _showExerciseSelection(
                context: context,
                ref: ref,
                currentIds: draft.substitutedExerciseIds,
                excludedIds: draft.favoriteExerciseIds,
                onDone: (ids) {
                  onUpdateDraft(draft.copyWith(substitutedExerciseIds: ids));
                },
              ),
            );
          },
        ),
        AppWhiteSpace.hXl,
        OnboardingConstraintSurface(
          key: const ValueKey<String>('onboarding_other_notes_section'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialEditNote,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wControlGap,
                  Expanded(
                    child: Text(
                      AppStrings.onboardingOtherNotesTitle.toUpperCase(),
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hMd,
              OnboardingFormField(
                initialValue: draft.notes ?? '',
                maxLines: 4,
                hintText: AppStrings.onboardingOtherNotesPlaceholder,
                onChanged: (value) {
                  onUpdateDraft(
                    draft.copyWith(notes: value.isEmpty ? null : value),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingLimitationOptionCard extends StatelessWidget {
  const _OnboardingLimitationOptionCard({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHigh
        : context.colorScheme.surfaceContainerLow;

    final foregroundColor = selected
        ? colorScheme.secondary
        : colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? foregroundColor : backgroundColor,
            width: AppSizing.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
              ),
              AppWhiteSpace.hControlGap,
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd.copyWith(color: foregroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
