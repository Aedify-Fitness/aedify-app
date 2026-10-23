import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/application/programme_exercise_config_adapter.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/workout_exercise_config_panel.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_section.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_management_section.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Day-specific workout editor for the fourth programme builder stage.
class ProgrammeBuilderWorkouts extends StatefulWidget {
  const ProgrammeBuilderWorkouts({
    super.key,
    required this.weeks,
    this.blockLabel,
    required this.weekIndex,
    required this.onWeekChanged,
    required this.controller,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onAssignTemplate,
    this.onRepeatTemplate,
    this.repeatedSlotIndices = const {},
    required this.onAddExercises,
    required this.onEditSuperset,
    required this.weekManagement,
    this.enabled = true,
    this.selection,
  });

  final List<ProgrammeBuilderWeekDraft> weeks;
  final String? blockLabel;
  final int weekIndex;
  final ValueChanged<int> onWeekChanged;
  final ProgrammeBuilderController controller;
  final VoidCallback onAddDay;
  final void Function(int weekIndex, int slotIndex) onRemoveDay;
  final void Function(int weekIndex, int slotIndex) onAssignTemplate;
  final void Function(int weekIndex, int slotIndex)? onRepeatTemplate;
  final Set<int> repeatedSlotIndices;
  final ValueChanged<String> onAddExercises;
  final void Function(int weekIndex, int slotIndex) onEditSuperset;
  final Widget weekManagement;
  final bool enabled;
  final ({String templateId, String exerciseId, int revision})? selection;

  @override
  State<ProgrammeBuilderWorkouts> createState() =>
      _ProgrammeBuilderWorkoutsState();
}

class _ProgrammeBuilderWorkoutsState extends State<ProgrammeBuilderWorkouts> {
  final _configurationAnchor = GlobalKey();
  final _dayTabsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _prepareAssignments();
  }

  @override
  void dispose() {
    _dayTabsController.dispose();
    super.dispose();
  }

  void _addDay() {
    widget.onAddDay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _dayTabsController.hasClients) {
        _dayTabsController.animateTo(
          _dayTabsController.position.maxScrollExtent,
          duration: AppDurations.navigationSelection,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeDay(int slotIndex, {required bool selected}) {
    if (selected) {
      setState(() {
        _templateId = null;
        _exerciseId = null;
        _reordering = false;
      });
    }
    widget.onRemoveDay(widget.weekIndex, slotIndex);
  }

  @override
  void reassemble() {
    super.reassemble();
    _prepareAssignments();
  }

  void _prepareAssignments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.ensureIndependentAssignments();
    });
  }

  @override
  void didUpdateWidget(ProgrammeBuilderWorkouts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weekIndex != oldWidget.weekIndex) {
      _templateId = null;
      _exerciseId = null;
      _reordering = false;
    }
    if (widget.selection != null && widget.selection != oldWidget.selection) {
      _templateId = widget.selection!.templateId;
      _exerciseId = widget.selection!.exerciseId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = _configurationAnchor.currentContext;
        if (target != null) Scrollable.ensureVisible(target);
      });
    }
  }

  String? _templateId;
  String? _exerciseId;
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    final week = widget.weeks.isEmpty ? null : widget.weeks[widget.weekIndex];
    final slots = week?.slots ?? [];
    final templates = <String, ProgrammeBuilderTemplateDraft>{
      for (final slot in slots)
        if (slot.template != null) slot.template!.id: slot.template!,
    };
    final locations = <String, int>{
      for (var i = 0; i < slots.length; i++)
        if (slots[i].template != null) slots[i].template!.id: i,
    };
    final template = templates[_templateId] ?? templates.values.firstOrNull;
    final exercise =
        template?.exercises
            .where((item) => item.id == _exerciseId)
            .firstOrNull ??
        template?.exercises.firstOrNull;

    return Column(
      key: const ValueKey('programme_define_workouts'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row(
        //   children: [
        //     Expanded(
        //       child: Text(
        //         AppStrings.defineWorkouts,
        //         style: AppTextStyles.headlineLgMobile.copyWith(
        //           color: context.colorScheme.onSurface,
        //         ),
        //       ),
        //     ),
        //     AppWhiteSpace.wSm,
        //     AppBadge(
        //       label: AppStrings.programmeWorkoutCount(slots.length),
        //       backgroundColor: context.colorScheme.secondaryContainer,
        //       foregroundColor: context.colorScheme.onSecondaryContainer,
        //       borderRadius: AppRadius.full,
        //       textStyle: AppTextStyles.labelSm,
        //     ),
        //   ],
        // ),
        // AppWhiteSpace.hSm,
        // Text(
        //   AppStrings.programmeDayWorkoutsHint,
        //   style: AppTextStyles.bodyLg.copyWith(
        //     color: context.colorScheme.onSurfaceVariant,
        //   ),
        // ),
        // AppWhiteSpace.hMd,
        if (widget.blockLabel != null) ...[
          Text(
            widget.blockLabel!,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.secondary,
            ),
          ),
          AppWhiteSpace.hMd,
        ],
        if (widget.weeks.length > 1) ...[
          DropdownButtonFormField<int>(
            key: ValueKey('programme_workouts_week_${widget.weekIndex}'),
            initialValue: widget.weekIndex,
            isExpanded: true,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
            icon: SvgPicture.asset(
              OutlinedSvgAssets.chevronDown,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            items: [
              for (var i = 0; i < widget.weeks.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    AppStrings.programmeWeekLabel(widget.weeks[i].weekNumber),
                  ),
                ),
            ],
            onChanged: widget.enabled
                ? (index) {
                    if (index != null) widget.onWeekChanged(index);
                  }
                : null,
          ),
          AppWhiteSpace.hLg,
        ],
        SingleChildScrollView(
          controller: _dayTabsController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                KeyedSubtree(
                  key: ValueKey('programme_workout_day_${week!.id}_$i'),
                  child: _TemplateTab(
                    key: slots[i].template == null
                        ? ValueKey('programme_unassigned_${week.id}_$i')
                        : ValueKey(
                            'programme_template_${slots[i].template!.id}',
                          ),
                    label: AppStrings.programmeDayTemplate(
                      (slots[i].scheduledDay ??
                              TrainingDay.values[slots[i].scheduledDayIndex %
                                  TrainingDay.values.length])
                          .fullDisplayLabel,
                      slots[i].template?.name ??
                          AppStrings.selectWorkoutTemplate,
                    ),
                    selected:
                        slots[i].template != null &&
                        slots[i].template!.id == template?.id,
                    removeLabel: AppStrings.removeWorkoutDay(
                      (slots[i].scheduledDay ??
                              TrainingDay.values[slots[i].scheduledDayIndex %
                                  TrainingDay.values.length])
                          .fullDisplayLabel,
                    ),
                    onRemove: widget.enabled
                        ? () => _removeDay(
                            i,
                            selected: slots[i].template?.id == template?.id,
                          )
                        : null,
                    onTap: !widget.enabled
                        ? null
                        : () {
                            final assigned = slots[i].template;
                            if (assigned == null) {
                              widget.onAssignTemplate(widget.weekIndex, i);
                            } else {
                              setState(() {
                                _templateId = assigned.id;
                                _exerciseId = null;
                                _reordering = false;
                              });
                            }
                          },
                  ),
                ),
                AppWhiteSpace.wSm,
              ],
              _DashedAction(
                label: AppStrings.addWorkoutSlot,
                onTap:
                    widget.enabled &&
                        slots
                                .map((slot) => slot.scheduledDayIndex)
                                .toSet()
                                .length <
                            TrainingDay.values.length
                    ? _addDay
                    : null,
                compact: true,
              ),
            ],
          ),
        ),
        if (template != null &&
            widget.onRepeatTemplate != null &&
            !widget.repeatedSlotIndices.contains(locations[template.id])) ...[
          AppWhiteSpace.hSm,
          TextButton(
            key: const ValueKey('programme_repeat_selected_workout'),
            onPressed: widget.enabled
                ? () => widget.onRepeatTemplate!(
                    widget.weekIndex,
                    locations[template.id]!,
                  )
                : null,
            child: const Text(AppStrings.programmeRepeatInBlock),
          ),
          Text(
            AppStrings.programmeRepeatCopiesHint,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        AppWhiteSpace.hXl,
        if (template == null)
          ProgrammeBuilderPanel(
            padding: AppSpacing.lg,
            child: Text(
              AppStrings.programmeWorkoutTemplatesHint,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Builder(
            builder: (context) {
              final list = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.programmeExerciseCount(
                            template.exercises.length,
                          ).toUpperCase(),
                          style: AppTextStyles.labelMd,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            template.exercises.length > 1 && widget.enabled
                            ? () => setState(() => _reordering = !_reordering)
                            : null,
                        child: Text(
                          _reordering
                              ? AppStrings.done
                              : AppStrings.reorderButton,
                        ),
                      ),
                    ],
                  ),
                  AppWhiteSpace.hSm,
                  for (var i = 0; i < template.exercises.length; i++) ...[
                    _ExerciseCard(
                      key: ValueKey(
                        'programme_exercise_${template.exercises[i].id}',
                      ),
                      exercise: template.exercises[i],
                      selected: exercise?.id == template.exercises[i].id,
                      onTap: widget.enabled
                          ? () => setState(
                              () => _exerciseId = template.exercises[i].id,
                            )
                          : null,
                      onUp: _reordering && i > 0
                          ? () => widget.controller.reorderTemplateExercises(
                              template.id,
                              i,
                              i - 1,
                            )
                          : null,
                      onDown: _reordering && i < template.exercises.length - 1
                          ? () => widget.controller.reorderTemplateExercises(
                              template.id,
                              i,
                              i + 2,
                            )
                          : null,
                      reordering: _reordering,
                    ),
                    AppWhiteSpace.hMd,
                  ],
                  if (template.exercises.isEmpty) ...[
                    Text(
                      AppStrings.addExercisesToGetStarted,
                      style: AppTextStyles.bodyMd,
                    ),
                    AppWhiteSpace.hMd,
                  ],
                  _DashedAction(
                    label: AppStrings.addExercise,
                    onTap: widget.enabled
                        ? () => widget.onAddExercises(template.id)
                        : null,
                  ),
                  AppWhiteSpace.hSm,
                  TextButton.icon(
                    onPressed: template.exercises.length > 1 && widget.enabled
                        ? () {
                            final location = locations[template.id]!;
                            widget.onEditSuperset(widget.weekIndex, location);
                          }
                        : null,
                    icon: const _WorkoutIcon(asset: OutlinedSvgAssets.link),
                    label: const Text(AppStrings.supersets),
                  ),
                ],
              );
              final config = exercise == null
                  ? const ProgrammeBuilderPanel(
                      child: Text(AppStrings.selectExerciseToConfigure),
                    )
                  : _ExerciseConfiguration(
                      key: ValueKey('programme_config_${exercise.id}'),
                      exercise: exercise,
                      enabled: widget.enabled,
                      onChanged: (updated) => widget.controller
                          .updateTemplateExercise(template.id, updated),
                      onRemove: () => widget.controller.removeTemplateExercise(
                        template.id,
                        exercise.id,
                      ),
                      onAddSet: () => widget.controller.addTemplateSet(
                        template.id,
                        exercise.id,
                      ),
                      onRemoveSet: (setId) => widget.controller
                          .removeTemplateSet(template.id, exercise.id, setId),
                    );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  list,
                  AppWhiteSpace.hLg,
                  KeyedSubtree(key: _configurationAnchor, child: config),
                ],
              );
            },
          ),
        AppWhiteSpace.hXl,
        ProgrammeWeekManagementSection(child: widget.weekManagement),
      ],
    );
  }
}

class _TemplateTab extends StatelessWidget {
  const _TemplateTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.removeLabel,
    required this.onRemove,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? context.colorScheme.onSecondary
        : context.colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondary
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                minimumSize: const Size(0, AppSizing.iconXxl),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.formChipVertical,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
              ),
              child: Text(label, style: AppTextStyles.labelMd),
            ),
            IconButton(
              tooltip: removeLabel,
              onPressed: onRemove,
              style: IconButton.styleFrom(
                foregroundColor: foreground,
                minimumSize: const Size.square(AppSizing.iconXxs),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.xMark,
                width: AppSizing.iconXxs,
                height: AppSizing.iconXxs,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.selected,
    required this.onTap,
    required this.reordering,
    this.onUp,
    this.onDown,
  });
  final ProgrammeExerciseDraft exercise;
  final bool selected;
  final VoidCallback? onTap;
  final bool reordering;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref
        .watch(
          AppProviders.exerciseDetailControllerProvider(exercise.exerciseId),
        )
        .asData
        ?.value;
    final name =
        details?.name ??
        exercise.exerciseRef ??
        AppStrings.exerciseNumberLabel(exercise.exerciseId);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: context.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (details?.primaryMuscles.isNotEmpty ?? false) ...[
                  AppWhiteSpace.hXs,
                  AppBadge(
                    label: details!.primaryMuscles.first.toUpperCase(),
                    backgroundColor: context.colorScheme.surfaceContainerLow,
                    foregroundColor: context.colorScheme.onSurfaceVariant,
                    borderRadius: AppRadius.sm,
                  ),
                ],
                AppWhiteSpace.hControlGap,
                Row(
                  children: [
                    _WorkoutIcon(
                      asset: OutlinedSvgAssets.queueList,
                      color: selected
                          ? context.colorScheme.secondary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    AppWhiteSpace.wSm,
                    Expanded(
                      child: Text(
                        AppStrings.programmeSetCount(exercise.sets.length),
                        style: AppTextStyles.labelSm.copyWith(
                          color: selected
                              ? context.colorScheme.secondary
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (exercise.supersetGroupId != null)
                      const AppBadge(label: AppStrings.superset),
                  ],
                ),
                if (reordering)
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: AppSpacing.baseUnit),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppIconButton(
                          asset: OutlinedSvgAssets.arrowUp,
                          onPressed: onUp,
                          semanticLabel: AppStrings.moveExerciseUp,
                          iconSize: AppSizing.iconS,
                        ),
                        AppIconButton(
                          asset: OutlinedSvgAssets.arrowDown,
                          onPressed: onDown,
                          semanticLabel: AppStrings.moveExerciseDown,
                          iconSize: AppSizing.iconS,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseConfiguration extends ConsumerWidget {
  const _ExerciseConfiguration({
    super.key,
    required this.exercise,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
    required this.onAddSet,
    required this.onRemoveSet,
  });
  final ProgrammeExerciseDraft exercise;
  final bool enabled;
  final ValueChanged<ProgrammeExerciseDraft> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onAddSet;
  final ValueChanged<String> onRemoveSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref
        .watch(
          AppProviders.exerciseDetailControllerProvider(exercise.exerciseId),
        )
        .asData
        ?.value;
    return ExcludeFocus(
      excluding: !enabled,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: WorkoutExerciseConfigPanel(
          selectedExercise: ProgrammeExerciseConfigAdapter.toEditor(
            exercise,
            details,
          ),
          setTypeOptions: ref
              .read(AppProviders.setTypeOptionsUseCaseProvider)
              .execute(),
          onAddSet: (_) => onAddSet(),
          onRemoveSet: (_, setId) => onRemoveSet(setId),
          onUpdateSet: (_, setId, edited) => onChanged(
            exercise.copyWith(
              sets: [
                for (final original in exercise.sets)
                  original.id == setId
                      ? ProgrammeExerciseConfigAdapter.applyEdit(
                          original,
                          edited,
                        )
                      : original,
              ],
            ),
          ),
          onUpdateNotes: (_, notes) =>
              onChanged(exercise.copyWith(notes: notes ?? '')),
          onDeleteExercise: (_) => onRemove(),
        ),
      ),
    );
  }
}

class _DashedAction extends StatelessWidget {
  const _DashedAction({
    required this.label,
    required this.onTap,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: compact ? label : null,
    button: true,
    child: CustomPaint(
      painter: DashedBorderPainter(
        color: context.colorScheme.outlineVariant,
        strokeWidth: AppSizing.strokeWidth,
        dashWidth: AppSpacing.xs,
        gapWidth: AppSpacing.xs,
        borderRadius: AppRadius.md,
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _WorkoutIcon(
              asset: OutlinedSvgAssets.plus,
              color: context.colorScheme.secondary,
            ),
            if (!compact) ...[
              AppWhiteSpace.wSm,
              Flexible(child: Text(label, style: AppTextStyles.labelMd)),
            ],
          ],
        ),
      ),
    ),
  );
}

class _WorkoutIcon extends StatelessWidget {
  const _WorkoutIcon({required this.asset, this.color});
  final String asset;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: AppSizing.iconS,
    height: AppSizing.iconS,
    colorFilter: ColorFilter.mode(
      color ?? context.colorScheme.onSurfaceVariant,
      BlendMode.srcIn,
    ),
  );
}
