import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Keeps recoverable session failures visible without replacing logged work.
class WorkoutRunnerErrorBanner extends StatelessWidget {
  const WorkoutRunnerErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppWorkoutRunnerTokens.innerMaxContentWidth,
        ),
        child: Semantics(
          liveRegion: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: WorkoutRunnerStyle.body(
                    context,
                  ).copyWith(color: context.colorScheme.onErrorContainer),
                ),
                if (onRetry != null) ...[
                  AppWhiteSpace.hSm,
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.onErrorContainer,
                      minimumSize: const Size.fromHeight(
                        AppWorkoutRunnerTokens.controlSize,
                      ),
                      textStyle: WorkoutRunnerStyle.label(
                        context,
                      ).copyWith(inherit: false),
                    ),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
