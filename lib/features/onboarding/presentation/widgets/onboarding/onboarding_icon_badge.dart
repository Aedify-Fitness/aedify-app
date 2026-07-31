import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingIconBadge extends StatelessWidget {
  const OnboardingIconBadge({
    super.key,
    required this.iconAsset,
    required this.accent,
    this.iconColor,
  });

  final String iconAsset;
  final Color accent;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Container(
      width: AppSizing.cardBadge,
      height: AppSizing.cardBadge,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        iconAsset,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(
          iconColor ?? defaultIconColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
