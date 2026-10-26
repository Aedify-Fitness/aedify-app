import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_visuals.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutHistorySetRow extends StatelessWidget {
  const WorkoutHistorySetRow({super.key, required this.item, this.onEdit});
  final WorkoutHistorySetItem item;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final actual = _actualValues();
    final planned = _plannedValues();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppStrings.setNumberLabel(item.setIndex + 1),
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            HistoryPill(
              label: item.setType == SetType.warmup
                  ? AppStrings.warmupSet
                  : AppStrings.workingSet,
            ),
            if (!item.hasCompletedLog)
              Text(
                item.skipped
                    ? AppStrings.skipped
                    : WorkoutHistoryStrings.notLogged,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            if (onEdit != null)
              TextButton.icon(
                key: ValueKey('history_correct_${item.id}'),
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    AppWorkoutHistoryTokens.controlSize,
                    AppWorkoutHistoryTokens.controlSize,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                icon: HistoryIcon(
                  asset: OutlinedSvgAssets.pencil,
                  color: context.colorScheme.secondary,
                  size: AppSizing.iconS,
                ),
                label: const Text(
                  WorkoutHistoryStrings.correctSet,
                  style: AppTextStyles.labelMd,
                ),
              ),
          ],
        ),
        if (actual.isNotEmpty) ...[
          AppWhiteSpace.hSm,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (final value in actual)
                Text(
                  value,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ],
        if (planned.isNotEmpty) ...[
          AppWhiteSpace.hSm,
          Text(
            '${AppStrings.planned} · ${planned.join(' · ')}',
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (item.notes?.trim().isNotEmpty ?? false) ...[
          AppWhiteSpace.hSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HistoryIcon(
                asset: OutlinedSvgAssets.chatBubbleLeft,
                size: AppSizing.iconS,
              ),
              AppWhiteSpace.wSm,
              Expanded(
                child: Text(
                  item.notes!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<String> _actualValues() {
    if (!item.hasCompletedLog) return [];
    final rpe = item.actualRpe ?? SetEffort.rpeFromRir(item.actualRir);
    return [
      if (item.resolvedLoggingType != ExerciseLoggingType.duration &&
          item.actualReps != null)
        '${item.actualReps} ${AppStrings.repsLabel.toLowerCase()}',
      if (item.resolvedLoggingType == ExerciseLoggingType.repsWeight &&
          item.actualWeightKg != null)
        '${item.actualWeightKg!.toStringAsFixed(1)} ${AppStrings.metricWeightUnit}',
      if (item.resolvedLoggingType == ExerciseLoggingType.duration &&
          item.actualDurationSeconds != null)
        '${item.actualDurationSeconds}${AppStrings.secondsUnitAbbreviation}',
      if (item.resolvedLoggingType == ExerciseLoggingType.duration &&
          item.actualDistanceMeters != null)
        '${item.actualDistanceMeters} ${WorkoutHistoryStrings.metersUnit}',
      if (rpe != null) '${AppStrings.rpe} ${rpe.toStringAsFixed(1)}',
    ];
  }

  List<String> _plannedValues() {
    final reps = _prescribedReps();
    final rpe = SetEffort.rpeFromRir(item.prescribedRir);
    return [
      if (item.resolvedLoggingType != ExerciseLoggingType.duration &&
          reps != null)
        '$reps ${AppStrings.repsLabel.toLowerCase()}',
      if (item.resolvedLoggingType == ExerciseLoggingType.repsWeight &&
          item.prescribedWeightKg != null)
        '${item.prescribedWeightKg!.toStringAsFixed(1)} ${AppStrings.metricWeightUnit}',
      if (item.resolvedLoggingType == ExerciseLoggingType.duration &&
          item.prescribedDurationSeconds != null)
        '${item.prescribedDurationSeconds}${AppStrings.secondsUnitAbbreviation}',
      if (item.resolvedLoggingType == ExerciseLoggingType.duration &&
          item.prescribedDistanceMeters != null)
        '${item.prescribedDistanceMeters} ${WorkoutHistoryStrings.metersUnit}',
      if (rpe != null) '${AppStrings.rpe} ${rpe.toStringAsFixed(0)}',
    ];
  }

  String? _prescribedReps() {
    if (item.prescribedRepsExact != null) return '${item.prescribedRepsExact}';
    final min = item.prescribedRepsMin;
    final max = item.prescribedRepsMax;
    if (min != null && max != null) return min == max ? '$min' : '$min–$max';
    return min?.toString() ?? max?.toString();
  }
}
