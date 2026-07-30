import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/superset_grouping_policy.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgrammeSupersetEditorSheet extends StatelessWidget {
  const ProgrammeSupersetEditorSheet({
    super.key,
    required this.exercises,
    required this.selectedExerciseIds,
    required this.onToggleSelection,
    required this.onCreateSuperset,
    this.activeGroupId,
    this.onRemoveMember,
    this.onDeleteGroup,
  });

  final List<ProgrammeExerciseDraft> exercises;
  final Set<String> selectedExerciseIds;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onCreateSuperset;
  final String? activeGroupId;
  final ValueChanged<String>? onRemoveMember;
  final VoidCallback? onDeleteGroup;

  @override
  Widget build(BuildContext context) {
    final policy = const SupersetGroupingPolicy();
    final canCreate = policy.canCreateGroup(selectedExerciseIds.length);
    final hasActiveGroup = activeGroupId != null;
    final groupMembers = hasActiveGroup
        ? exercises.where((e) => e.supersetGroupId == activeGroupId).toList()
        : <ProgrammeExerciseDraft>[];

    return AppBottomSheet(
      title: hasActiveGroup
          ? AppStrings.editSuperset
          : AppStrings.createSuperset,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasActiveGroup)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        OutlinedSvgAssets.link,
                        width: AppSizing.iconMd,
                        height: AppSizing.iconMd,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Expanded(
                        child: Text(
                          AppStrings.supersetInvalidSelection,
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasActiveGroup) ...[
              Text(
                AppStrings.groupedExercises,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hSm,
              ...groupMembers.map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppListTile(
                    leadingAsset: OutlinedSvgAssets.link,
                    title: _exerciseLabel(exercise),
                    trailing: onRemoveMember != null
                        ? Tooltip(
                            message: AppStrings.removeFromSuperset,
                            child: AppIconButton(
                              key: ValueKey(
                                'remove_superset_member_${exercise.id}',
                              ),
                              asset: OutlinedSvgAssets.minusCircle,
                              onPressed: () => onRemoveMember!(exercise.id),
                              semanticLabel: AppStrings.removeFromSuperset,
                              color: context.colorScheme.error,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
            AppWhiteSpace.hMd,
            if (!hasActiveGroup && exercises.isEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    AppStrings.noExercisesAdded,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else if (!hasActiveGroup)
              ...exercises.map((exercise) {
                final isSelected = selectedExerciseIds.contains(exercise.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ExerciseSelectionTile(
                    label: _exerciseLabel(exercise),
                    isSelected: isSelected,
                    onTap: () => onToggleSelection(exercise.id),
                  ),
                );
              }),
            AppWhiteSpace.hSm,
            if (!hasActiveGroup)
              FilledButton(
                onPressed: canCreate ? onCreateSuperset : null,
                child: const Text(AppStrings.createSuperset),
              ),
            if (hasActiveGroup && onDeleteGroup != null)
              OutlinedButton(
                onPressed: onDeleteGroup,
                child: Text(
                  AppStrings.deleteSuperset,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _exerciseLabel(ProgrammeExerciseDraft exercise) {
    return exercise.exerciseRef ??
        AppStrings.exerciseNumberLabel(exercise.exerciseId);
  }
}

class _ExerciseSelectionTile extends StatelessWidget {
  const _ExerciseSelectionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.iconXxl),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.secondaryContainer
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (isSelected)
                    SvgPicture.asset(
                      OutlinedSvgAssets.checkCircle,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSecondaryContainer,
                        BlendMode.srcIn,
                      ),
                    )
                  else
                    Container(
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.outline,
                          width: AppSizing.strokeWidth,
                        ),
                      ),
                    ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isSelected
                            ? context.colorScheme.onSecondaryContainer
                            : context.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
