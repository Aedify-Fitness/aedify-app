import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class SupersetGroupBadge extends StatelessWidget {
  const SupersetGroupBadge({super.key, required this.groupId, this.order});

  final String groupId;
  final int? order;

  @override
  Widget build(BuildContext context) {
    final label = order != null
        ? '${AppStrings.superset} ${order! + 1}'
        : AppStrings.superset;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
