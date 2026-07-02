import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_actions_menu.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/superset_group_badge.dart';
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
  });

  final ProgrammeBuilderWorkoutSlotDraft slot;
  final VoidCallback onAssignTemplate;
  final VoidCallback onRemove;
  final int? weekIndex;
  final int? slotIndex;
  final VoidCallback? onOpenSupersetEditor;

  @override
  Widget build(BuildContext context) {
    final hasTemplate = slot.template != null;
    final hasExercises = hasTemplate && slot.template!.exercises.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.sparkles,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasTemplate
                              ? slot.template!.name
                              : AppStrings.weekTemplateEmpty,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      if (hasExercises && onOpenSupersetEditor != null)
                        SupersetActionsMenu(
                          isGrouped: slot.template!.exercises.any(
                            (e) => e.supersetGroupId != null,
                          ),
                          onCreateSuperset: onOpenSupersetEditor!,
                          onRemoveFromSuperset: onOpenSupersetEditor!,
                          onDeleteSuperset: onOpenSupersetEditor!,
                        ),
                    ],
                  ),
                  Text(
                    slot.scheduledDay?.displayLabel ??
                        '${AppStrings.onboardingDaySingle} ${slot.scheduledDayIndex + 1}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasTemplate && slot.template!.description != null)
                    Text(
                      slot.template!.description!,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (hasExercises)
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: slot.template!.exercises.map((ex) {
                        final isGrouped = ex.supersetGroupId != null;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGrouped && ex.supersetOrder != null)
                              SupersetGroupBadge(
                                groupId: ex.supersetGroupId!,
                                order: ex.supersetOrder,
                              ),
                            if (isGrouped && ex.supersetOrder != null)
                              const SizedBox(width: AppSpacing.xxs),
                            Text(
                              ex.exerciseRef ?? 'Exercise ${ex.exerciseId}',
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowsRightLeft,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              onPressed: onAssignTemplate,
              tooltip: AppStrings.assignTemplate,
            ),
            IconButton(
              icon: SvgPicture.asset(
                OutlinedSvgAssets.xMark,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onRemove,
              tooltip: AppStrings.removeSlot,
            ),
          ],
        ),
      ),
    );
  }
}
