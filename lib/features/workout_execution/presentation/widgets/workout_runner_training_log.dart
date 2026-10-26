import 'dart:math' as math;

import 'package:aedify/shared/domain/set_effort.dart';

import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_strings.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
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
  final _tableScrollController = ScrollController();

  @override
  void dispose() {
    _tableScrollController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final rows = _resolver.orderedSets(widget.block);
    final activeRow = rows
        .where((row) => row.set.id == widget.activeSet?.id)
        .firstOrNull;
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = math.max(
          1.0,
          MediaQuery.textScalerOf(context).scale(AppFontSizes.md) /
              AppFontSizes.md,
        );
        final stacked =
            constraints.maxWidth < AppWorkoutRunnerTokens.tableBreakpoint ||
            textScale > AppWorkoutRunnerTokens.largeTextBreakpoint;
        final tableWidth = rows.fold<double>(
          constraints.maxWidth,
          (width, row) => math.max(
            width,
            _RunnerTableLayout.minimumWidth(
              _RunnerTableLayout.loggingType(row),
              textScale,
            ),
          ),
        );
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
              MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Scrollbar(
                  controller: _tableScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    key: const Key('workout_runner_table_scroll'),
                    controller: _tableScrollController,
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SizedBox(
                      width: tableWidth,
                      child: _RunnerTableRows(
                        block: widget.block,
                        activeSet: widget.activeSet,
                        enabled: _enabled,
                        canLogSet: widget.canLogSet,
                        logging: _logging,
                        textScale: textScale,
                        onUpdateSet: widget.onUpdateSet,
                        onToggleCompleted: widget.onToggleCompleted,
                        onToggleSkipped: widget.onToggleSkipped,
                        onLogSet: _logSet,
                      ),
                    ),
                  ),
                ),
              ),
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

enum _RunnerColumn { set, target, weight, reps, duration, distance, rpe, log }

abstract final class _RunnerTableLayout {
  static ExerciseLoggingType loggingType(WorkoutRunnerBlockSet row) =>
      WorkoutRunnerSetPolicy.loggingType(
        row.set,
        snapshot: row.set.exerciseId == row.exercise.exerciseId
            ? row.exercise.loggingType
            : null,
      );

  static List<_RunnerColumn> columns(ExerciseLoggingType type) => [
    _RunnerColumn.set,
    _RunnerColumn.target,
    ...switch (type) {
      ExerciseLoggingType.repsWeight => [
        _RunnerColumn.weight,
        _RunnerColumn.reps,
      ],
      ExerciseLoggingType.repsOnly => [_RunnerColumn.reps],
      ExerciseLoggingType.duration => [
        _RunnerColumn.duration,
        _RunnerColumn.distance,
      ],
    },
    _RunnerColumn.rpe,
    _RunnerColumn.log,
  ];

  static double width(_RunnerColumn column) => switch (column) {
    _RunnerColumn.set => AppWorkoutRunnerTokens.tableSetWidth,
    _RunnerColumn.target => AppWorkoutRunnerTokens.tableTargetWidth,
    _RunnerColumn.weight => AppWorkoutRunnerTokens.tableWeightWidth,
    _RunnerColumn.reps => AppWorkoutRunnerTokens.tableRepsWidth,
    _RunnerColumn.duration => AppWorkoutRunnerTokens.tableDurationWidth,
    _RunnerColumn.distance => AppWorkoutRunnerTokens.tableDistanceWidth,
    _RunnerColumn.rpe => AppWorkoutRunnerTokens.tableEffortWidth,
    _RunnerColumn.log => AppWorkoutRunnerTokens.controlSize,
  };

  static double minimumWidth(ExerciseLoggingType type, double scale) {
    final schema = columns(type);
    return schema.fold<double>(
          0,
          (total, column) => total + width(column) * scale,
        ) +
        AppSpacing.xs * (schema.length - 1) +
        AppSpacing.controlGap * 2;
  }

  static String heading(_RunnerColumn column) => switch (column) {
    _RunnerColumn.set => AppStrings.setNumberColumn,
    _RunnerColumn.target => AppStrings.targetColumn,
    _RunnerColumn.weight => AppStrings.kilogramsAbbreviation,
    _RunnerColumn.reps => AppStrings.repsColumn,
    _RunnerColumn.duration => AppStrings.durationColumn,
    _RunnerColumn.distance => AppStrings.distanceColumn,
    _RunnerColumn.rpe => AppStrings.rpe,
    _RunnerColumn.log => AppStrings.logColumn,
  };
}

class _RunnerTableRows extends StatelessWidget {
  const _RunnerTableRows({
    required this.block,
    required this.activeSet,
    required this.enabled,
    required this.canLogSet,
    required this.logging,
    required this.textScale,
    required this.onUpdateSet,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
    required this.onLogSet,
  });
  final WorkoutRunnerBlock block;
  final WorkoutRunnerSetItem? activeSet;
  final bool enabled;
  final bool canLogSet;
  final bool logging;
  final double textScale;
  final void Function(String, WorkoutRunnerSetItem) onUpdateSet;
  final void Function(String, WorkoutRunnerSetItem, bool) onToggleCompleted;
  final void Function(String, WorkoutRunnerSetItem, bool)? onToggleSkipped;
  final Future<void> Function() onLogSet;

  @override
  Widget build(BuildContext context) {
    const resolver = WorkoutRunnerBlockResolver();
    final rows = resolver.orderedSets(block);
    return Column(
      key: block.isSuperset ? const Key('workout_runner_superset_block') : null,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (block.isSuperset)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              AppStrings.superset,
              style: WorkoutRunnerStyle.label(context),
            ),
          ),
        for (final entry in rows.indexed) ...[
          if (block.isSuperset &&
              (entry.$1 == 0 ||
                  rows[entry.$1 - 1].set.setType != entry.$2.set.setType ||
                  resolver.roundIndex(
                        rows[entry.$1 - 1].exercise,
                        rows[entry.$1 - 1].set,
                      ) !=
                      resolver.roundIndex(entry.$2.exercise, entry.$2.set)))
            Padding(
              key: ValueKey(
                'workout_runner_superset_round_${entry.$2.set.setType.name}_${resolver.roundIndex(entry.$2.exercise, entry.$2.set)}',
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                AppStrings.runnerRound(
                  resolver.roundIndex(entry.$2.exercise, entry.$2.set) + 1,
                  entry.$2.set.setType == SetType.warmup
                      ? AppStrings.warmupSet
                      : AppStrings.workingSet,
                ),
                style: WorkoutRunnerStyle.caption(context),
              ),
            ),
          if (entry.$1 == 0 ||
              _RunnerTableLayout.loggingType(rows[entry.$1 - 1]) !=
                  _RunnerTableLayout.loggingType(entry.$2))
            _TableHeader(
              loggingType: _RunnerTableLayout.loggingType(entry.$2),
              textScale: textScale,
            ),
          _RunnerSetRow(
            key: ValueKey('workout_runner_set_row_${entry.$2.set.id}'),
            row: entry.$2,
            label: block.isSuperset
                ? resolver.setLabel(block, entry.$2.exercise, entry.$2.set)
                : resolver.shortSetLabel(entry.$2.exercise, entry.$2.set),
            showExercise: block.isSuperset,
            active: entry.$2.set.id == activeSet?.id,
            enabled: enabled,
            canLogSet: canLogSet,
            logging: logging && entry.$2.set.id == activeSet?.id,
            textScale: textScale,
            onUpdate: (set) => onUpdateSet(entry.$2.exercise.id, set),
            onCompleted: (value) =>
                onToggleCompleted(entry.$2.exercise.id, entry.$2.set, value),
            onLog: onLogSet,
            onRestore: onToggleSkipped == null
                ? null
                : () => onToggleSkipped!(
                    entry.$2.exercise.id,
                    entry.$2.set,
                    false,
                  ),
          ),
        ],
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.loggingType, required this.textScale});
  final ExerciseLoggingType loggingType;
  final double textScale;

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
        loggingType: loggingType,
        textScale: textScale,
        cells: [
          for (final column in _RunnerTableLayout.columns(loggingType))
            Text(
              _RunnerTableLayout.heading(column),
              textAlign: column == _RunnerColumn.target
                  ? TextAlign.start
                  : TextAlign.center,
              style: WorkoutRunnerStyle.caption(context),
            ),
        ],
      ),
    ),
  );
}

class _SetTableGrid extends StatelessWidget {
  const _SetTableGrid({
    required this.loggingType,
    required this.textScale,
    required this.cells,
  });
  final ExerciseLoggingType loggingType;
  final double textScale;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    final schema = _RunnerTableLayout.columns(loggingType);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final entry in schema.indexed) ...[
          if (entry.$2 == _RunnerColumn.target)
            Expanded(child: cells[entry.$1])
          else
            SizedBox(
              width: _RunnerTableLayout.width(entry.$2) * textScale,
              child: cells[entry.$1],
            ),
          if (entry.$1 < schema.length - 1) AppWhiteSpace.wXs,
        ],
      ],
    );
  }
}

class _SetGroupLabel extends StatelessWidget {
  const _SetGroupLabel({
    required this.set,
    required this.label,
    required this.onPressed,
  });
  final WorkoutRunnerSetItem set;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    key: ValueKey('workout_runner_set_type_${set.id}'),
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size.square(AppWorkoutRunnerTokens.controlSize),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
    ),
    child: Semantics(
      label: AppStrings.toggleSetTypeLabel(
        label,
        set.setType == SetType.working
            ? AppStrings.warmupSet
            : AppStrings.workingSet,
      ),
      child: Text(
        set.setType == SetType.warmup
            ? AppStrings.warmupSet
            : AppStrings.workingSet,
        textAlign: TextAlign.center,
        style: WorkoutRunnerStyle.caption(context).copyWith(
          color: onPressed == null
              ? context.colorScheme.onSurfaceVariant
              : WorkoutRunnerStyle.accent(context),
        ),
      ),
    ),
  );
}

class _RunnerSetRow extends StatelessWidget {
  const _RunnerSetRow({
    super.key,
    required this.row,
    required this.label,
    required this.showExercise,
    required this.active,
    required this.enabled,
    required this.canLogSet,
    required this.logging,
    required this.textScale,
    required this.onUpdate,
    required this.onCompleted,
    required this.onLog,
    required this.onRestore,
  });
  final WorkoutRunnerBlockSet row;
  final String label;
  final bool showExercise;
  final bool active;
  final bool enabled;
  final bool canLogSet;
  final bool logging;
  final double textScale;
  final ValueChanged<WorkoutRunnerSetItem> onUpdate;
  final ValueChanged<bool> onCompleted;
  final Future<void> Function() onLog;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final set = row.set;
    final type = _RunnerTableLayout.loggingType(row);
    final schema = _RunnerTableLayout.columns(type);
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
              left: AppSpacing.zero,
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
                if (showExercise) ...[
                  Text(
                    row.exercise.exerciseName,
                    style: WorkoutRunnerStyle.label(context),
                  ),
                  AppWhiteSpace.hSm,
                ],
                _SetTableGrid(
                  loggingType: type,
                  textScale: textScale,
                  cells: [
                    for (final column in schema)
                      if (column == _RunnerColumn.set)
                        Column(
                          children: [
                            Text(
                              label,
                              style: WorkoutRunnerStyle.label(context),
                            ),
                            _SetGroupLabel(
                              set: set,
                              label: label,
                              onPressed: enabled
                                  ? () => onUpdate(
                                      set.copyWith(
                                        setType: set.setType == SetType.working
                                            ? SetType.warmup
                                            : SetType.working,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        )
                      else if (column == _RunnerColumn.target)
                        Text(
                          _RunnerSetFormatting.target(set),
                          style: WorkoutRunnerStyle.caption(context),
                        )
                      else if (column == _RunnerColumn.log)
                        set.skipped
                            ? SizedBox(
                                key: ValueKey(
                                  'workout_runner_skip_set_${set.id}',
                                ),
                                child: action,
                              )
                            : action
                      else
                        _RunnerMetricCell(
                          column: column,
                          set: set,
                          editable: active,
                          enabled: enabled,
                          onUpdate: onUpdate,
                        ),
                  ],
                ),
                if (active && !WorkoutRunnerSetPolicy.hasValidActuals(set)) ...[
                  AppWhiteSpace.hXs,
                  Text(
                    AppErrorStrings.workoutActualsInvalid,
                    style: WorkoutRunnerStyle.small(
                      context,
                    ).copyWith(color: context.colorScheme.error),
                  ),
                ],
                if (set.skipped) ...[
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

class _RunnerMetricCell extends StatelessWidget {
  const _RunnerMetricCell({
    required this.column,
    required this.set,
    required this.editable,
    required this.enabled,
    required this.onUpdate,
  });
  final _RunnerColumn column;
  final WorkoutRunnerSetItem set;
  final bool editable;
  final bool enabled;
  final ValueChanged<WorkoutRunnerSetItem> onUpdate;

  @override
  Widget build(BuildContext context) {
    final actual = switch (column) {
      _RunnerColumn.weight => set.actualWeightKg,
      _RunnerColumn.reps => set.actualReps,
      _RunnerColumn.duration => set.actualDurationSeconds,
      _RunnerColumn.distance => set.actualDistanceMeters,
      _RunnerColumn.rpe => set.actualRpe,
      _ => null,
    };
    if (!editable) {
      return Text(
        actual == null
            ? AppStrings.unavailableValue
            : _RunnerSetFormatting.number(actual),
        textAlign: TextAlign.center,
        style: WorkoutRunnerStyle.label(context),
      );
    }
    final fallback = switch (column) {
      _RunnerColumn.weight => set.prescribedWeightKg,
      _RunnerColumn.reps =>
        set.prescribedRepsExact ??
            set.prescribedRepsMin ??
            set.prescribedRepsMax,
      _RunnerColumn.duration => set.prescribedDurationSeconds,
      _RunnerColumn.distance => set.prescribedDistanceMeters,
      _RunnerColumn.rpe => set.prescribedRpeMin ?? set.prescribedRpeMax,
      _ => null,
    };
    final name = switch (column) {
      _RunnerColumn.weight => AppStrings.actualWeight,
      _RunnerColumn.reps => AppStrings.actualReps,
      _RunnerColumn.duration =>
        '${AppStrings.actualDuration} (${AppStrings.secondsUnitAbbreviation})',
      _RunnerColumn.distance =>
        '${AppStrings.actualDistance} (${WorkoutRunnerStrings.meters})',
      _RunnerColumn.rpe => AppStrings.actualRpe,
      _ => AppStrings.unavailableValue,
    };
    return _RunnerNumberInput(
      key: ValueKey('workout_runner_${column.name}_input_${set.id}'),
      fieldKey: Key('active_${column.name}_field'),
      label: name,
      actual: actual == null ? null : _RunnerSetFormatting.number(actual),
      fallback: fallback == null ? '' : _RunnerSetFormatting.number(fallback),
      enabled: enabled,
      decimal:
          column == _RunnerColumn.weight ||
          column == _RunnerColumn.distance ||
          column == _RunnerColumn.rpe,
      compact: true,
      onChanged: (value) => onUpdate(switch (column) {
        _RunnerColumn.weight => _RunnerSetFormatting.withActuals(
          set,
          weight: value,
        ),
        _RunnerColumn.reps => _RunnerSetFormatting.withActuals(
          set,
          reps: value,
        ),
        _RunnerColumn.duration => _RunnerSetFormatting.withActuals(
          set,
          duration: value,
        ),
        _RunnerColumn.distance => _RunnerSetFormatting.withActuals(
          set,
          distance: value,
        ),
        _RunnerColumn.rpe => _RunnerSetFormatting.withActuals(set, rpe: value),
        _ => set,
      }),
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
  // Keep field scrolling independent of the table's horizontal position.
  final _scrollController = ScrollController(keepScrollOffset: false);
  String? _lastEdit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.actual ?? '');
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
    final text = widget.actual ?? '';
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
    _scrollController.dispose();
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
            scrollController: _scrollController,
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
              else ...[
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction(
                  _RunnerSetFormatting.integerInput,
                ),
              ],
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
              hintText: widget.fallback.isEmpty
                  ? AppStrings.unavailableValue
                  : widget.fallback,
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
        Flexible(
          child: Text(
            label,
            style: WorkoutRunnerStyle.label(context).copyWith(
              color: onPressed == null
                  ? context.colorScheme.onSurfaceVariant
                  : WorkoutRunnerStyle.accent(context),
            ),
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
    final rpeFromRir = SetEffort.rpeFromRir(set.prescribedRir);
    final parts = <String>[
      if (weight != null) '${number(weight)} ${AppStrings.metricWeightUnit}',
      if (reps != null) AppStrings.exerciseRepsSummary(reps),
      if (set.prescribedDurationSeconds != null)
        '${set.prescribedDurationSeconds}${AppStrings.secondsUnitAbbreviation}',
      if (set.prescribedDistanceMeters != null)
        '${number(set.prescribedDistanceMeters!)} ${WorkoutRunnerStrings.meters}',
      if (rpeMin != null && rpeMax != null)
        '${AppStrings.rpe} ${number(rpeMin)}${rpeMin == rpeMax ? '' : '–${number(rpeMax)}'}'
      else if (rpeMin != null)
        '${AppStrings.rpe} ≥${number(rpeMin)}'
      else if (rpeMax != null)
        '${AppStrings.rpe} ≤${number(rpeMax)}'
      else if (rpeFromRir != null)
        '${AppStrings.rpe} ${number(rpeFromRir)}',
      if (set.restSeconds != null)
        '${AppStrings.rest}: ${set.restSeconds}${AppStrings.secondsUnitAbbreviation}',
    ];
    return parts.isEmpty ? AppStrings.unavailableValue : parts.join(' · ');
  }

  static TextEditingValue weightInput(
    TextEditingValue previous,
    TextEditingValue next,
  ) =>
      next.text.isEmpty ||
          RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(next.text) &&
              (double.tryParse(next.text)?.isFinite ?? false)
      ? next
      : previous;

  static TextEditingValue integerInput(
    TextEditingValue previous,
    TextEditingValue next,
  ) => next.text.isEmpty || int.tryParse(next.text) != null ? next : previous;

  static WorkoutRunnerSetItem withActuals(
    WorkoutRunnerSetItem set, {
    String? weight,
    String? reps,
    String? duration,
    String? distance,
    String? rpe,
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
    prescribedRir: set.prescribedRir,
    prescribedDurationSeconds: set.prescribedDurationSeconds,
    prescribedDistanceMeters: set.prescribedDistanceMeters,
    actualReps: reps == null ? set.actualReps : int.tryParse(reps),
    actualWeightKg: weight == null
        ? set.actualWeightKg
        : double.tryParse(weight),
    actualDurationSeconds: duration == null
        ? set.actualDurationSeconds
        : int.tryParse(duration),
    actualDistanceMeters: distance == null
        ? set.actualDistanceMeters
        : double.tryParse(distance),
    actualRpe: rpe == null ? set.actualRpe : double.tryParse(rpe),
    actualRir: rpe == null
        ? set.actualRir
        : SetEffort.rirFromRpe(double.tryParse(rpe)),
    restSeconds: set.restSeconds,
    notes: set.notes,
  );
}
