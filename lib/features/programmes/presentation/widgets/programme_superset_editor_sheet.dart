import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/superset_grouping_policy.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
    final editing = activeGroupId != null;
    final selected = selectedExerciseIds
        .where((id) => exercises.any((exercise) => exercise.id == id))
        .toList();
    final members =
        exercises
            .where((exercise) => exercise.supersetGroupId == activeGroupId)
            .toList()
          ..sort(
            (a, b) => (a.supersetOrder ?? a.sortOrder).compareTo(
              b.supersetOrder ?? b.sortOrder,
            ),
          );
    final visibleExercises = editing ? members : exercises;
    final canCreate = const SupersetGroupingPolicy().canCreateGroup(
      selected.length,
    );

    return AppBottomSheet(
      heightFactor: AppProgrammeBuilderTokens.supersetSheetHeightFactor,
      showCloseButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SupersetHeader(editing: editing),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('programme_superset_exercises'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SupersetHint(),
                  AppWhiteSpace.hLg,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing
                              ? AppStrings.groupedExercises
                              : AppStrings.supersetChooseExercises,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      AppBadge(
                        label: visibleExercises.length.toString(),
                        borderRadius: AppRadius.full,
                        backgroundColor:
                            context.colorScheme.surfaceContainerHigh,
                        foregroundColor: context.colorScheme.onSurfaceVariant,
                        textStyle: AppTextStyles.labelSm,
                      ),
                    ],
                  ),
                  AppWhiteSpace.hSm,
                  Text(
                    editing
                        ? AppStrings.executionOrder
                        : AppStrings.supersetSelectionOrderHint,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppWhiteSpace.hMd,
                  if (visibleExercises.isEmpty)
                    const _EmptyExercises()
                  else
                    for (var i = 0; i < visibleExercises.length; i++) ...[
                      _SupersetExerciseRow(
                        key: ValueKey(
                          'superset_exercise_${visibleExercises[i].id}',
                        ),
                        exercise: visibleExercises[i],
                        order: editing
                            ? i + 1
                            : selected.indexOf(visibleExercises[i].id) + 1,
                        editing: editing,
                        onSelect: () =>
                            onToggleSelection(visibleExercises[i].id),
                        onRemove: onRemoveMember == null
                            ? null
                            : () => onRemoveMember!(visibleExercises[i].id),
                      ),
                      if (i < visibleExercises.length - 1) AppWhiteSpace.hSm,
                    ],
                ],
              ),
            ),
          ),
          _SupersetActions(
            editing: editing,
            selectedCount: selected.length,
            onCreate: canCreate ? onCreateSuperset : null,
            onDelete: onDeleteGroup,
          ),
        ],
      ),
    );
  }
}

class _SupersetHeader extends StatelessWidget {
  const _SupersetHeader({required this.editing});

  final bool editing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.md,
      top: AppSpacing.md,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              editing ? AppStrings.editSuperset : AppStrings.createSuperset,
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
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
  );
}

class _SupersetHint extends StatelessWidget {
  const _SupersetHint();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
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
          AppWhiteSpace.wControlGap,
          Expanded(
            child: Text(
              AppStrings.supersetRunnerHint,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SupersetExerciseRow extends StatelessWidget {
  const _SupersetExerciseRow({
    super.key,
    required this.exercise,
    required this.order,
    required this.editing,
    required this.onSelect,
    this.onRemove,
  });

  final ProgrammeExerciseDraft exercise;
  final int order;
  final bool editing;
  final VoidCallback onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = order > 0;
    final label =
        exercise.exerciseRef ??
        AppStrings.exerciseNumberLabel(exercise.exerciseId);
    return Semantics(
      selected: editing ? null : selected,
      button: !editing,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppDurations.navigationSelection,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  context.colorScheme.secondary.withValues(
                    alpha: AppProgrammeBuilderTokens.highlightOpacity,
                  ),
                  context.colorScheme.surfaceContainerLowest,
                )
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: editing ? null : onSelect,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.controlGap,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Semantics(
                    label: selected
                        ? AppStrings.supersetOrderPosition(order)
                        : null,
                    excludeSemantics: true,
                    child: Container(
                      width: AppSizing.reviewCardIcon,
                      height: AppSizing.reviewCardIcon,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? context.colorScheme.secondary
                            : context.colorScheme.surfaceContainerLow,
                      ),
                      child: selected
                          ? Text(
                              order.toString(),
                              style: AppTextStyles.labelMd.copyWith(
                                color: context.colorScheme.onSecondary,
                              ),
                            )
                          : SvgPicture.asset(
                              OutlinedSvgAssets.link,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              colorFilter: ColorFilter.mode(
                                context.colorScheme.onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                  AppWhiteSpace.wControlGap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppWhiteSpace.hXs,
                        Text(
                          AppStrings.programmeSetCount(exercise.sets.length),
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  if (editing && onRemove != null)
                    IconButton(
                      key: ValueKey('remove_superset_member_${exercise.id}'),
                      tooltip: AppStrings.removeFromSuperset,
                      onPressed: onRemove,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colorScheme.error,
                        minimumSize: const Size.square(AppSizing.iconXxl),
                      ),
                      icon: SvgPicture.asset(
                        OutlinedSvgAssets.minusCircle,
                        width: AppSizing.iconMd,
                        height: AppSizing.iconMd,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.error,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  else if (!editing)
                    ExcludeSemantics(
                      child: selected
                          ? SvgPicture.asset(
                              OutlinedSvgAssets.checkCircle,
                              width: AppSizing.iconMd,
                              height: AppSizing.iconMd,
                              colorFilter: ColorFilter.mode(
                                context.colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            )
                          : Container(
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

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Text(
      AppStrings.noExercisesAdded,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMd.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _SupersetActions extends StatelessWidget {
  const _SupersetActions({
    required this.editing,
    required this.selectedCount,
    this.onCreate,
    this.onDelete,
  });

  final bool editing;
  final int selectedCount;
  final VoidCallback? onCreate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colorScheme.surfaceContainerLow,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: !editing,
              child: Text(
                editing
                    ? AppStrings.supersetDeleteHint
                    : AppStrings.supersetSelectedCount(selectedCount),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (!editing && onCreate == null) ...[
              AppWhiteSpace.hXs,
              Text(
                AppStrings.supersetInvalidSelection,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            AppWhiteSpace.hMd,
            if (editing && onDelete != null)
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.error,
                  minimumSize: const Size(0, AppSizing.iconXxl),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.buttonVertical,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: AppTextStyles.labelMd,
                ),
                child: const Text(AppStrings.deleteSuperset),
              )
            else if (!editing)
              FilledButton(
                key: const ValueKey('programme_create_superset'),
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  minimumSize: const Size(0, AppSizing.iconXxl),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.buttonVertical,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: AppTextStyles.labelMd,
                ),
                child: const Text(AppStrings.createSuperset),
              ),
          ],
        ),
      ),
    ),
  );
}
