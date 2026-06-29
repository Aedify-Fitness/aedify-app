import 'package:aedify/features/bodymap/data/bodymap_asset_contract.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodymapSvgView extends StatelessWidget {
  const BodymapSvgView({
    super.key,
    required this.side,
    required this.selectedBucket,
    required this.onBucketSelected,
  });

  final BodymapViewSide side;
  final BodymapBucket? selectedBucket;
  final ValueChanged<BodymapBucket> onBucketSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mapping = BodymapAssetContract.mappingForSide(side);

    return Column(
      children: [
        Text(
          side == BodymapViewSide.front
              ? AppStrings.bodymapFront
              : AppStrings.bodymapBack,
          style: context.textTheme.titleSmall,
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: AppSizing.bodymapSvgWidth,
            height: AppSizing.bodymapSvgHeight,
            child: GestureDetector(
              onTapDown: (details) {
                final renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox == null) return;
                final localPosition = renderBox.globalToLocal(
                  details.globalPosition,
                );
                _handleTap(localPosition, renderBox.size, mapping);
              },
              child: SvgPicture.asset(
                BodymapAssetContract.assetPathForSide(side),
                width: AppSizing.bodymapSvgWidth,
                height: AppSizing.bodymapSvgHeight,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTap(
    Offset localPosition,
    Size svgSize,
    Map<String, BodymapBucket> mapping,
  ) {
    // Placeholder: SVG path hit-testing is approximated by bucket chip selection.
    // Tap on the SVG surface is a visual hint; actual bucket selection
    // happens via the chip bar below.
  }
}
