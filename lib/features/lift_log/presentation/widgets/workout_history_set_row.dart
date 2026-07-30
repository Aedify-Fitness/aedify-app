import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_type_chip.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutHistorySetRow extends StatelessWidget {
  const WorkoutHistorySetRow({super.key, required this.item});

  final WorkoutHistorySetItem item;

  @override
  Widget build(BuildContext context) {
    final isWarmup = item.setType == SetType.warmup;
    final actualValues = _actualValues();
    final plannedValues = _plannedValues();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isWarmup
            ? context.colorScheme.tertiaryContainer.withValues(alpha: 0.18)
            : context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: isWarmup ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                SetTypeChip(setType: item.setType),
                AppBadge(
                  label: _statusLabel(),
                  backgroundColor: _statusBackground(context),
                  foregroundColor: _statusForeground(context),
                  borderRadius: AppRadius.full,
                ),
              ],
            ),
            if (actualValues.isNotEmpty) ...[
              AppWhiteSpace.hSm,
              _SetValues(label: AppStrings.actual, values: actualValues),
            ],
            if (plannedValues.isNotEmpty) ...[
              AppWhiteSpace.hSm,
              _SetValues(label: AppStrings.planned, values: plannedValues),
            ],
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              AppWhiteSpace.hSm,
              Text(
                '${AppStrings.setNotes}: ${item.notes}',
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    if (item.skipped) return AppStrings.skipped;
    if (item.completed) return AppStrings.completed;
    return AppStrings.inProgressLabel;
  }

  Color _statusBackground(BuildContext context) {
    if (item.skipped) return context.colorScheme.surfaceContainerHighest;
    if (item.completed) return context.colorScheme.secondaryContainer;
    return context.colorScheme.tertiaryContainer;
  }

  Color _statusForeground(BuildContext context) {
    if (item.skipped) return context.colorScheme.onSurfaceVariant;
    if (item.completed) return context.colorScheme.onSecondaryContainer;
    return context.colorScheme.onTertiaryContainer;
  }

  List<String> _actualValues() {
    return [
      if (item.actualReps != null)
        '${item.actualReps} ${AppStrings.repsLabel.toLowerCase()}',
      if (item.actualWeightKg != null)
        '${item.actualWeightKg!.toStringAsFixed(1)} '
            '${AppStrings.metricWeightUnit}',
      if (item.actualRpe != null)
        '${AppStrings.rpe} ${item.actualRpe!.toStringAsFixed(1)}',
      if (item.actualRir != null) '${AppStrings.rir} ${item.actualRir}',
    ];
  }

  List<String> _plannedValues() {
    final reps = _prescribedReps();
    return [
      if (reps != null) '$reps ${AppStrings.repsLabel.toLowerCase()}',
      if (item.prescribedWeightKg != null)
        '${item.prescribedWeightKg!.toStringAsFixed(1)} '
            '${AppStrings.metricWeightUnit}',
    ];
  }

  String? _prescribedReps() {
    final minimum = item.prescribedRepsMin;
    final maximum = item.prescribedRepsMax;
    if (minimum == null && maximum == null) return null;
    if (minimum == null) return '$maximum';
    if (maximum == null || minimum == maximum) return '$minimum';
    return '$minimum-$maximum';
  }
}

class _SetValues extends StatelessWidget {
  const _SetValues({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxs,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xxs,
          children: values
              .map(
                (value) => Text(
                  value,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
