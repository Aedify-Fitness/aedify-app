import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.svgAsset,
    this.message,
  });

  final String title;
  final String? svgAsset;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgAsset != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SvgPicture.asset(
                    svgAsset!,
                    width: AppSizing.iconLg,
                    height: AppSizing.iconLg,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              Text(title, style: context.textTheme.headlineSmall),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
