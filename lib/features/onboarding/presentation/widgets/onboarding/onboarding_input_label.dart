import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingInputLabel extends StatelessWidget {
  const OnboardingInputLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMd.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
