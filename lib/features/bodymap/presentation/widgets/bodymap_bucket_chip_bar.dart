import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodymapBucketChipBar extends StatelessWidget {
  const BodymapBucketChipBar({
    super.key,
    required this.selectedBucket,
    required this.onSelected,
    required this.onClear,
  });

  final BodymapBucket? selectedBucket;
  final ValueChanged<BodymapBucket> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ...BodymapBucket.values.map(
                (bucket) => ChoiceChip(
                  label: Text(
                    bucket.label,
                    style: const TextStyle(fontSize: AppFontSizes.xs),
                  ),
                  selected: selectedBucket == bucket,
                  onSelected: (isSelected) =>
                      isSelected ? onSelected(bucket) : onClear(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        if (selectedBucket != null) ...[
          SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: onClear,
              icon: SvgPicture.asset(
                OulinedSvgAssets.xMark,
                width: AppSizing.iconXs,
                height: AppSizing.iconXs,
              ),
              label: Text(AppStrings.clearSelection),
            ),
          ),
        ],
      ],
    );
  }
}
