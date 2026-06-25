import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hMd,
          ...children,
        ],
      ),
    );
  }
}
