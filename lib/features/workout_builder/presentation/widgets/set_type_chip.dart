import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class SetTypeChip extends StatelessWidget {
  const SetTypeChip({super.key, required this.setType});

  final SetType setType;

  @override
  Widget build(BuildContext context) {
    final isWarmup = setType == SetType.warmup;
    final label = isWarmup ? AppStrings.warmupSet : AppStrings.workingSet;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: isWarmup
            ? context.colorScheme.tertiaryContainer
            : context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: isWarmup
              ? context.colorScheme.onTertiaryContainer
              : context.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
