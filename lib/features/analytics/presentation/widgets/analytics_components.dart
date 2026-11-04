import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_button_styles.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AnalyticsStyles {
  static Color accent(BuildContext context) =>
      context.theme.brightness == Brightness.dark
      ? context.colorScheme.primary
      : context.colorScheme.secondary;
  static TextStyle body(BuildContext context) =>
      (context.theme.brightness == Brightness.dark
              ? AppTextStylesDark.bodyMd
              : AppTextStyles.bodyMd)
          .copyWith(color: context.colorScheme.onSurface);
  static TextStyle small(BuildContext context) =>
      (context.theme.brightness == Brightness.dark
              ? AppTextStylesDark.bodySm
              : AppTextStyles.bodySm)
          .copyWith(color: context.colorScheme.onSurfaceVariant);
  static TextStyle label(BuildContext context) =>
      (context.theme.brightness == Brightness.dark
              ? AppTextStylesDark.labelMd
              : AppTextStyles.labelMd)
          .copyWith(color: context.colorScheme.onSurface);
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({
    super.key,
    required this.children,
    required this.onRefresh,
  });
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizing.analyticsMaxWidth,
          ),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              key: const Key('analytics_scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: AppBottomNavigationScope.contentClearance(
                  context,
                  fallback:
                      AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                ),
              ),
              itemCount: children.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: children[index],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AnalyticsHeader extends StatelessWidget {
  const AnalyticsHeader({
    super.key,
    required this.title,
    required this.onRefresh,
    this.onBack,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final VoidCallback onRefresh;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          if (onBack != null)
            AnalyticsIconButton(
              asset: OutlinedSvgAssets.arrowLeft,
              label: AppStrings.backLabel,
              onPressed: onBack!,
            ),
          Expanded(
            child: Text(
              title,
              style:
                  (context.theme.brightness == Brightness.dark
                          ? AppTextStylesDark.headlineLgMobile
                          : AppTextStyles.headlineLgMobile)
                      .copyWith(color: context.colorScheme.onSurface),
            ),
          ),
          AnalyticsIconButton(
            asset: OutlinedSvgAssets.arrowPath,
            label: AnalyticsStrings.refresh,
            onPressed: onRefresh,
          ),
        ],
      ),
      if (subtitle != null) ...[
        AppWhiteSpace.hSm,
        Text(subtitle!, style: AnalyticsStyles.small(context)),
      ],
    ],
  );
}

class AnalyticsIconButton extends StatelessWidget {
  const AnalyticsIconButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onPressed,
  });
  final String asset;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: AppSpacing.xxl,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: SvgPicture.asset(
        asset,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}

class AnalyticsPanel extends StatelessWidget {
  const AnalyticsPanel({
    super.key,
    required this.child,
    this.emphasized = false,
  });
  final Widget child;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Material(
    color: emphasized
        ? context.colorScheme.surfaceContainer
        : context.colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: child,
    ),
  );
}

class AnalyticsSectionTitle extends StatelessWidget {
  const AnalyticsSectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: AppTextStyles.headlineMd.copyWith(
      color: context.colorScheme.onSurface,
    ),
  );
}

class AnalyticsRangePicker extends StatelessWidget {
  const AnalyticsRangePicker({
    super.key,
    required this.range,
    required this.onChanged,
  });
  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final option in AnalyticsRange.values)
        ChoiceChip(
          key: ValueKey('analytics_range_${option.name}'),
          label: Text(AnalyticsFormat.range(option)),
          labelStyle: AnalyticsStyles.label(context).copyWith(
            color: option == range
                ? context.theme.brightness == Brightness.dark
                      ? context.colorScheme.onPrimaryContainer
                      : context.colorScheme.onSecondaryContainer
                : context.colorScheme.onSurfaceVariant,
          ),
          selectedColor: context.theme.brightness == Brightness.dark
              ? context.colorScheme.primaryContainer
              : context.colorScheme.secondaryContainer,
          backgroundColor: context.colorScheme.surfaceContainerLow,
          side: BorderSide.none,
          shape: const StadiumBorder(),
          showCheckmark: false,
          selected: option == range,
          onSelected: (_) => onChanged(option),
        ),
    ],
  );
}

class AnalyticsMessage extends StatelessWidget {
  const AnalyticsMessage({
    super.key,
    required this.message,
    this.title,
    this.action,
    this.onAction,
    this.error = false,
  });
  final String message;
  final String? title;
  final String? action;
  final VoidCallback? onAction;
  final bool error;
  @override
  Widget build(BuildContext context) => AnalyticsPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          AnalyticsSectionTitle(title!),
          AppWhiteSpace.hSm,
        ],
        Text(
          message,
          style: AnalyticsStyles.body(
            context,
          ).copyWith(color: error ? context.colorScheme.error : null),
        ),
        if (action != null && onAction != null) ...[
          AppWhiteSpace.hMd,
          FilledButton(
            style: AppButtonStyles.primary(
              context,
              minimumHeight: AppSpacing.xxl,
            ),
            onPressed: onAction,
            child: Text(action!),
          ),
        ],
      ],
    ),
  );
}

class AnalyticsMetric extends StatelessWidget {
  const AnalyticsMetric({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: AppSizing.metricTileMinWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hXs,
        Text(label, style: AnalyticsStyles.small(context)),
      ],
    ),
  );
}

class AnalyticsLoading extends StatelessWidget {
  const AnalyticsLoading({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Center(
      child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
    ),
  );
}
