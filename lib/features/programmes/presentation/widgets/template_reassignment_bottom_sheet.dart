import 'package:aedify/features/programmes/domain/programme_template_choices.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Mobile workout chooser for a programme assignment.
class TemplateReassignmentBottomSheet extends StatelessWidget {
  const TemplateReassignmentBottomSheet({
    super.key,
    this.availableTemplates,
    this.savedWorkouts,
    this.onSelected,
    this.onSelectSavedWorkout,
    this.assignmentScope,
  });

  final List<ProgrammeBuilderTemplateDraft>? availableTemplates;
  final List<SavedWorkoutListItem>? savedWorkouts;
  final void Function(ProgrammeBuilderTemplateDraft)? onSelected;
  final void Function(SavedWorkoutListItem)? onSelectSavedWorkout;
  final Widget? assignmentScope;

  @override
  Widget build(BuildContext context) {
    final templates = ProgrammeTemplateChoices.distinctByExercises(
      availableTemplates ?? [],
    );
    final workouts = savedWorkouts ?? [];

    return AppBottomSheet(
      // heightFactor: AppProgrammeBuilderTokens.assignmentSheetHeightFactor,
      showCloseButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AssignmentHeader(),
          Flexible(
            child: SingleChildScrollView(
              key: const ValueKey('template_assignment_choices'),
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom:
                    MediaQuery.viewPaddingOf(context).bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?assignmentScope,
                  _WorkoutChoiceCard(
                    title: AppStrings.createTemplate,
                    asset: OutlinedSvgAssets.plus,
                    highlighted: true,
                    metadata: const [AppStrings.selectExercisesForTemplate],
                    onTap: () => context.pop(true),
                  ),
                  if (templates.isNotEmpty) ...[
                    AppWhiteSpace.hXl,
                    _ChoiceGroupHeader(
                      title: AppStrings.programmeTemplates,
                      count: templates.length,
                    ),
                    AppWhiteSpace.hMd,
                    for (final template in templates) ...[
                      _WorkoutChoiceCard(
                        title: template.name,
                        asset: OutlinedSvgAssets.rectangleStack,
                        metadata: [
                          AppStrings.workoutExerciseTotal(
                            template.exercises.length,
                          ),
                          if (template.estimatedDurationMinutes
                              case final minutes?)
                            AppStrings.workoutDurationEstimate(minutes),
                        ],
                        onTap: () {
                          onSelected?.call(template);
                          context.pop();
                        },
                      ),
                      AppWhiteSpace.hSm,
                    ],
                  ],
                  AppWhiteSpace.hXl,
                  _ChoiceGroupHeader(
                    title: AppStrings.fromSavedWorkouts,
                    count: workouts.length,
                  ),
                  AppWhiteSpace.hMd,
                  if (workouts.isEmpty)
                    const _EmptySavedWorkouts()
                  else
                    for (final item in workouts) ...[
                      _WorkoutChoiceCard(
                        title: item.name,
                        asset: OutlinedSvgAssets.documentText,
                        metadata: [
                          AppStrings.workoutExerciseTotal(item.exerciseCount),
                          if (item.estimatedDurationMinutes case final minutes?)
                            AppStrings.workoutDurationEstimate(minutes),
                        ],
                        onTap: () {
                          onSelectSavedWorkout?.call(item);
                          context.pop();
                        },
                      ),
                      AppWhiteSpace.hSm,
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentHeader extends StatelessWidget {
  const _AssignmentHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.md,
      top: AppSpacing.md,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                AppStrings.assignTemplate,
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AppWhiteSpace.wSm,
            IconButton(
              tooltip: AppStrings.close,
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(
                backgroundColor: context.colorScheme.surfaceContainerLow,
                minimumSize: const Size.square(AppSizing.iconXxl),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.xMark,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hSm,
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Text(
            AppStrings.assignWorkoutHint,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChoiceGroupHeader extends StatelessWidget {
  const _ChoiceGroupHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      AppWhiteSpace.wSm,
      AppBadge(
        label: count.toString(),
        backgroundColor: context.colorScheme.secondaryContainer,
        foregroundColor: context.colorScheme.onSecondaryContainer,
        borderRadius: AppRadius.full,
        textStyle: AppTextStyles.labelSm,
      ),
    ],
  );
}

class _WorkoutChoiceCard extends StatelessWidget {
  const _WorkoutChoiceCard({
    required this.title,
    required this.asset,
    required this.metadata,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String asset;
  final List<String> metadata;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted
        ? context.colorScheme.onSecondary
        : context.colorScheme.onSurface;
    return Material(
      color: highlighted
          ? context.colorScheme.secondary
          : context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: highlighted
            ? BorderSide.none
            : BorderSide(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: AppProgrammeBuilderTokens.managementBorderOpacity,
                ),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: highlighted
                      ? foreground.withValues(
                          alpha: AppProgrammeBuilderTokens.actionIconOpacity,
                        )
                      : context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: SvgPicture.asset(
                  asset,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    highlighted ? foreground : context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppWhiteSpace.wControlGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppWhiteSpace.hXs,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final label in metadata)
                          Text(
                            label,
                            style: AppTextStyles.labelSm.copyWith(
                              color: highlighted
                                  ? foreground
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              AppWhiteSpace.wSm,
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: SvgPicture.asset(
                  OutlinedSvgAssets.arrowRight,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    highlighted ? foreground : context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySavedWorkouts extends StatelessWidget {
  const _EmptySavedWorkouts();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.documentText,
            width: AppSizing.reviewCardIcon,
            height: AppSizing.reviewCardIcon,
            colorFilter: ColorFilter.mode(
              context.colorScheme.secondary,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noSavedWorkoutsToImport,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.noSavedWorkoutsYetHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
