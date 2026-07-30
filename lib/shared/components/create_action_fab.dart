import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class CreateActionFab extends StatelessWidget {
  const CreateActionFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      key: const Key('create_action_fab'),
      onTap: onPressed,
      child: Container(
        width: AppSizing.cardBadge,
        height: AppSizing.cardBadge,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: AppSpacing.md,
              offset: const Offset(0, AppSpacing.xs),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            OutlinedSvgAssets.plusSmall,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              colorScheme.onSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
