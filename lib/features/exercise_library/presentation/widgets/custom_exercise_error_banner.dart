import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomExerciseErrorBanner extends StatelessWidget {
  const CustomExerciseErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onErrorContainer,
            ),
          ),
          if (onRetry != null) ...[
            AppWhiteSpace.hSm,
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
