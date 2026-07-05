import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class FinishEarlyDialog extends StatefulWidget {
  const FinishEarlyDialog({
    super.key,
    required this.session,
    required this.onComplete,
  });

  final WorkoutRunnerSessionViewData session;
  final void Function(WorkoutRunnerCompletionDraft draft) onComplete;

  @override
  State<FinishEarlyDialog> createState() => _FinishEarlyDialogState();
}

class _FinishEarlyDialogState extends State<FinishEarlyDialog> {
  String? _selectedReason;

  static const _reasons = [
    AppStrings.finishEarlyReasonOutOfTime,
    AppStrings.finishEarlyReasonInjuryPain,
    AppStrings.finishEarlyReasonEquipmentIssue,
    AppStrings.finishEarlyReasonTooTired,
  ];

  int get _remainingExercises {
    var count = 0;
    for (final ex in widget.session.exercises) {
      var anyNotCompleted = false;
      for (final set in ex.sets) {
        if (!set.completed && !set.skipped) {
          anyNotCompleted = true;
          break;
        }
      }
      if (anyNotCompleted) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingExercises;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 448),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 50,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WarningIcon(),
                      AppWhiteSpace.hLg,
                      Text(
                        AppStrings.finishWorkoutEarly,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      AppWhiteSpace.hMd,
                      _buildMessage(context, remaining),
                      AppWhiteSpace.hXxl,
                      _buildReasonSection(context),
                      AppWhiteSpace.hXxl,
                      _buildActions(context, remaining),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, int remaining) {
    final parts = AppStrings.finishEarlyMessage.split('{remaining}');
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        children: [
          if (parts.length > 1)
            TextSpan(text: parts[0])
          else
            TextSpan(text: AppStrings.finishEarlyMessage),
          TextSpan(
            text: '$remaining',
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  Widget _buildReasonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.finishEarlyReason,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _reasons
              .map(
                (reason) => _ReasonChip(
                  label: reason,
                  isSelected: _selectedReason == reason,
                  onTap: () => setState(() => _selectedReason = reason),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, int remaining) {
    final now = DateTime.now();
    final duration =
        widget.session.durationSeconds ??
        now.difference(widget.session.startedAt).inSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              widget.onComplete(
                WorkoutRunnerCompletionDraft(
                  sessionId: widget.session.sessionId,
                  completedAt: now,
                  durationSeconds: duration,
                  notes: _selectedReason,
                  energyLevel: widget.session.energyLevel,
                  perceivedDifficulty: widget.session.perceivedDifficulty,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(
              AppStrings.finishAndSaveSession,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSecondary,
              ),
            ),
          ),
        ),
        AppWhiteSpace.hSm,
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: Text(
              AppStrings.resumeWorkout,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconXxl,
      height: AppSizing.iconXxl,
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.warning,
        color: context.colorScheme.secondary,
        size: AppSizing.iconMd,
        fill: 1,
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.secondary
              : context.colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: isSelected
                ? context.colorScheme.onSecondary
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
