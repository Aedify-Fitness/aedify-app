import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryIcon extends StatelessWidget {
  const HistoryIcon({
    super.key,
    required this.asset,
    this.color,
    this.size = AppSizing.iconSm,
  });
  final String asset;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? context.colorScheme.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    ),
  );
}

class HistoryPill extends StatelessWidget {
  const HistoryPill({super.key, required this.label, this.emphasized = false});
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: emphasized
          ? context.colorScheme.secondary.withValues(
              alpha: AppWorkoutHistoryTokens.tintOpacity,
            )
          : context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: emphasized
              ? context.colorScheme.secondary
              : context.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class HistoryMetric extends StatelessWidget {
  const HistoryMetric({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(
      minWidth: AppWorkoutHistoryTokens.metricMinWidth,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        AppWhiteSpace.hXs,
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
