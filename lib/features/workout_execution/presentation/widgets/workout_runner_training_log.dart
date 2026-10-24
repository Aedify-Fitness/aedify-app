import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A compact set table that adapts to larger text and narrow phones.
class WorkoutRunnerTrainingLog extends StatefulWidget {
  const WorkoutRunnerTrainingLog({
    super.key,
    required this.block,
    required this.activeSet,
    required this.enabled,
    required this.canLogSet,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onLogSet,
    required this.onAddSet,
    required this.onAddNote,
    required this.onShowExercise,
    this.onToggleSkipped,
  });

  final WorkoutRunnerBlock block;
  final WorkoutRunnerSetItem? activeSet;
  final bool enabled;
  final bool canLogSet;
  final void Function(String, WorkoutRunnerSetItem) onUpdateSet;
  final void Function(String, WorkoutRunnerSetItem, bool) onToggleCompleted;
  final Future<void> Function() onLogSet;
  final VoidCallback onAddSet;
  final void Function(String, WorkoutRunnerSetItem) onAddNote;
  final ValueChanged<int> onShowExercise;
  final void Function(String, WorkoutRunnerSetItem, bool)? onToggleSkipped;

  @override
  State<WorkoutRunnerTrainingLog> createState() =>
      _WorkoutRunnerTrainingLogState();
}

class _WorkoutRunnerTrainingLogState extends State<WorkoutRunnerTrainingLog> {
  static const _resolver = WorkoutRunnerBlockResolver();
  bool _logging = false;

  bool get _enabled => widget.enabled && !_logging;

  Future<void> _logSet() async {
    if (!_enabled || !widget.canLogSet) return;
    setState(() => _logging = true);
    try {
      await widget.onLogSet();
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  Widget _setRow(WorkoutRunnerBlockSet row, {required bool stacked}) {
    final active = row.set.id == widget.activeSet?.id;
    return _RunnerSetRow(
      key: ValueKey('workout_runner_set_row_${row.set.id}'),
      row: row,
      label: widget.block.isSuperset
          ? _resolver.setLabel(widget.block, row.exercise, row.set)
          : _resolver.shortSetLabel(row.exercise, row.set),
      showExercise: widget.block.isSuperset,
      active: active,
      stacked: stacked,
      enabled: _enabled,
      canLogSet: widget.canLogSet,
      logging: _logging && active,
      onUpdate: (set) => widget.onUpdateSet(row.exercise.id, set),
      onCompleted: (value) =>
          widget.onToggleCompleted(row.exercise.id, row.set, value),
      onLog: _logSet,
      onRestore: widget.onToggleSkipped == null
          ? null
          : () => widget.onToggleSkipped!(row.exercise.id, row.set, false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _resolver.orderedSets(widget.block);
    final activeRow = rows
        .where((row) => row.set.id == widget.activeSet?.id)
        .firstOrNull;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth - AppSpacing.controlGap * 2 <
                AppWorkoutRunnerTokens.tableBreakpoint ||
            MediaQuery.textScalerOf(context).scale(AppFontSizes.md) >
                AppFontSizes.md * AppWorkoutRunnerTokens.largeTextBreakpoint;
        final addSet = _RunnerTextAction(
          key: const Key('workout_runner_add_set'),
          label: widget.block.isSuperset
              ? AppStrings.addSuperset
              : AppStrings.addSet,
          asset: OutlinedSvgAssets.plus,
          onPressed: _enabled ? widget.onAddSet : null,
        );
        final addNote = _RunnerTextAction(
          key: const Key('workout_runner_add_note'),
          label: AppStrings.addNote,
          asset: OutlinedSvgAssets.pencilSquare,
          onPressed: _enabled && activeRow != null
              ? () => widget.onAddNote(activeRow.exercise.id, activeRow.set)
              : null,
        );
        return Material(
          key: const Key('workout_runner_training_log'),
          color: WorkoutRunnerStyle.panel(context),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(
                alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
              ),
              width: AppSizing.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.controlGap,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          AppStrings.runnerTrainingLog,
                          style: WorkoutRunnerStyle.heading(
                            context,
                          ).copyWith(fontSize: AppFontSizes.xl),
                        ),
                      ),
                    ),
                    if (widget.enabled && activeRow != null) ...[
                      AppWhiteSpace.wSm,
                      const _LiveIndicator(),
                    ],
                    if (!widget.block.isSuperset &&
                        widget.block.members.isNotEmpty)
                      IconButton(
                        key: const Key('workout_runner_log_exercise_guide'),
                        onPressed: _enabled
                            ? () => widget.onShowExercise(
                                widget.block.members.single.exerciseId,
                              )
                            : null,
                        tooltip: AppStrings.exerciseGuide,
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(
                            AppWorkoutRunnerTokens.controlSize,
                          ),
                        ),
                        icon: const _RunnerIcon(
                          asset: OutlinedSvgAssets.informationCircle,
                        ),
                      ),
                  ],
                ),
              ),
              if (!stacked) const _TableHeader(),
              if (widget.block.isSuperset)
                Column(
                  key: const Key('workout_runner_superset_block'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        AppStrings.superset,
                        style: WorkoutRunnerStyle.label(
                          context,
                        ).copyWith(color: WorkoutRunnerStyle.accent(context)),
                      ),
                    ),
                    for (final type in SetType.values)
                      for (
                        var round = 0;
                        round <
                            (type == SetType.warmup
                                ? _resolver.maxWarmupRounds(widget.block)
                                : _resolver.maxWorkingRounds(widget.block));
                        round++
                      )
                        Column(
                          key: ValueKey(
                            'workout_runner_superset_round_${type.name}_$round',
                          ),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SetGroupLabel(
                              label: AppStrings.runnerRound(
                                round + 1,
                                type == SetType.warmup
                                    ? AppStrings.warmupSet
                                    : AppStrings.workingSet,
                              ),
                            ),
                            for (final row
                                in type == SetType.warmup
                                    ? _resolver.warmupRoundSets(
                                        widget.block,
                                        round,
                                      )
                                    : _resolver.workingRoundSets(
                                        widget.block,
                                        round,
                                      ))
                              KeyedSubtree(
                                key: ValueKey(
                                  'workout_runner_superset_set_row_${row.set.id}',
                                ),
                                child: _setRow(row, stacked: stacked),
                              ),
                          ],
                        ),
                  ],
                )
              else
                for (final type in SetType.values)
                  if (rows.any((row) => row.set.setType == type)) ...[
                    _SetGroupLabel(
                      label: type == SetType.warmup
                          ? AppStrings.warmupSet
                          : AppStrings.workingSet,
                    ),
                    for (final row in rows.where(
                      (row) => row.set.setType == type,
                    ))
                      _setRow(row, stacked: stacked),
                  ],
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    AppStrings.noSetsYet,
                    style: WorkoutRunnerStyle.body(context),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (stacked)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [addSet, AppWhiteSpace.hSm, addNote],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: addSet),
                          AppWhiteSpace.wSm,
                          Expanded(child: addNote),
                        ],
                      ),
                    if (widget.onToggleSkipped != null &&
                        activeRow != null) ...[
                      AppWhiteSpace.hXs,
                      TextButton(
                        key: ValueKey(
                          'workout_runner_skip_set_${activeRow.set.id}',
                        ),
                        onPressed: _enabled
                            ? () => widget.onToggleSkipped!(
                                activeRow.exercise.id,
                                activeRow.set,
                                true,
                              )
                            : null,
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            AppWorkoutRunnerTokens.controlSize,
                          ),
                          foregroundColor: WorkoutRunnerStyle.accent(context),
                        ),
                        child: Text(
                          AppStrings.markSkipped,
                          style: WorkoutRunnerStyle.label(context).copyWith(
                            color: _enabled
                                ? WorkoutRunnerStyle.accent(context)
                                : context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('workout_runner_live_indicator'),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: WorkoutRunnerStyle.accent(
        context,
      ).withValues(alpha: AppWorkoutRunnerTokens.activeRowSurfaceOpacity),
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.xs,
          height: AppSpacing.xs,
          decoration: BoxDecoration(
            color: WorkoutRunnerStyle.accent(context),
            shape: BoxShape.circle,
          ),
        ),
        AppWhiteSpace.wXs,
        Text(
          AppStrings.runnerLive,
          style: WorkoutRunnerStyle.caption(context).copyWith(
            color: WorkoutRunnerStyle.accent(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('workout_runner_table_columns'),
    color: context.colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppSpacing.sm,
      ),
      child: _SetTableGrid(
        set: Text(
          AppStrings.setNumberColumn,
          style: WorkoutRunnerStyle.caption(context),
        ),
        target: Text(
          AppStrings.targetColumn,
          style: WorkoutRunnerStyle.caption(context),
        ),
        weight: Text(
          AppStrings.kilogramsAbbreviation,
          textAlign: TextAlign.center,
          style: WorkoutRunnerStyle.caption(context),
        ),
        reps: Text(
          AppStrings.repsColumn,
          textAlign: TextAlign.center,
          style: WorkoutRunnerStyle.caption(context),
        ),
        action: Text(
          AppStrings.logColumn,
          textAlign: TextAlign.center,
          style: WorkoutRunnerStyle.caption(context),
        ),
      ),
    ),
  );
}

class _SetTableGrid extends StatelessWidget {
  const _SetTableGrid({
    required this.set,
    required this.target,
    required this.weight,
    required this.reps,
    required this.action,
  });

  final Widget set;
  final Widget target;
  final Widget weight;
  final Widget reps;
  final Widget action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(width: AppWorkoutRunnerTokens.tableSetWidth, child: set),
      AppWhiteSpace.wXs,
      Expanded(child: target),
      AppWhiteSpace.wXs,
      SizedBox(width: AppWorkoutRunnerTokens.tableWeightWidth, child: weight),
      AppWhiteSpace.wXs,
      SizedBox(width: AppWorkoutRunnerTokens.tableRepsWidth, child: reps),
      AppWhiteSpace.wXs,
      SizedBox(width: AppWorkoutRunnerTokens.controlSize, child: action),
    ],
  );
}

class _SetGroupLabel extends StatelessWidget {
  const _SetGroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: Text(label, style: WorkoutRunnerStyle.caption(context)),
  );
}

class _RunnerSetRow extends StatelessWidget {
  const _RunnerSetRow({
    super.key,
    required this.row,
    required this.label,
    required this.showExercise,
    required this.active,
    required this.stacked,
    required this.enabled,
    required this.canLogSet,
    required this.logging,
    required this.onUpdate,
    required this.onCompleted,
    required this.onLog,
    required this.onRestore,
  });

  final WorkoutRunnerBlockSet row;
  final String label;
  final bool showExercise;
  final bool active;
  final bool stacked;
  final bool enabled;
  final bool canLogSet;
  final bool logging;
  final ValueChanged<WorkoutRunnerSetItem> onUpdate;
  final ValueChanged<bool> onCompleted;
  final Future<void> Function() onLog;
  final VoidCallback? onRestore;

  Widget _field({required bool weight}) {
    final set = row.set;
    return _RunnerNumberInput(
      key: ValueKey(
        'workout_runner_${weight ? 'weight' : 'reps'}_input_${set.id}',
      ),
      fieldKey: Key(weight ? 'active_weight_field' : 'active_reps_field'),
      label: weight
          ? '${AppStrings.actualWeight} (${AppStrings.metricWeightUnit})'
          : AppStrings.actualReps,
      actual: weight
          ? (set.actualWeightKg == null
                ? null
                : _RunnerSetFormatting.number(set.actualWeightKg!))
          : set.actualReps?.toString(),
      fallback: weight
          ? (set.prescribedWeightKg == null
                ? ''
                : _RunnerSetFormatting.number(set.prescribedWeightKg!))
          : (set.prescribedRepsExact ??
                        set.prescribedRepsMin ??
                        set.prescribedRepsMax)
                    ?.toString() ??
                '',
      enabled: enabled,
      decimal: weight,
      compact: !stacked,
      onChanged: (value) => onUpdate(
        weight
            ? _RunnerSetFormatting.withActuals(set, weight: value)
            : _RunnerSetFormatting.withActuals(set, reps: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final set = row.set;
    final action = _SetCompletionAction(
      set: set,
      active: active,
      logging: logging,
      enabled:
          enabled &&
          (set.completed ||
              active && canLogSet ||
              set.skipped && onRestore != null),
      onPressed: active
          ? onLog
          : set.completed
          ? () => onCompleted(false)
          : set.skipped
          ? onRestore
          : null,
    );
    final completion = set.skipped
        ? SizedBox(
            key: ValueKey('workout_runner_skip_set_${set.id}'),
            child: action,
          )
        : action;
    final valueStyle = WorkoutRunnerStyle.label(context).copyWith(
      color: set.completed
          ? context.colorScheme.onSurfaceVariant
          : context.colorScheme.onSurface,
    );
    final target = Text(
      stacked
          ? '${AppStrings.targetColumn}: ${_RunnerSetFormatting.target(set)}'
          : _RunnerSetFormatting.target(set),
      style: stacked
          ? WorkoutRunnerStyle.small(context)
          : WorkoutRunnerStyle.caption(context),
    );
    final weight = active
        ? _field(weight: true)
        : Text(
            set.actualWeightKg == null
                ? AppStrings.unavailableValue
                : _RunnerSetFormatting.number(set.actualWeightKg!),
            textAlign: TextAlign.center,
            style: valueStyle,
          );
    final reps = active
        ? _field(weight: false)
        : Text(
            set.actualReps?.toString() ?? AppStrings.unavailableValue,
            textAlign: TextAlign.center,
            style: valueStyle,
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? Color.alphaBlend(
                WorkoutRunnerStyle.accent(context).withValues(
                  alpha: AppWorkoutRunnerTokens.activeRowSurfaceOpacity,
                ),
                WorkoutRunnerStyle.panel(context),
              )
            : WorkoutRunnerStyle.panel(context),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: AppWorkoutRunnerTokens.subtleBorderOpacity,
            ),
            width: AppSizing.divider,
          ),
        ),
      ),
      child: Stack(
        children: [
          if (active)
            Positioned(
              left: 0,
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
              width: AppWorkoutRunnerTokens.activeRailWidth,
              child: DecoratedBox(
                key: ValueKey('workout_runner_active_rail_${set.id}'),
                decoration: BoxDecoration(
                  color: WorkoutRunnerStyle.accent(context),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.controlGap,
              vertical: AppSpacing.controlGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stacked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Text(label, style: valueStyle),
                            Text(
                              active
                                  ? AppStrings.runnerActiveSet
                                  : set.completed
                                  ? AppStrings.setCompleted
                                  : set.skipped
                                  ? AppStrings.skipped
                                  : set.setType == SetType.warmup
                                  ? AppStrings.warmupSet
                                  : AppStrings.workingSet,
                              style: WorkoutRunnerStyle.caption(context),
                            ),
                          ],
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      completion,
                    ],
                  ),
                  if (showExercise) ...[
                    AppWhiteSpace.hXs,
                    Text(
                      row.exercise.exerciseName,
                      style: WorkoutRunnerStyle.label(context),
                    ),
                  ],
                  AppWhiteSpace.hSm,
                  target,
                  if (active) ...[
                    AppWhiteSpace.hMd,
                    _StackedActualInputs(weight: weight, reps: reps),
                  ] else if (set.completed) ...[
                    AppWhiteSpace.hSm,
                    Text(
                      '${AppStrings.actual}: ${_RunnerSetFormatting.actual(set)}',
                      style: WorkoutRunnerStyle.small(context),
                    ),
                  ],
                ] else
                  _SetTableGrid(
                    set: Text(label, style: valueStyle),
                    target: target,
                    weight: weight,
                    reps: reps,
                    action: completion,
                  ),
                if (set.skipped && !stacked) ...[
                  AppWhiteSpace.hXs,
                  Text(
                    AppStrings.skipped,
                    style: WorkoutRunnerStyle.caption(context),
                  ),
                ],
                if (set.notes?.trim().isNotEmpty ?? false) ...[
                  AppWhiteSpace.hXs,
                  Text(set.notes!, style: WorkoutRunnerStyle.caption(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedActualInputs extends StatelessWidget {
  const _StackedActualInputs({required this.weight, required this.reps});
  final Widget weight;
  final Widget reps;

  @override
  Widget build(BuildContext context) {
    final large =
        MediaQuery.textScalerOf(context).scale(AppFontSizes.md) >
        AppFontSizes.md * AppWorkoutRunnerTokens.largeTextBreakpoint;
    if (large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [weight, AppWhiteSpace.hMd, reps],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: weight),
        AppWhiteSpace.wSm,
        Expanded(child: reps),
      ],
    );
  }
}

class _SetCompletionAction extends StatelessWidget {
  const _SetCompletionAction({
    required this.set,
    required this.active,
    required this.logging,
    required this.enabled,
    required this.onPressed,
  });
  final WorkoutRunnerSetItem set;
  final bool active;
  final bool logging;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      key: ValueKey('workout_runner_set_hit_target_${set.id}'),
      checked: set.completed,
      child: IconButton(
        key: ValueKey('workout_runner_set_action_${set.id}'),
        tooltip: active
            ? AppStrings.logSet
            : set.completed
            ? AppStrings.runnerUndoSet
            : set.skipped
            ? AppStrings.runnerRestoreSet
            : AppStrings.markCompleted,
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppWorkoutRunnerTokens.controlSize),
          backgroundColor: active
              ? WorkoutRunnerStyle.actionFill(context)
              : context.colorScheme.surfaceContainerLow,
          foregroundColor: active
              ? WorkoutRunnerStyle.actionForeground(context)
              : context.colorScheme.onSurfaceVariant,
          disabledBackgroundColor: context.colorScheme.surfaceContainerLow,
          disabledForegroundColor: context.colorScheme.onSurfaceVariant,
          side: BorderSide(
            color: active
                ? WorkoutRunnerStyle.actionFill(context)
                : context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        icon: logging
            ? SizedBox(
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.strokeWidth,
                  color: context.colorScheme.onSurfaceVariant,
                  semanticsLabel: AppStrings.loading,
                ),
              )
            : set.completed || active || set.skipped
            ? _RunnerIcon(
                asset: set.skipped
                    ? OutlinedSvgAssets.arrowUturnLeft
                    : OutlinedSvgAssets.check,
                color: enabled && active
                    ? WorkoutRunnerStyle.actionForeground(context)
                    : context.colorScheme.onSurfaceVariant,
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
}

class _RunnerNumberInput extends StatefulWidget {
  const _RunnerNumberInput({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.actual,
    required this.fallback,
    required this.enabled,
    required this.decimal,
    required this.onChanged,
    this.compact = false,
  });

  final Key fieldKey;
  final String label;
  final String? actual;
  final String fallback;
  final bool enabled;
  final bool decimal;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  State<_RunnerNumberInput> createState() => _RunnerNumberInputState();
}

class _RunnerNumberInputState extends State<_RunnerNumberInput> {
  late final TextEditingController _controller;
  String? _lastEdit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.actual ?? widget.fallback);
  }

  @override
  void didUpdateWidget(_RunnerNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final edit = _lastEdit;
    if (edit != null &&
        (edit.isEmpty
            ? widget.actual == null
            : num.tryParse(edit) == num.tryParse(widget.actual ?? ''))) {
      return;
    }
    if (widget.actual == oldWidget.actual &&
        (widget.fallback == oldWidget.fallback || edit != null)) {
      return;
    }
    final text = widget.actual ?? widget.fallback;
    if (text == _controller.text) return;
    final selection = _controller.selection;
    _controller.value = TextEditingValue(
      text: text,
      selection: selection.isValid
          ? TextSelection(
              baseOffset: selection.baseOffset.clamp(0, text.length),
              extentOffset: selection.extentOffset.clamp(0, text.length),
              affinity: selection.affinity,
              isDirectional: selection.isDirectional,
            )
          : TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!widget.compact) ...[
        ExcludeSemantics(
          child: Text(widget.label, style: WorkoutRunnerStyle.label(context)),
        ),
        AppWhiteSpace.hSm,
      ],
      MergeSemantics(
        child: Semantics(
          label: widget.label,
          child: TextField(
            key: widget.fieldKey,
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.decimal,
            ),
            textInputAction: TextInputAction.done,
            textAlign: widget.compact ? TextAlign.center : TextAlign.start,
            inputFormatters: [
              if (widget.decimal)
                TextInputFormatter.withFunction(
                  _RunnerSetFormatting.weightInput,
                )
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              _lastEdit = value;
              widget.onChanged(value);
            },
            style: WorkoutRunnerStyle.body(context).copyWith(
              fontSize: widget.compact ? AppFontSizes.md : AppFontSizes.lg,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.unavailableValue,
              hintStyle: WorkoutRunnerStyle.body(
                context,
              ).copyWith(color: context.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: WorkoutRunnerStyle.panel(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.compact ? AppSpacing.xs : AppSpacing.md,
                vertical: AppSpacing.controlGap,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: AppSizing.divider,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: AppSizing.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: WorkoutRunnerStyle.accent(context),
                  width: AppSizing.strokeWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _RunnerTextAction extends StatelessWidget {
  const _RunnerTextAction({
    super.key,
    required this.label,
    required this.asset,
    required this.onPressed,
  });

  final String label;
  final String asset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(AppWorkoutRunnerTokens.controlSize),
      foregroundColor: WorkoutRunnerStyle.accent(context),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.buttonVertical,
      ),
      side: BorderSide(color: context.colorScheme.outlineVariant),
      shape: const StadiumBorder(),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RunnerIcon(
          asset: asset,
          color: onPressed == null
              ? context.colorScheme.onSurfaceVariant
              : WorkoutRunnerStyle.accent(context),
        ),
        AppWhiteSpace.wSm,
        Text(
          label,
          style: WorkoutRunnerStyle.label(context).copyWith(
            color: onPressed == null
                ? context.colorScheme.onSurfaceVariant
                : WorkoutRunnerStyle.accent(context),
          ),
        ),
      ],
    ),
  );
}

class _RunnerIcon extends StatelessWidget {
  const _RunnerIcon({required this.asset, this.color});

  final String asset;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      asset,
      width: AppSizing.iconSm,
      height: AppSizing.iconSm,
      colorFilter: ColorFilter.mode(
        color ?? context.colorScheme.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    ),
  );
}

abstract final class _RunnerSetFormatting {
  static String number(num value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  static String? _reps(WorkoutRunnerSetItem set) {
    final exact = set.prescribedRepsExact;
    if (exact != null) return '$exact';
    final minimum = set.prescribedRepsMin;
    final maximum = set.prescribedRepsMax;
    if (minimum != null && maximum != null) {
      return minimum == maximum ? '$minimum' : '$minimum–$maximum';
    }
    if (minimum != null) return '$minimum+';
    if (maximum != null) return '≤$maximum';
    return null;
  }

  static String target(WorkoutRunnerSetItem set) {
    final reps = _reps(set);
    final weight = set.prescribedWeightKg;
    final rpeMin = set.prescribedRpeMin;
    final rpeMax = set.prescribedRpeMax;
    final parts = <String>[
      if (weight != null) '${number(weight)} ${AppStrings.metricWeightUnit}',
      if (reps != null) AppStrings.exerciseRepsSummary(reps),
      if (rpeMin != null && rpeMax != null)
        '${AppStrings.rpe} ${number(rpeMin)}${rpeMin == rpeMax ? '' : '–${number(rpeMax)}'}'
      else if (rpeMin != null)
        '${AppStrings.rpe} ≥${number(rpeMin)}'
      else if (rpeMax != null)
        '${AppStrings.rpe} ≤${number(rpeMax)}',
      if (set.restSeconds != null)
        '${AppStrings.rest}: ${set.restSeconds}${AppStrings.secondsUnitAbbreviation}',
    ];
    return parts.isEmpty ? AppStrings.unavailableValue : parts.join(' · ');
  }

  static String actual(WorkoutRunnerSetItem set) {
    final parts = <String>[
      if (set.actualWeightKg != null)
        '${number(set.actualWeightKg!)} ${AppStrings.metricWeightUnit}',
      if (set.actualReps != null)
        AppStrings.exerciseRepsSummary('${set.actualReps}'),
      if (set.actualRpe != null) '${AppStrings.rpe} ${number(set.actualRpe!)}',
      if (set.actualRir != null) '${AppStrings.rir} ${set.actualRir}',
    ];
    return parts.isEmpty ? AppStrings.unavailableValue : parts.join(' · ');
  }

  static TextEditingValue weightInput(
    TextEditingValue previous,
    TextEditingValue next,
  ) => RegExp(r'^\d*(?:\.\d{0,2})?$').hasMatch(next.text) ? next : previous;

  static WorkoutRunnerSetItem withActuals(
    WorkoutRunnerSetItem set, {
    String? weight,
    String? reps,
  }) => WorkoutRunnerSetItem(
    id: set.id,
    exerciseId: set.exerciseId,
    setIndex: set.setIndex,
    setType: set.setType,
    performedAt: set.performedAt,
    completed: set.completed,
    skipped: set.skipped,
    setIntent: set.setIntent,
    prescribedRepsMin: set.prescribedRepsMin,
    prescribedRepsMax: set.prescribedRepsMax,
    prescribedRepsExact: set.prescribedRepsExact,
    prescribedWeightKg: set.prescribedWeightKg,
    prescribedRpeMin: set.prescribedRpeMin,
    prescribedRpeMax: set.prescribedRpeMax,
    actualReps: reps == null ? set.actualReps : int.tryParse(reps),
    actualWeightKg: weight == null
        ? set.actualWeightKg
        : double.tryParse(weight),
    actualDurationSeconds: set.actualDurationSeconds,
    actualDistanceMeters: set.actualDistanceMeters,
    actualRpe: set.actualRpe,
    actualRir: set.actualRir,
    restSeconds: set.restSeconds,
    notes: set.notes,
  );
}
