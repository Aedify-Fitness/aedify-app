import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutBuilderErrorBanner extends StatelessWidget {
  const WorkoutBuilderErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: context.theme.brightness == Brightness.light
          ? AedifyLightColors.errorSurface
          : AedifyDarkColors.errorSurface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(AppStrings.retry)),
        ],
      ),
    );
  }
}
