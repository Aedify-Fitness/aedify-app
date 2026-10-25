import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_button_styles.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A temporary, explicit editor for one existing completed-session set.
class WorkoutHistoryCorrectionSheet extends ConsumerStatefulWidget {
  const WorkoutHistoryCorrectionSheet({
    super.key,
    required this.sessionId,
    required this.item,
    this.exerciseName,
  });

  final String sessionId;
  final WorkoutHistorySetItem item;
  final String? exerciseName;

  @override
  ConsumerState<WorkoutHistoryCorrectionSheet> createState() =>
      _WorkoutHistoryCorrectionSheetState();
}

class _WorkoutHistoryCorrectionSheetState
    extends ConsumerState<WorkoutHistoryCorrectionSheet> {
  late final Map<String, TextEditingController> _fields;
  String? _validation;
  final _errorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final type = item.resolvedLoggingType;
    _fields = {
      if (type != ExerciseLoggingType.duration)
        AppStrings.actualReps: TextEditingController(
          text: item.actualReps?.toString() ?? '',
        ),
      if (type == ExerciseLoggingType.repsWeight)
        AppStrings.actualWeight: TextEditingController(
          text: item.actualWeightKg?.toString() ?? '',
        ),
      if (type == ExerciseLoggingType.duration)
        WorkoutHistoryStrings.seconds: TextEditingController(
          text: item.actualDurationSeconds?.toString() ?? '',
        ),
      if (type == ExerciseLoggingType.duration)
        WorkoutHistoryStrings.meters: TextEditingController(
          text: item.actualDistanceMeters?.toString() ?? '',
        ),
      AppStrings.actualRpe: TextEditingController(
        text:
            (item.actualRpe ?? SetEffort.rpeFromRir(item.actualRir))
                ?.toString() ??
            '',
      ),
      AppStrings.setNotes: TextEditingController(text: item.notes ?? ''),
    };
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final invalidText = _fields.entries.any((entry) {
      if (entry.key == AppStrings.setNotes || entry.value.text.trim().isEmpty) {
        return false;
      }
      final integer =
          entry.key == AppStrings.actualReps ||
          entry.key == WorkoutHistoryStrings.seconds;
      return integer
          ? int.tryParse(entry.value.text.trim()) == null
          : double.tryParse(entry.value.text.trim()) == null;
    });
    final correction = WorkoutHistorySetCorrection(
      expected: widget.item,
      actualReps: _fields.containsKey(AppStrings.actualReps)
          ? int.tryParse(_fields[AppStrings.actualReps]!.text.trim())
          : widget.item.actualReps,
      actualWeightKg: _fields.containsKey(AppStrings.actualWeight)
          ? double.tryParse(_fields[AppStrings.actualWeight]!.text.trim())
          : widget.item.actualWeightKg,
      actualDurationSeconds: _fields.containsKey(WorkoutHistoryStrings.seconds)
          ? int.tryParse(_fields[WorkoutHistoryStrings.seconds]!.text.trim())
          : widget.item.actualDurationSeconds,
      actualDistanceMeters: _fields.containsKey(WorkoutHistoryStrings.meters)
          ? double.tryParse(_fields[WorkoutHistoryStrings.meters]!.text.trim())
          : widget.item.actualDistanceMeters,
      actualRpe: double.tryParse(_fields[AppStrings.actualRpe]!.text.trim()),
      actualRir: SetEffort.rirFromRpe(
        double.tryParse(_fields[AppStrings.actualRpe]!.text.trim()),
      ),
      notes: _fields[AppStrings.setNotes]!.text.trim().isEmpty
          ? null
          : _fields[AppStrings.setNotes]!.text.trim(),
    );
    if (invalidText || !correction.isValid) {
      setState(
        () => _validation = AppErrorStrings.workoutHistoryCorrectionInvalid,
      );
      _revealError();
      return;
    }
    setState(() => _validation = null);
    final saved = await ref
        .read(
          WorkoutHistoryProviders.correctionControllerProvider(
            widget.sessionId,
          ).notifier,
        )
        .save(correction);
    if (saved && mounted) context.pop();
    if (!saved && mounted) _revealError();
  }

  void _revealError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final errorContext = _errorKey.currentContext;
      if (mounted && errorContext != null) {
        Scrollable.ensureVisible(errorContext);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      WorkoutHistoryProviders.correctionControllerProvider(widget.sessionId),
    );
    final saving = state.isLoading;
    final error = _validation ?? state.asData?.value;
    final metrics = _fields.entries
        .where(
          (entry) =>
              entry.key != AppStrings.actualRpe &&
              entry.key != AppStrings.setNotes,
        )
        .toList();
    return PopScope(
      canPop: !saving,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height *
                  AppWorkoutHistoryTokens.sheetHeightFactor,
              maxWidth: AppWorkoutHistoryTokens.maxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    key: const Key('history_correction_scroll'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      WorkoutHistoryStrings.correctSet,
                                      style: AppTextStyles.headlineMd.copyWith(
                                        color: context.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: saving
                                        ? null
                                        : () => context.pop(),
                                    tooltip: AppStrings.close,
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size.square(
                                        AppWorkoutHistoryTokens.controlSize,
                                      ),
                                    ),
                                    icon: const HistoryIcon(
                                      asset: OutlinedSvgAssets.xMark,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.exerciseName != null) ...[
                                AppWhiteSpace.hXs,
                                Text(
                                  widget.exerciseName!,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              AppWhiteSpace.hSm,
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  HistoryPill(
                                    label: AppStrings.setNumberLabel(
                                      widget.item.setIndex + 1,
                                    ),
                                    emphasized: true,
                                  ),
                                  HistoryPill(
                                    label: widget.item.setType == SetType.warmup
                                        ? AppStrings.warmupSet
                                        : AppStrings.workingSet,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Text(
                          WorkoutHistoryStrings.correctionHint,
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (error != null) ...[
                          Semantics(
                            key: _errorKey,
                            liveRegion: true,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.controlGap,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Text(
                                error,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: context.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ),
                          AppWhiteSpace.hMd,
                        ],
                        AppWhiteSpace.hLg,
                        Text(
                          WorkoutHistoryStrings.results,
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        AppWhiteSpace.hMd,
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final paired =
                                constraints.maxWidth >=
                                    AppWorkoutHistoryTokens.formPairMinWidth &&
                                MediaQuery.textScalerOf(
                                          context,
                                        ).scale(AppFontSizes.md) /
                                        AppFontSizes.md <=
                                    AppWorkoutHistoryTokens.largeTextScale &&
                                metrics.length == 2;
                            final width = paired
                                ? (constraints.maxWidth -
                                          AppSpacing.controlGap) /
                                      2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: AppSpacing.controlGap,
                              runSpacing: AppSpacing.md,
                              children: [
                                for (final entry in metrics)
                                  SizedBox(
                                    width: width,
                                    child: _CorrectionInput(
                                      label: entry.key,
                                      controller: entry.value,
                                      enabled: !saving,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        AppWhiteSpace.hLg,
                        Text(
                          WorkoutHistoryStrings.effort,
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        AppWhiteSpace.hMd,
                        _CorrectionInput(
                          label: AppStrings.actualRpe,
                          controller: _fields[AppStrings.actualRpe]!,
                          enabled: !saving,
                        ),
                        AppWhiteSpace.hLg,
                        _CorrectionInput(
                          label: AppStrings.setNotes,
                          controller: _fields[AppStrings.setNotes]!,
                          enabled: !saving,
                        ),
                        AppWhiteSpace.hSm,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        key: const Key('history_save_correction'),
                        onPressed: saving ? null : _save,
                        style: AppButtonStyles.primary(
                          context,
                          minimumHeight: AppSizing.homePrimaryActionHeight,
                        ),
                        child: Text(
                          saving
                              ? AppStrings.loading
                              : WorkoutHistoryStrings.saveCorrection,
                        ),
                      ),
                      AppWhiteSpace.hXs,
                      TextButton(
                        onPressed: saving ? null : () => context.pop(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            AppWorkoutHistoryTokens.controlSize,
                          ),
                        ),
                        child: const Text(
                          AppStrings.cancel,
                          style: AppTextStyles.labelMd,
                        ),
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

class _CorrectionInput extends StatelessWidget {
  const _CorrectionInput({
    required this.label,
    required this.controller,
    required this.enabled,
  });
  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => AppTextField(
    key: ValueKey('history_correction_$label'),
    controller: controller,
    labelText: label == AppStrings.actualWeight
        ? '$label (${AppStrings.metricWeightUnit})'
        : label,
    suffixText: label == AppStrings.actualRpe
        ? WorkoutHistoryStrings.rpeRange
        : label == WorkoutHistoryStrings.meters
        ? AppStrings.customExerciseInstructionsOptional
        : null,
    enabled: enabled,
    filled: true,
    fillColor: context.colorScheme.surfaceContainerLow,
    keyboardType: label == AppStrings.setNotes
        ? TextInputType.multiline
        : const TextInputType.numberWithOptions(decimal: true),
    textInputAction: label == AppStrings.setNotes
        ? TextInputAction.newline
        : TextInputAction.next,
    maxLines: label == AppStrings.setNotes ? 3 : 1,
  );
}
