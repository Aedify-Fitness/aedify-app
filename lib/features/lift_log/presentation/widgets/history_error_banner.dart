import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class HistoryErrorBanner extends StatelessWidget {
  const HistoryErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.error,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(message),
          if (onRetry != null) ...[
            AppWhiteSpace.hMd,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
