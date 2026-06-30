import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeBuilderErrorBanner extends ConsumerWidget {
  const ProgrammeBuilderErrorBanner({
    super.key,
    required this.errorCode,
    required this.errorMessage,
  });

  final String? errorCode;
  final String errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: context.theme.brightness == Brightness.light
          ? AedifyLightColors.errorSurface
          : AedifyDarkColors.errorSurface,
      child: Row(
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(errorMessage)),
          TextButton(onPressed: () {}, child: const Text(AppStrings.retry)),
        ],
      ),
    );
  }
}
