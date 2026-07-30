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
    final sideLabel = side == BodymapViewSide.front
        ? AppStrings.bodymapFront
        : AppStrings.bodymapBack;

    return Semantics(
      key: ValueKey<String>('bodymap_svg_${side.name}'),
      image: true,
      label: sideLabel,
      value: selectedBucket?.label,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: double.infinity,
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
              width: double.infinity,
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
    );
  }

  void _handleTap(
    Offset localPosition,
    Size svgSize,
    Map<String, BodymapBucket> mapping,
  ) {
    // SVG path hit-testing remains intentionally unavailable. The anatomical
    // surface is visual; bucket selection happens through the pill selector.
  }
}
