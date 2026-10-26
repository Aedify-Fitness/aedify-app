import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
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
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: CustomExerciseEditorStyle.body(
                context,
              ).copyWith(color: context.colorScheme.onErrorContainer),
            ),
            if (onRetry != null) ...[
              AppWhiteSpace.hSm,
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.onErrorContainer,
                  minimumSize: const Size.fromHeight(
                    AppCustomExerciseEditorTokens.controlSize,
                  ),
                  textStyle: CustomExerciseEditorStyle.label(
                    context,
                  ).copyWith(inherit: false),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
