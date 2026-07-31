import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class OnboardingIntroHeader extends StatelessWidget {
  final String title;
  final String description;
  const OnboardingIntroHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineXl.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          description,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXl,
      ],
    );
  }
}
