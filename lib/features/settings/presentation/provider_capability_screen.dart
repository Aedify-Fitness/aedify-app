import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProviderCapabilityScreen extends ConsumerWidget {
  const ProviderCapabilityScreen({
    super.key,
    required this.providerName,
    required this.modelName,
  });

  final String providerName;
  final String modelName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = AiProviderName.fromDb(providerName);
    final controller = ref.watch(
      AppProviders.providerCapabilityControllerProvider((
        providerName: provider,
        modelName: modelName,
      )),
    );

    void retry() {
      ref.invalidate(
        AppProviders.providerCapabilityControllerProvider((
          providerName: provider,
          modelName: modelName,
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.providerCapabilityTitle)),
      body: controller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _UnavailableView(
          providerName: providerName,
          modelName: modelName,
          message: AppErrorStrings.providerCapabilityLoadFailedMessage,
          onRetry: retry,
        ),
        data: (state) {
          if (state.capability == null) {
            return _UnavailableView(
              providerName: providerName,
              modelName: modelName,
              message:
                  state.errorMessage ??
                  AppErrorStrings.providerCapabilityUnknownMessage,
              onRetry: retry,
            );
          }
          return _CapabilityContentView(capability: state.capability!);
        },
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({
    required this.providerName,
    required this.modelName,
    required this.message,
    required this.onRetry,
  });

  final String providerName;
  final String modelName;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              decoration: BoxDecoration(
                color: context.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                OutlinedSvgAssets.noSymbol,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onErrorContainer,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.providerCapabilityUnavailable,
              style: AppTextStyles.bodyLg.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hSm,
            Text(
              '$providerName / $modelName',
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hXs,
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(
                color: context.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowPath,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityContentView extends StatelessWidget {
  const _CapabilityContentView({required this.capability});

  final ProviderCapabilityViewData capability;

  @override
  Widget build(BuildContext context) {
    final capabilityCards = [
      _CapabilityCardData(
        id: 'text-input',
        label: AppStrings.capabilityTextInput,
        supported: capability.supportsTextInput,
      ),
      _CapabilityCardData(
        id: 'image-input',
        label: AppStrings.capabilityImageInput,
        supported: capability.supportsImageInput,
      ),
      _CapabilityCardData(
        id: 'json-schema',
        label: AppStrings.capabilityJsonSchemaMode,
        supported: capability.supportsJsonSchemaMode,
      ),
      _CapabilityCardData(
        id: 'streaming',
        label: AppStrings.capabilityStreaming,
        supported: capability.supportsStreaming,
      ),
      if (capability.supportsToolCalling != null)
        _CapabilityCardData(
          id: 'tool-calling',
          label: AppStrings.capabilityToolCalling,
          supported: capability.supportsToolCalling!,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.lg,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              AppListTile(
                title: AppStrings.provider,
                subtitle: capability.providerName.dbValue,
                leadingAsset: OutlinedSvgAssets.cloud,
              ),
              AppWhiteSpace.hSm,
              AppListTile(
                title: AppStrings.model,
                subtitle: capability.modelName,
                leadingAsset: OutlinedSvgAssets.cpuChip,
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        const AppSectionHeader(title: AppStrings.featureStatus),
        AppWhiteSpace.hSm,
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: capabilityCards
                  .map(
                    (card) => SizedBox(
                      width: cardWidth,
                      child: _CapabilityCard(data: card),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        AppWhiteSpace.hLg,
        const AppSectionHeader(title: AppStrings.providerCapabilityTitle),
        AppWhiteSpace.hSm,
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              if (capability.maxContextTokens != null) ...[
                _CapabilityInfoTile(
                  label: AppStrings.capabilityMaxContextTokens,
                  value: capability.maxContextTokens!.toString(),
                  icon: OutlinedSvgAssets.documentText,
                ),
                AppWhiteSpace.hSm,
              ],
              if (capability.maxOutputTokens != null) ...[
                _CapabilityInfoTile(
                  label: AppStrings.capabilityMaxOutputTokens,
                  value: capability.maxOutputTokens!.toString(),
                  icon: OutlinedSvgAssets.arrowUpTray,
                ),
                AppWhiteSpace.hSm,
              ],
              if (capability.maxImagesPerRequest != null) ...[
                _CapabilityInfoTile(
                  label: AppStrings.capabilityMaxImagesPerRequest,
                  value: capability.maxImagesPerRequest!.toString(),
                  icon: OutlinedSvgAssets.photo,
                ),
                AppWhiteSpace.hSm,
              ],
              _CapabilityInfoTile(
                label: AppStrings.capabilityLastChecked,
                value: _formatDateTime(capability.checkedAt),
                icon: OutlinedSvgAssets.clock,
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _CapabilityCardData {
  const _CapabilityCardData({
    required this.id,
    required this.label,
    required this.supported,
  });

  final String id;
  final String label;
  final bool supported;
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({required this.data});

  final _CapabilityCardData data;

  @override
  Widget build(BuildContext context) {
    final statusBackground = data.supported
        ? context.colorScheme.tertiaryContainer
        : context.colorScheme.errorContainer;
    final statusForeground = data.supported
        ? context.colorScheme.onTertiaryContainer
        : context.colorScheme.onErrorContainer;

    return Semantics(
      key: ValueKey('provider-capability-${data.id}'),
      label: data.label,
      value: data.supported ? AppStrings.enabled : AppStrings.disabled,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSizing.optionCardMinHeight,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: AppSizing.reviewCardIcon,
              height: AppSizing.reviewCardIcon,
              decoration: BoxDecoration(
                color: statusBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                data.supported
                    ? OutlinedSvgAssets.check
                    : OutlinedSvgAssets.noSymbol,
                key: ValueKey(
                  'provider-capability-${data.id}-'
                  '${data.supported ? 'available' : 'unavailable'}',
                ),
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  statusForeground,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppWhiteSpace.hSm,
            Text(
              data.label,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hXs,
            Row(
              children: [
                SvgPicture.asset(
                  data.supported
                      ? OutlinedSvgAssets.checkCircle
                      : OutlinedSvgAssets.noSymbol,
                  width: AppSizing.iconXs,
                  height: AppSizing.iconXs,
                  colorFilter: ColorFilter.mode(
                    statusForeground,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wXs,
                Text(
                  data.supported ? AppStrings.enabled : AppStrings.disabled,
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityInfoTile extends StatelessWidget {
  const _CapabilityInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return AppListTile(title: label, subtitle: value, leadingAsset: icon);
  }
}
