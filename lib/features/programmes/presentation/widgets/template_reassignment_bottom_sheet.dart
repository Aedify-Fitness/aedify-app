import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:go_router/go_router.dart';

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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.assignTemplate, style: context.textTheme.titleMedium),
          AppWhiteSpace.hMd,
          _CreateNewSection(),
          AppWhiteSpace.hMd,
          if (workouts.isNotEmpty) ...[
            _SectionHeader(title: AppStrings.fromSavedWorkouts),
            ...workouts.map(
              (item) => ListTile(
                leading: SvgPicture.asset(
                  OutlinedSvgAssets.documentText,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                ),
                title: Text(item.name),
                subtitle: Text(
                  '${item.exerciseCount} ${AppStrings.exercisesSelected}',
                ),
                onTap: () {
                  onSelectSavedWorkout?.call(item);
                  context.pop();
                },
              ),
            ),
            AppWhiteSpace.hMd,
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                AppStrings.noSavedWorkoutsToImport,
                style: context.textTheme.bodyMedium,
              ),
            ),
          if (templates.isNotEmpty) ...[
            _SectionHeader(title: AppStrings.programmeTemplates),
            ...templates.map(
              (template) => ListTile(
                title: Text(template.name),
                subtitle: template.dayType != null
                    ? Text(
                        '${AppStrings.dayTypeLabel}: ${template.dayType!.name}',
                      )
                    : null,
                onTap: () {
                  onSelected?.call(template);
                  context.pop();
                },
              ),
            ),
          ],
          AppWhiteSpace.hSm,
        ],
      ),
    );
  }
}

class _CreateNewSection extends StatelessWidget {
  const _CreateNewSection();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        OutlinedSvgAssets.plusCircle,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        AppStrings.createTemplate,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.primary,
        ),
      ),
      onTap: () {
        context.pop(true);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        title,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }
}
