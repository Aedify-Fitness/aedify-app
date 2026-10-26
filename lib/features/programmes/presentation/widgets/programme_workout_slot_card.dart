import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.onAddExercises,
    this.onEditExercise,
  });
  final ProgrammeBuilderWorkoutSlotDraft slot;
  final VoidCallback onAssignTemplate;
  final VoidCallback onRemove;
  final int? weekIndex;
  final int? slotIndex;
  final VoidCallback? onOpenSupersetEditor;
  final VoidCallback? onChangeDay;
  final VoidCallback? onAddExercises;
  final ValueChanged<String>? onEditExercise;

  @override
  Widget build(BuildContext context) {
    final template = slot.template;
    final day =
        slot.scheduledDay?.fullDisplayLabel ??
        '${AppStrings.onboardingDaySingle} ${slot.scheduledDayIndex + 1}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        key: ValueKey('programme_week_workout_${weekIndex}_$slotIndex'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: AppProgrammeBuilderTokens.managementBorderOpacity,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizing.iconXxl,
                  height: AppSizing.iconXxl,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: _CardIcon(
                    asset: OutlinedSvgAssets.materialBolt,
                    color: context.colorScheme.secondary,
                  ),
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template?.name ?? AppStrings.weekTemplateEmpty,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      AppWhiteSpace.hXs,
                      Text(
                        [
                          AppStrings.workoutExerciseTotal(
                            template?.exercises.length ?? 0,
                          ),
                          if (template?.estimatedDurationMinutes != null)
                            AppStrings.workoutDurationEstimate(
                              template!.estimatedDurationMinutes!,
                            ),
                        ].join(' • '),
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: AppStrings.workoutOptions,
                  icon: _CardIcon(
                    asset: OutlinedSvgAssets.ellipsisVertical,
                    color: context.colorScheme.outline,
                  ),
                  onSelected: (action) {
                    if (action == AppStrings.assignTemplate) onAssignTemplate();
                    if (action == AppStrings.removeSlot) onRemove();
                    if (action == AppStrings.selectDay) onChangeDay?.call();
                    if (action == AppStrings.supersets) {
                      onOpenSupersetEditor?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: AppStrings.assignTemplate,
                      child: Text(AppStrings.assignTemplate),
                    ),
                    if (onChangeDay != null)
                      const PopupMenuItem(
                        value: AppStrings.selectDay,
                        child: Text(AppStrings.selectDay),
                      ),
                    if (template?.exercises.isNotEmpty == true &&
                        onOpenSupersetEditor != null)
                      const PopupMenuItem(
                        value: AppStrings.supersets,
                        child: Text(AppStrings.supersets),
                      ),
                    const PopupMenuItem(
                      value: AppStrings.removeSlot,
                      child: Text(AppStrings.removeSlot),
                    ),
                  ],
                ),
              ],
            ),
            AppWhiteSpace.hSm,
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onChangeDay,
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.onSurface,
                  disabledForegroundColor: context.colorScheme.onSurface,
                ),
                icon: const _CardIcon(asset: OutlinedSvgAssets.calendarDays),
                label: Text(day, style: AppTextStyles.labelSm),
              ),
            ),
            if (template != null) ...[
              AppWhiteSpace.hMd,
              for (final exercise in template.exercises) ...[
                _WorkoutExerciseRow(
                  exercise: exercise,
                  onEdit: onEditExercise == null
                      ? null
                      : () => onEditExercise!(exercise.id),
                ),
                AppWhiteSpace.hMd,
              ],
              if (template.exercises.isEmpty) ...[
                const Text(
                  AppStrings.noExercisesAddedHint,
                  style: AppTextStyles.bodyMd,
                ),
                AppWhiteSpace.hMd,
              ],
              CustomPaint(
                painter: DashedBorderPainter(
                  color: context.colorScheme.outlineVariant,
                  strokeWidth: AppSizing.strokeWidth,
                  dashWidth: AppSpacing.xs,
                  gapWidth: AppSpacing.xs,
                  borderRadius: AppRadius.defaultRadius,
                ),
                child: TextButton.icon(
                  onPressed: onAddExercises,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.buttonVertical,
                    ),
                  ),
                  icon: const _CardIcon(asset: OutlinedSvgAssets.plus),
                  label: const Text(
                    AppStrings.addExercise,
                    style: AppTextStyles.labelMd,
                  ),
                ),
              ),
            ] else ...[
              AppWhiteSpace.hMd,
              OutlinedButton(
                onPressed: onAssignTemplate,
                child: const Text(AppStrings.assignTemplate),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutExerciseRow extends ConsumerWidget {
  const _WorkoutExerciseRow({required this.exercise, required this.onEdit});
  final ProgrammeExerciseDraft exercise;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref
        .watch(
          AppProviders.exerciseDetailControllerProvider(exercise.exerciseId),
        )
        .asData
        ?.value;
    final set =
        exercise.sets
            .where((set) => set.setType == SetType.working)
            .firstOrNull ??
        exercise.sets.firstOrNull;
    final reps =
        set?.prescribedRepsExact?.toString() ??
        (set?.prescribedRepsMin == null
            ? null
            : set?.prescribedRepsMax == null
            ? '${set!.prescribedRepsMin}'
            : '${set!.prescribedRepsMin}-${set.prescribedRepsMax}');
    final rpe = set?.prescribedRpeMin == null
        ? null
        : set?.prescribedRpeMax == null ||
              set?.prescribedRpeMax == set?.prescribedRpeMin
        ? '${set!.prescribedRpeMin}'
        : '${set!.prescribedRpeMin}-${set.prescribedRpeMax}';
    final summaries = [
      AppStrings.programmeSetCount(exercise.sets.length),
      if (reps != null) AppStrings.exerciseRepsSummary(reps),
      if (rpe != null) AppStrings.exerciseRpeSummary(rpe),
      if (set?.restSeconds != null)
        AppStrings.exerciseRestSummary(set!.restSeconds!),
    ];
    return Container(
      key: ValueKey('programme_week_exercise_${exercise.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppProgrammeBuilderTokens.managementDividerOpacity,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppProgrammeBuilderTokens.assignmentExerciseIconSize,
            height: AppProgrammeBuilderTokens.assignmentExerciseIconSize,
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: _CardIcon(
              asset: OutlinedSvgAssets.materialFitnessCenter,
              color: context.colorScheme.onSecondaryFixedVariant,
            ),
          ),
          AppWhiteSpace.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail?.name ??
                      exercise.exerciseRef ??
                      AppStrings.exerciseNumberLabel(exercise.exerciseId),
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hXs,
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final summary in summaries)
                      Text(
                        summary,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (exercise.supersetGroupId != null) ...[
                      const AppBadge(label: AppStrings.superset),
                    ],
                    if (onEdit != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppIconButton(
                          asset: OutlinedSvgAssets.pencil,
                          onPressed: onEdit,
                          semanticLabel: AppStrings.editExercise,
                          color: context.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.asset, this.color});
  final String asset;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: AppSizing.iconSm,
    height: AppSizing.iconSm,
    colorFilter: ColorFilter.mode(
      color ?? context.colorScheme.onSurfaceVariant,
      BlendMode.srcIn,
    ),
  );
}
