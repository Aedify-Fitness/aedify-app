import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class ExerciseDatasetSyncStatusCard extends StatelessWidget {
  const ExerciseDatasetSyncStatusCard({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.xxs,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleSmall),
                  AppWhiteSpace.hXxs,
                  Text(message, style: context.textTheme.bodySmall),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              AppWhiteSpace.wMd,
              FilledButton.tonal(
                onPressed: isLoading ? null : onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
