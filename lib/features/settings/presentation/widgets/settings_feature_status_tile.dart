import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsFeatureStatusTile extends StatelessWidget {
  const SettingsFeatureStatusTile({
    super.key,
    required this.label,
    required this.enabled,
    required this.leadingAsset,
  });

  final String label;
  final bool enabled;
  final String leadingAsset;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: label,
      subtitle: enabled ? AppStrings.enabled : AppStrings.disabled,
      leadingAsset: leadingAsset,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? context.colorScheme.tertiaryContainer
              : context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              enabled
                  ? OutlinedSvgAssets.checkCircle
                  : OutlinedSvgAssets.noSymbol,
              width: AppSizing.iconXs,
              height: AppSizing.iconXs,
              colorFilter: ColorFilter.mode(
                enabled
                    ? context.colorScheme.onTertiaryContainer
                    : context.colorScheme.onErrorContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wXs,
            Text(
              enabled ? AppStrings.enabled : AppStrings.disabled,
              style: AppTextStyles.labelSm.copyWith(
                color: enabled
                    ? context.colorScheme.onTertiaryContainer
                    : context.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
