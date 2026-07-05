import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_type_chip.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerSetRow extends StatefulWidget {
  const WorkoutRunnerSetRow({
    super.key,
    required this.set,
    required this.onChanged,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
  });

  final WorkoutRunnerSetItem set;
  final ValueChanged<WorkoutRunnerSetItem> onChanged;
  final ValueChanged<bool> onToggleCompleted;
  final ValueChanged<bool> onToggleSkipped;

  @override
  State<WorkoutRunnerSetRow> createState() => _WorkoutRunnerSetRowState();
}

class _WorkoutRunnerSetRowState extends State<WorkoutRunnerSetRow> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _notesController = TextEditingController();
  double? _rpe;
  int? _rir;
  bool _isSyncingFromWidget = false;

  @override
  void initState() {
    super.initState();
    _syncFromSet();
    _weightController.addListener(_onFieldChanged);
    _repsController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  @override
  void didUpdateWidget(WorkoutRunnerSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.set.id != oldWidget.set.id) {
      _syncFromSet();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncFromSet() {
    _isSyncingFromWidget = true;
    _weightController.text =
        widget.set.actualWeightKg?.toStringAsFixed(1) ?? '';
    _repsController.text = widget.set.actualReps?.toString() ?? '';
    _notesController.text = widget.set.notes ?? '';
    _rpe = widget.set.actualRpe;
    _rir = widget.set.actualRir;
    _isSyncingFromWidget = false;
  }

  void _onFieldChanged() {
    if (!_isSyncingFromWidget) _emitChanged();
  }

  void _emitChanged() {
    final s = widget.set;
    widget.onChanged(
      WorkoutRunnerSetItem(
        id: s.id,
        exerciseId: s.exerciseId,
        setIndex: s.setIndex,
        setType: s.setType,
        performedAt: s.performedAt,
        completed: s.completed,
        skipped: s.skipped,
        setIntent: s.setIntent,
        prescribedRepsMin: s.prescribedRepsMin,
        prescribedRepsMax: s.prescribedRepsMax,
        prescribedRepsExact: s.prescribedRepsExact,
        prescribedWeightKg: s.prescribedWeightKg,
        prescribedRpeMin: s.prescribedRpeMin,
        prescribedRpeMax: s.prescribedRpeMax,
        actualReps: int.tryParse(_repsController.text),
        actualWeightKg: double.tryParse(_weightController.text),
        actualDurationSeconds: s.actualDurationSeconds,
        actualDistanceMeters: s.actualDistanceMeters,
        actualRpe: _rpe,
        actualRir: _rir,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ),
    );
  }

  void _setRpe(double? v) {
    _rpe = v;
    _emitChanged();
  }

  void _setRir(int? v) {
    _rir = v;
    _emitChanged();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.set;
    final isWarmup = s.setType == SetType.warmup;
    final prescribedLabel = _buildPrescribedLabel(s);
    final isCompleted = s.completed;
    final isSkipped = s.skipped;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.colorScheme.primaryContainer
            : isSkipped
            ? context.colorScheme.surfaceContainerHighest
            : isWarmup
            ? context.colorScheme.surfaceContainerLow
            : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => widget.onToggleCompleted(!isCompleted),
                child: isCompleted
                    ? SvgPicture.asset(
                        OutlinedSvgAssets.checkCircle,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      )
                    : Container(
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colorScheme.onSurfaceVariant,
                            width: AppSizing.strokeWidth,
                          ),
                        ),
                      ),
              ),
              AppWhiteSpace.wXs,
              Text(
                AppStrings.setNumberLabel(s.setIndex + 1),
                style: context.textTheme.bodySmall,
              ),
              AppWhiteSpace.wXs,
              SetTypeChip(setType: s.setType),
              if (prescribedLabel != null) ...[
                AppWhiteSpace.wXs,
                Text(
                  prescribedLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              if (isSkipped)
                Text(
                  AppStrings.skipped,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (!isSkipped) ...[
            AppWhiteSpace.hXs,
            Row(
              children: [
                SizedBox(
                  width: AppSizing.fieldWidthMd,
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.weightLabel,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.inputHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                AppWhiteSpace.wXxs,
                SizedBox(
                  width: AppSizing.fieldWidthSm,
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.repsLabel,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.inputHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                AppWhiteSpace.wXxs,
                SizedBox(
                  width: AppSizing.fieldWidthXs,
                  child: DropdownButtonFormField<double?>(
                    key: const ValueKey('rpe_dropdown'),
                    initialValue: _rpe,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.actualRpe,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.inputHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...List.generate(
                        10,
                        (i) => DropdownMenuItem(
                          value: (i + 1).toDouble(),
                          child: Text('${i + 1}'),
                        ),
                      ),
                    ],
                    onChanged: _setRpe,
                  ),
                ),
                AppWhiteSpace.wXxs,
                SizedBox(
                  width: AppSizing.fieldWidthXs,
                  child: DropdownButtonFormField<int?>(
                    key: const ValueKey('rir_dropdown'),
                    initialValue: _rir,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.actualRir,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.inputHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('-')),
                      ...List.generate(
                        6,
                        (i) => DropdownMenuItem(value: i, child: Text('$i')),
                      ),
                    ],
                    onChanged: _setRir,
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hXxs,
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: AppStrings.setNotes,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.inputHorizontal,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  String? _buildPrescribedLabel(WorkoutRunnerSetItem s) {
    if (s.prescribedRepsMin != null || s.prescribedRepsMax != null) {
      final min = s.prescribedRepsMin;
      final max = s.prescribedRepsMax;
      if (min != null && max != null && min == max) return '$min reps';
      if (min != null && max != null) return '$min-$max reps';
      if (min != null) return '$min+ reps';
      if (max != null) return 'up to $max reps';
    }
    return null;
  }
}
