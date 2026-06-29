import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
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
    final controller = ref.watch(
      AppProviders.providerCapabilityControllerProvider((
        providerName: AiProviderName.fromDb(providerName),
        modelName: modelName,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.providerCapabilityTitle)),
      body: controller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(message: error.toString()),
        data: (state) {
          if (state.capability == null) {
            return _UnavailableView(
              providerName: providerName,
              modelName: modelName,
              onRetry: () {
                ref.invalidate(
                  AppProviders.providerCapabilityControllerProvider((
                    providerName: AiProviderName.fromDb(providerName),
                    modelName: modelName,
                  )),
                );
              },
            );
          }
          return _CapabilityContentView(capability: state.capability!);
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.providerCapabilityUnavailable,
              style: AppTextStyles.bodyLg,
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hSm,
            Text(
              message,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({
    required this.providerName,
    required this.modelName,
    required this.onRetry,
  });

  final String providerName;
  final String modelName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.providerCapabilityUnavailable,
              style: AppTextStyles.bodyLg,
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hSm,
            Text(
              '$providerName / $modelName',
              style: AppTextStyles.labelSm,
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowPath,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _CapabilityTile(
          label: AppStrings.capabilityTextInput,
          supported: capability.supportsTextInput,
        ),
        _CapabilityTile(
          label: AppStrings.capabilityImageInput,
          supported: capability.supportsImageInput,
        ),
        _CapabilityTile(
          label: AppStrings.capabilityJsonSchemaMode,
          supported: capability.supportsJsonSchemaMode,
        ),
        _CapabilityTile(
          label: AppStrings.capabilityStreaming,
          supported: capability.supportsStreaming,
        ),
        if (capability.supportsToolCalling != null)
          _CapabilityTile(
            label: AppStrings.capabilityToolCalling,
            supported: capability.supportsToolCalling!,
          ),
        const Divider(),
        if (capability.maxContextTokens != null)
          _InfoTile(
            label: AppStrings.capabilityMaxContextTokens,
            value: capability.maxContextTokens!.toString(),
          ),
        if (capability.maxOutputTokens != null)
          _InfoTile(
            label: AppStrings.capabilityMaxOutputTokens,
            value: capability.maxOutputTokens!.toString(),
          ),
        if (capability.maxImagesPerRequest != null)
          _InfoTile(
            label: AppStrings.capabilityMaxImagesPerRequest,
            value: capability.maxImagesPerRequest!.toString(),
          ),
        const Divider(),
        _InfoTile(
          label: AppStrings.capabilityLastChecked,
          value: _formatDateTime(capability.checkedAt),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CapabilityTile extends StatelessWidget {
  const _CapabilityTile({required this.label, required this.supported});

  final String label;
  final bool supported;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SvgPicture.asset(
        supported ? OutlinedSvgAssets.checkCircle : OutlinedSvgAssets.xCircle,
        colorFilter: ColorFilter.mode(
          supported ? context.colorScheme.primary : context.colorScheme.error,
          BlendMode.srcIn,
        ),
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: AppTextStyles.labelSm),
    );
  }
}
