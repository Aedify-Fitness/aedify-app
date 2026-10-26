import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared set configuration surface for workout and programme template editors.
class WorkoutExerciseConfigPanel extends StatelessWidget {
  const WorkoutExerciseConfigPanel({
    super.key,
    required this.selectedExercise,
    required this.setTypeOptions,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
    required this.onUpdateNotes,
    required this.onDeleteExercise,
  });

  final WorkoutBuilderExerciseDraft? selectedExercise;
  final List<SetTypeOption> setTypeOptions;

  final ValueChanged<String> onAddSet;
  final void Function(String exerciseId, String setId) onRemoveSet;
  final void Function(
    String exerciseId,
    String setId,
    SetPrescriptionDraft prescription,
  )
  onUpdateSet;
  final void Function(String exerciseId, String? notes) onUpdateNotes;
  final ValueChanged<String> onDeleteExercise;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    final exercise = selectedExercise;
    if (exercise == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(
            color: cs.outlineVariant.withValues(
              alpha: AppProgrammeBuilderTokens.borderOpacity,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.arrowsRightLeft,
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              colorFilter: ColorFilter.mode(
                cs.onSurfaceVariant.withValues(
                  alpha: AppProgrammeBuilderTokens.borderOpacity,
                ),
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.selectExerciseToConfigure,
              style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(
          color: cs.outlineVariant.withValues(
            alpha: AppProgrammeBuilderTokens.borderOpacity,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigPanelHeader(
            exercise: exercise,
            onDelete: () => onDeleteExercise(exercise.id),
          ),
          AppWhiteSpace.hXl,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width:
                  AppExerciseConfigTokens.tableWidth *
                  MediaQuery.textScalerOf(context).scale(1),
              child: _SetsTable(
                exercise: exercise,
                setTypeOptions: setTypeOptions,
                loggingType: ExerciseLoggingType.fromDbWithDefault(
                  exercise.exercise.loggingType,
                ),
                onRemoveSet: (setId) => onRemoveSet(exercise.id, setId),
                onUpdateSet: (setId, prescription) =>
                    onUpdateSet(exercise.id, setId, prescription),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('exercise_config_add_set'),
              onPressed: () => onAddSet(exercise.id),
              style: TextButton.styleFrom(
                foregroundColor: cs.secondary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.xs,
                ),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconXs,
                height: AppSizing.iconXs,
                colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
              ),
              label: Text(
                AppStrings.addSet,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Divider(
            height: AppSizing.hairlineStrokeWidth,
            thickness: AppSizing.hairlineStrokeWidth,
          ),
          _CoachNotesField(
            exerciseId: exercise.id,
            initialNotes: exercise.notes,
            onChanged: (notes) => onUpdateNotes(exercise.id, notes),
          ),
        ],
      ),
    );
  }
}

class _ConfigPanelHeader extends StatelessWidget {
  const _ConfigPanelHeader({required this.exercise, required this.onDelete});

  final WorkoutBuilderExerciseDraft exercise;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Row(
      children: [
        Container(
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            SolidSvgAssets.dumbbell,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              cs.onSecondaryContainer,
              BlendMode.srcIn,
            ),
          ),
        ),
        AppWhiteSpace.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.exercise.name,
                style: AppTextStyles.headlineMd.copyWith(
                  color: cs.onSurface,
                  fontSize: AppFontSizes.xl,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppWhiteSpace.hXxs,
              Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (exercise.supersetGroupId != null)
                    AppBadge(
                      label: AppStrings.superset.toUpperCase(),
                      backgroundColor: cs.secondaryContainer,
                      foregroundColor: cs.onSecondaryContainer,
                      borderRadius: AppRadius.sm,
                    ),
                  Text(
                    AppStrings.configLabel.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: AppExerciseConfigTokens.labelTracking,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.trash,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
          ),
          onPressed: onDelete,
          tooltip: AppStrings.removeExercise,
        ),
      ],
    );
  }
}

class _SetsTable extends StatelessWidget {
  const _SetsTable({
    required this.exercise,
    required this.setTypeOptions,
    required this.loggingType,
    required this.onRemoveSet,
    required this.onUpdateSet,
  });

  final WorkoutBuilderExerciseDraft exercise;
  final List<SetTypeOption> setTypeOptions;
  final ExerciseLoggingType loggingType;
  final ValueChanged<String> onRemoveSet;
  final void Function(String setId, SetPrescriptionDraft prescription)
  onUpdateSet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        Divider(
          height: AppSizing.hairlineStrokeWidth,
          thickness: AppSizing.hairlineStrokeWidth,
        ),
        ...exercise.sets.map(
          (set) => _SetTableRow(
            key: ValueKey(set.id),
            set: set,
            setTypeOptions: setTypeOptions,
            loggingType: loggingType,
            onUpdate: (updated) => onUpdateSet(set.id, updated),
            onRemove: () => onRemoveSet(set.id),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    switch (loggingType) {
      case ExerciseLoggingType.repsWeight:
        return Row(
          children: [
            _TableHeader(label: AppStrings.setNumberColumn, flex: 2),
            _TableHeader(label: AppStrings.setTypeColumn, flex: 3),
            _TableHeader(label: AppStrings.weightColumn, flex: 4),
            _TableHeader(label: AppStrings.repsColumn, flex: 3),
            _TableHeader(label: AppStrings.targetColumn, flex: 4),
            _TableHeader(label: AppStrings.restColumn, flex: 2),
            AppWhiteSpace.custom(width: AppSizing.handleWidth),
          ],
        );
      case ExerciseLoggingType.repsOnly:
        return Row(
          children: [
            _TableHeader(label: AppStrings.setNumberColumn, flex: 2),
            _TableHeader(label: AppStrings.repsColumn, flex: 3),
            Expanded(flex: 6, child: const SizedBox.shrink()),
            _TableHeader(label: AppStrings.restColumn, flex: 2),
            AppWhiteSpace.custom(width: AppSizing.handleWidth),
          ],
        );
      case ExerciseLoggingType.duration:
        return Row(
          children: [
            _TableHeader(label: AppStrings.setNumberColumn, flex: 2),
            _TableHeader(label: AppStrings.durationColumn, flex: 5),
            _TableHeader(label: AppStrings.restColumn, flex: 2),
            AppWhiteSpace.custom(width: AppSizing.handleWidth),
          ],
        );
    }
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: AppExerciseConfigTokens.labelTracking,
          ),
        ),
      ),
    );
  }
}

class _SetTableRow extends StatefulWidget {
  const _SetTableRow({
    super.key,
    required this.set,
    required this.setTypeOptions,
    required this.loggingType,
    required this.onUpdate,
    required this.onRemove,
  });

  final SetPrescriptionDraft set;
  final List<SetTypeOption> setTypeOptions;
  final ExerciseLoggingType loggingType;
  final ValueChanged<SetPrescriptionDraft> onUpdate;
  final VoidCallback onRemove;

  @override
  State<_SetTableRow> createState() => _SetTableRowState();
}

class _SetTableRowState extends State<_SetTableRow> {
  late final TextEditingController _repsController;
  late final TextEditingController _targetController;
  late final TextEditingController _weightController;
  late final TextEditingController _restController;
  late final TextEditingController _durationController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _targetController = TextEditingController();
    _weightController = TextEditingController();
    _restController = TextEditingController();
    _durationController = TextEditingController();
    _syncControllers();
    _repsController.addListener(_onRepsChanged);
    _targetController.addListener(_onTargetChanged);
    _weightController.addListener(_onWeightChanged);
    _restController.addListener(_onRestChanged);
    _durationController.addListener(_onDurationChanged);
  }

  @override
  void didUpdateWidget(_SetTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.set.id != oldWidget.set.id ||
        widget.set.setIndex != oldWidget.set.setIndex ||
        widget.set.prescribedRepsMin != oldWidget.set.prescribedRepsMin ||
        widget.set.prescribedRepsMax != oldWidget.set.prescribedRepsMax ||
        widget.set.prescribedRepsExact != oldWidget.set.prescribedRepsExact ||
        widget.set.prescribedRpeMin != oldWidget.set.prescribedRpeMin ||
        widget.set.prescribedRpeMax != oldWidget.set.prescribedRpeMax ||
        widget.set.prescribedRir != oldWidget.set.prescribedRir ||
        widget.set.prescribedWeightKg != oldWidget.set.prescribedWeightKg ||
        widget.set.restSeconds != oldWidget.set.restSeconds ||
        widget.set.durationSeconds != oldWidget.set.durationSeconds) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _targetController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  static String _formatWeight(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toString();
  }

  static String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null) return '';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static int? _parseDuration(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null) return null;
    return minutes * 60 + seconds;
  }

  void _syncControllers() {
    _isSyncing = true;
    _repsController.text = _formatReps();
    _targetController.text = _formatTarget();
    _weightController.text = widget.set.prescribedWeightKg != null
        ? _formatWeight(widget.set.prescribedWeightKg!)
        : '';
    _restController.text = widget.set.restSeconds?.toString() ?? '';
    _durationController.text = _formatDuration(widget.set.durationSeconds);
    _isSyncing = false;
  }

  String _formatReps() {
    final min = widget.set.prescribedRepsMin;
    final max = widget.set.prescribedRepsMax;
    final exact = widget.set.prescribedRepsExact;
    if (exact != null) return '$exact';
    if (min != null && max != null) return '$min-$max';
    if (min != null) return '$min';
    return '';
  }

  String _formatTarget() {
    final rpeMin = widget.set.prescribedRpeMin;
    final rpeMax = widget.set.prescribedRpeMax;
    final rir = widget.set.prescribedRir;
    if (rpeMin != null) {
      final min = _formatWeight(rpeMin);
      final max = rpeMax == null || rpeMax == rpeMin
          ? ''
          : '-${_formatWeight(rpeMax)}';
      return '${AppStrings.rpe} $min$max';
    }
    if (rir != null) return '${AppStrings.rir} $rir';
    return '';
  }

  void _onRepsChanged() {
    if (_isSyncing) return;
    final text = _repsController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearReps());
      return;
    }
    final parts = text.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0].trim());
      final max = int.tryParse(parts[1].trim());
      if (min != null && max != null) {
        widget.onUpdate(
          widget.set.clearReps().copyWith(
            prescribedRepsMin: min,
            prescribedRepsMax: max,
          ),
        );
      }
    } else {
      final exact = int.tryParse(parts[0].trim());
      widget.onUpdate(
        widget.set.clearReps().copyWith(prescribedRepsExact: exact),
      );
    }
  }

  void _onTargetChanged() {
    if (_isSyncing) return;
    final text = _targetController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearTarget());
      return;
    }
    final upper = text.toUpperCase();
    if (upper.startsWith('RPE')) {
      final numbers = text.substring(3).trim().split('-');
      if (numbers.length == 1 || numbers.length == 2) {
        final min = double.tryParse(numbers.first.trim());
        final max = numbers.length == 1
            ? min
            : double.tryParse(numbers.last.trim());
        if (min != null && max != null) {
          widget.onUpdate(
            widget.set.clearTarget().copyWith(
              prescribedRpeMin: min,
              prescribedRpeMax: max,
            ),
          );
        }
      }
    } else if (upper.startsWith('RIR')) {
      final rir = int.tryParse(text.substring(3).trim());
      if (rir != null) {
        widget.onUpdate(widget.set.clearTarget().copyWith(prescribedRir: rir));
      }
    } else if (text.contains('-')) {
      final parts = text.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].trim());
        final max = double.tryParse(parts[1].trim());
        if (min != null && max != null) {
          widget.onUpdate(
            widget.set.clearTarget().copyWith(
              prescribedRpeMin: min,
              prescribedRpeMax: max,
            ),
          );
        }
      }
    } else {
      final rir = int.tryParse(text);
      if (rir != null) {
        widget.onUpdate(widget.set.clearTarget().copyWith(prescribedRir: rir));
      }
    }
  }

  void _onWeightChanged() {
    if (_isSyncing) return;
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearWeight());
      return;
    }
    final value = double.tryParse(text);
    if (value != null) {
      widget.onUpdate(widget.set.copyWith(prescribedWeightKg: value));
    }
  }

  void _onRestChanged() {
    if (_isSyncing) return;
    final text = _restController.text.trim();
    if (text.isEmpty) {
      widget.onUpdate(widget.set.clearRest());
      return;
    }
    final value = int.tryParse(text);
    if (value != null) {
      widget.onUpdate(widget.set.copyWith(restSeconds: value));
    }
  }

  void _onDurationChanged() {
    if (_isSyncing) return;
    final seconds = _parseDuration(_durationController.text);
    if (seconds == null) {
      widget.onUpdate(widget.set.clearDuration());
      return;
    }
    widget.onUpdate(widget.set.copyWith(durationSeconds: seconds));
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.set;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: set.setIndex == 0
                ? AppSpacing.xs + AppSpacing.sm
                : AppSpacing.xxs + AppSpacing.xs,
            bottom: AppSpacing.xxs + AppSpacing.xs,
          ),
          child: Row(
            spacing: AppSpacing.xs,
            children: _buildRowCells(context, set),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRowCells(BuildContext context, SetPrescriptionDraft set) {
    final cs = context.colorScheme;

    switch (widget.loggingType) {
      case ExerciseLoggingType.repsWeight:
        return [
          _setNumber(set),
          _setTypeChip(set, cs),
          _weightInput(cs),
          _repsInput(cs),
          _targetInput(cs),
          _restInput(cs),
          _deleteButton(cs),
        ];

      case ExerciseLoggingType.repsOnly:
        return [
          _setNumber(set),
          _repsInput(cs),
          const Expanded(flex: 6, child: SizedBox.shrink()),
          _restInput(cs),
          _deleteButton(cs),
        ];

      case ExerciseLoggingType.duration:
        return [
          _setNumber(set),
          _durationInput(cs),
          _restInput(cs),
          _deleteButton(cs),
        ];
    }
  }

  Widget _setNumber(SetPrescriptionDraft set) {
    final cs = context.colorScheme;
    return Expanded(
      flex: 1,
      child: Text(
        '${set.setIndex + 1}',
        style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _setTypeChip(SetPrescriptionDraft set, ColorScheme cs) {
    return Expanded(
      flex: 3,
      child: GestureDetector(
        key: ValueKey('exercise_config_type_${set.id}'),
        onTap: () {
          final newType = set.setType == SetType.working
              ? SetType.warmup
              : SetType.working;
          widget.onUpdate(set.copyWith(setType: newType));
        },
        child: Container(
          height:
              AppExerciseConfigTokens.fieldHeight *
              MediaQuery.textScalerOf(context).scale(1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: set.setType == SetType.working
                ? cs.secondary.withValues(alpha: 0.1)
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            set.setType == SetType.working
                ? AppStrings.setTypeWorking
                : AppStrings.setTypeWarmup,
            style: AppTextStyles.labelSm.copyWith(
              color: set.setType == SetType.working
                  ? cs.secondary
                  : cs.onSurfaceVariant,
              fontSize: AppFontSizes.xxs,
            ),
          ),
        ),
      ),
    );
  }

  Widget _weightInput(ColorScheme cs) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        height:
            AppExerciseConfigTokens.fieldHeight *
            MediaQuery.textScalerOf(context).scale(1),
        child: AppTextField(
          key: ValueKey('exercise_config_weight_${widget.set.id}'),
          controller: _weightController,
          keyboardType: TextInputType.number,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.sm,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurface,
            fontSize: AppFontSizes.sm,
          ),
        ),
      ),
    );
  }

  Widget _repsInput(ColorScheme cs) {
    return Expanded(
      flex: 2,
      child: SizedBox(
        height:
            AppExerciseConfigTokens.fieldHeight *
            MediaQuery.textScalerOf(context).scale(1),
        child: AppTextField(
          key: ValueKey('exercise_config_reps_${widget.set.id}'),
          controller: _repsController,
          keyboardType: TextInputType.text,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.sm,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurface,
            fontSize: AppFontSizes.sm,
          ),
        ),
      ),
    );
  }

  Widget _targetInput(ColorScheme cs) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        height:
            AppExerciseConfigTokens.fieldHeight *
            MediaQuery.textScalerOf(context).scale(1),
        child: AppTextField(
          key: ValueKey('exercise_config_target_${widget.set.id}'),
          controller: _targetController,
          hintText: AppStrings.rpeHint,
          keyboardType: TextInputType.text,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.sm,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurface,
            fontSize: AppFontSizes.sm,
          ),
        ),
      ),
    );
  }

  Widget _restInput(ColorScheme cs) {
    return Expanded(
      flex: 2,
      child: SizedBox(
        height:
            AppExerciseConfigTokens.fieldHeight *
            MediaQuery.textScalerOf(context).scale(1),
        child: AppTextField(
          key: ValueKey('exercise_config_rest_${widget.set.id}'),
          controller: _restController,
          keyboardType: TextInputType.number,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.sm,
          style: AppTextStyles.labelSm.copyWith(
            color: cs.onSurface,
            fontSize: AppFontSizes.sm,
          ),
        ),
      ),
    );
  }

  Widget _durationInput(ColorScheme cs) {
    return Expanded(
      flex: 5,
      child: SizedBox(
        height:
            AppExerciseConfigTokens.fieldHeight *
            MediaQuery.textScalerOf(context).scale(1),
        child: Row(
          children: [
            Expanded(
              child: AppTextField(
                key: ValueKey('exercise_config_duration_${widget.set.id}'),
                controller: _durationController,
                keyboardType: TextInputType.text,
                hintText: AppStrings.durationInputHint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                borderRadius: AppRadius.sm,
                style: AppTextStyles.labelSm.copyWith(
                  color: cs.onSurface,
                  fontSize: AppFontSizes.sm,
                ),
              ),
            ),
            AppWhiteSpace.wXs,
            Text(
              AppStrings.durationUnit,
              style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteButton(ColorScheme cs) {
    return SizedBox(
      width: AppSizing.handleWidth,
      child: IconButton(
        icon: SvgPicture.asset(
          OutlinedSvgAssets.trash,
          width: AppSizing.iconXs,
          height: AppSizing.iconXs,
          colorFilter: ColorFilter.mode(
            cs.onSurfaceVariant.withValues(alpha: 0.5),
            BlendMode.srcIn,
          ),
        ),
        onPressed: widget.onRemove,
        tooltip: AppStrings.removeSet,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSpacing.xl,
          minHeight: AppSpacing.xl,
        ),
      ),
    );
  }
}

class _CoachNotesField extends StatefulWidget {
  const _CoachNotesField({
    required this.exerciseId,
    required this.initialNotes,
    required this.onChanged,
  });

  final String exerciseId;
  final String? initialNotes;
  final ValueChanged<String?> onChanged;

  @override
  State<_CoachNotesField> createState() => _CoachNotesFieldState();
}

class _CoachNotesFieldState extends State<_CoachNotesField> {
  late final TextEditingController _controller;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(_CoachNotesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exerciseId != oldWidget.exerciseId ||
        widget.initialNotes != oldWidget.initialNotes) {
      if (widget.initialNotes != _controller.text) {
        _isSyncing = true;
        _controller.text = widget.initialNotes ?? '';
        _isSyncing = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_isSyncing) return;
    widget.onChanged(_controller.text.isNotEmpty ? _controller.text : null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.coachNotes,
            style: AppTextStyles.labelSm.copyWith(color: cs.onSurface),
          ),
          AppWhiteSpace.hSm,
          AppTextField(
            key: const ValueKey('exercise_config_notes'),
            controller: _controller,
            hintText: AppStrings.coachNotesHint,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
