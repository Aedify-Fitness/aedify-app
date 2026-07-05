import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerResumeBanner extends StatelessWidget {
  const WorkoutRunnerResumeBanner({
    super.key,
    required this.onResume,
    required this.onDiscard,
  });

  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.recoverWorkoutMessage,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: onResume,
                  child: Text(AppStrings.recoverWorkout),
                ),
                AppWhiteSpace.wSm,
                OutlinedButton(
                  onPressed: onDiscard,
                  child: Text(AppStrings.cancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
