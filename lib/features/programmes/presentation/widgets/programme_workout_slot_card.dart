import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_actions_menu.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_group_badge.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWorkoutSlotCard extends StatelessWidget {
  const ProgrammeWorkoutSlotCard({
    super.key,
    required this.slot,
    required this.onAssignTemplate,
    required this.onRemove,
    this.weekIndex,
    this.slotIndex,
    this.onOpenSupersetEditor,
    this.onChangeDay,
  });

  final ProgrammeBuilderWorkoutSlotDraft slot;
  final VoidCallback onAssignTemplate;
  final VoidCallback onRemove;
  final int? weekIndex;
  final int? slotIndex;
  final VoidCallback? onOpenSupersetEditor;
  final VoidCallback? onChangeDay;

  @override
  Widget build(BuildContext context) {
    final hasTemplate = slot.template != null;
    final hasExercises = hasTemplate && slot.template!.exercises.isNotEmpty;
    final exerciseCount = slot.template?.exercises.length ?? 0;
    final dayLabel =
        slot.scheduledDay?.fullDisplayLabel ??
        '${AppStrings.onboardingDaySingle} ${slot.scheduledDayIndex + 1}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSizing.iconXxl,
                    height: AppSizing.iconXxl,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      hasTemplate
                          ? OutlinedSvgAssets.clipboardDocumentCheck
                          : OutlinedSvgAssets.clipboardDocument,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        hasTemplate
                            ? context.colorScheme.secondary
                            : context.colorScheme.onSurfaceVariant,
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
                          hasTemplate
                              ? slot.template!.name
                              : AppStrings.weekTemplateEmpty,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppWhiteSpace.hXs,
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            AppBadge(
                              label:
                                  '$exerciseCount ${AppStrings.exercisesCompleted}',
                              backgroundColor:
                                  context.colorScheme.surfaceContainerHigh,
                              foregroundColor:
                                  context.colorScheme.onSurfaceVariant,
                              borderRadius: AppRadius.full,
                            ),
                            AppBadge(
                              label: hasTemplate
                                  ? AppStrings.onboardingReviewConfigured
                                  : AppStrings.onboardingReviewNotConfigured,
                              backgroundColor: hasTemplate
                                  ? context.colorScheme.secondaryContainer
                                  : context.colorScheme.surfaceContainerHigh,
                              foregroundColor: hasTemplate
                                  ? context.colorScheme.onSecondaryContainer
                                  : context.colorScheme.onSurfaceVariant,
                              borderRadius: AppRadius.full,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hMd,
              _DaySelector(label: dayLabel, onTap: onChangeDay),
              if (hasTemplate &&
                  slot.template!.description?.trim().isNotEmpty == true) ...[
                AppWhiteSpace.hMd,
                Text(
                  slot.template!.description!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasExercises) ...[
                AppWhiteSpace.hMd,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: slot.template!.exercises.map((exercise) {
                        final isGrouped =
                            exercise.supersetGroupId != null &&
                            exercise.supersetOrder != null;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGrouped) ...[
                              SupersetGroupBadge(
                                groupId: exercise.supersetGroupId!,
                                order: exercise.supersetOrder,
                              ),
                              AppWhiteSpace.wXs,
                            ],
                            Text(
                              exercise.exerciseRef ??
                                  AppStrings.exerciseNumberLabel(
                                    exercise.exerciseId,
                                  ),
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
              AppWhiteSpace.hMd,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Tooltip(
                    message: AppStrings.assignTemplate,
                    child: OutlinedButton.icon(
                      onPressed: onAssignTemplate,
                      icon: SvgPicture.asset(
                        OutlinedSvgAssets.arrowsRightLeft,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(AppStrings.assignTemplate),
                    ),
                  ),
                  if (hasExercises && onOpenSupersetEditor != null)
                    SupersetActionsMenu(
                      isGrouped: slot.template!.exercises.any(
                        (exercise) => exercise.supersetGroupId != null,
                      ),
                      onCreateSuperset: onOpenSupersetEditor!,
                      onRemoveFromSuperset: onOpenSupersetEditor!,
                      onDeleteSuperset: onOpenSupersetEditor!,
                    ),
                  Tooltip(
                    message: AppStrings.removeSlot,
                    child: AppIconButton(
                      asset: OutlinedSvgAssets.trash,
                      onPressed: onRemove,
                      semanticLabel: AppStrings.removeSlot,
                      color: context.colorScheme.error,
                      backgroundColor: context.colorScheme.errorContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.calendarDays,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    AppWhiteSpace.wSm,
                    SvgPicture.asset(
                      OutlinedSvgAssets.chevronDown,
                      width: AppSizing.iconXs,
                      height: AppSizing.iconXs,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
