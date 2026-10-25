import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_correction.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
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
  });

  final String sessionId;
  final WorkoutHistorySetItem item;

  @override
  ConsumerState<WorkoutHistoryCorrectionSheet> createState() =>
      _WorkoutHistoryCorrectionSheetState();
}

class _WorkoutHistoryCorrectionSheetState
    extends ConsumerState<WorkoutHistoryCorrectionSheet> {
  late final Map<String, TextEditingController> _fields;
  String? _validation;

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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      WorkoutHistoryProviders.correctionControllerProvider(widget.sessionId),
    );
    final saving = state.isLoading;
    final error = _validation ?? state.asData?.value;
    return PopScope(
      canPop: !saving,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                WorkoutHistoryStrings.correctSet,
                style: AppTextStyles.headlineMd,
              ),
              AppWhiteSpace.hSm,
              Text(
                WorkoutHistoryStrings.correctionHint,
                style: AppTextStyles.bodySm,
              ),
              AppWhiteSpace.hMd,
              for (final entry in _fields.entries) ...[
                AppTextField(
                  key: ValueKey('history_correction_${entry.key}'),
                  controller: entry.value,
                  labelText: entry.key == AppStrings.actualWeight
                      ? '${entry.key} (${AppStrings.metricWeightUnit})'
                      : entry.key,
                  enabled: !saving,
                  keyboardType: entry.key == AppStrings.setNotes
                      ? TextInputType.multiline
                      : const TextInputType.numberWithOptions(decimal: true),
                  maxLines: entry.key == AppStrings.setNotes ? 3 : 1,
                ),
                AppWhiteSpace.hMd,
              ],
              if (error != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ),
                AppWhiteSpace.hMd,
              ],
              FilledButton(
                key: const Key('history_save_correction'),
                onPressed: saving ? null : _save,
                child: Text(
                  saving
                      ? AppStrings.loading
                      : WorkoutHistoryStrings.saveCorrection,
                ),
              ),
              TextButton(
                onPressed: saving ? null : () => context.pop(),
                child: const Text(AppStrings.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
