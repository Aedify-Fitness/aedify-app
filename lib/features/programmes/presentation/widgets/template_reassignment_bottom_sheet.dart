import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class TemplateReassignmentBottomSheet extends StatelessWidget {
  const TemplateReassignmentBottomSheet({
    super.key,
    this.availableTemplates,
    this.savedWorkouts,
    this.onSelected,
    this.onSelectSavedWorkout,
  });

  final List<ProgrammeBuilderTemplateDraft>? availableTemplates;
  final List<SavedWorkoutListItem>? savedWorkouts;
  final void Function(ProgrammeBuilderTemplateDraft)? onSelected;
  final void Function(SavedWorkoutListItem)? onSelectSavedWorkout;

  @override
  Widget build(BuildContext context) {
    final templates = availableTemplates ?? [];
    final workouts = savedWorkouts ?? [];

    return AppBottomSheet(
      title: AppStrings.assignTemplate,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CreateNewSection(),
            AppWhiteSpace.hLg,
            const AppSectionHeader(title: AppStrings.fromSavedWorkouts),
            AppWhiteSpace.hSm,
            if (workouts.isNotEmpty)
              ...workouts.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppListTile(
                    leadingAsset: OutlinedSvgAssets.documentText,
                    title: item.name,
                    subtitle:
                        '${item.exerciseCount} ${AppStrings.exercisesSelected}',
                    showChevron: true,
                    onTap: () {
                      onSelectSavedWorkout?.call(item);
                      context.pop();
                    },
                  ),
                ),
              )
            else
              const _EmptySavedWorkouts(),
            if (templates.isNotEmpty) ...[
              AppWhiteSpace.hLg,
              const AppSectionHeader(title: AppStrings.programmeTemplates),
              AppWhiteSpace.hSm,
              ...templates.map(
                (template) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppListTile(
                    leadingAsset: OutlinedSvgAssets.rectangleStack,
                    title: template.name,
                    subtitle: template.dayType != null
                        ? '${AppStrings.dayTypeLabel}: ${template.dayType!.name}'
                        : null,
                    showChevron: true,
                    onTap: () {
                      onSelected?.call(template);
                      context.pop();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateNewSection extends StatelessWidget {
  const _CreateNewSection();

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leadingAsset: OutlinedSvgAssets.plusCircle,
      title: AppStrings.createTemplate,
      subtitle: AppStrings.selectExercisesForTemplate,
      showChevron: true,
      onTap: () => context.pop(true),
    );
  }
}

class _EmptySavedWorkouts extends StatelessWidget {
  const _EmptySavedWorkouts();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          AppStrings.noSavedWorkoutsToImport,
          style: AppTextStyles.bodySm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
