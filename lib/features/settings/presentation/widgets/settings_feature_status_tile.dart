import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class SettingsFeatureStatusTile extends StatelessWidget {
  const SettingsFeatureStatusTile({
    super.key,
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: enabled
                  ? context.colorScheme.tertiaryContainer
                  : context.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              enabled ? AppStrings.enabled : AppStrings.disabled,
              style: AppTextStyles.labelSm.copyWith(
                color: enabled
                    ? context.colorScheme.onTertiaryContainer
                    : context.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
