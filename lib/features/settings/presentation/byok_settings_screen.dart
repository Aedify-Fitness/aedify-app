import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/application/byok_setup_controller.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_model_option.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_storage_boundary_card.dart';
import 'package:aedify/shared/components/app_dialog.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/provider_validation_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ByokSettingsScreen extends ConsumerWidget {
  const ByokSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(AppProviders.byokSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.byokSettings)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorView(
          message: AppErrorStrings.byokLoadFailedMessage,
          onRetry: () => ref
              .read(AppProviders.byokSetupControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.hasError && state.providerOptions.isEmpty) {
            return _ErrorView(
              message:
                  state.errorMessage ?? AppErrorStrings.byokLoadFailedMessage,
              onRetry: () => ref
                  .read(AppProviders.byokSetupControllerProvider.notifier)
                  .reload(),
            );
          }
          return _ByokContentView(state: state);
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ByokContentView extends ConsumerWidget {
  const _ByokContentView({required this.state});

  final ByokSetupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.byokSetupControllerProvider.notifier,
    );
    final draft = state.editDraft ?? const ByokEditDraft();
    final selectedProvider = state.providerOptions
        .where((option) => option.providerName == draft.providerName)
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsStorageBoundaryCard(),
          if (state.configs.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            const AppSectionHeader(title: AppStrings.savedProviders),
            AppWhiteSpace.hSm,
            ...state.configs.map(
              (config) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ConfigCard(
                  config: config,
                  onSetActive: () => controller.setActiveConfig(config.id),
                  onDelete: () =>
                      _confirmDelete(context, config.id, controller),
                ),
              ),
            ),
          ],
          AppWhiteSpace.hLg,
          const AppSectionHeader(title: AppStrings.provider),
          AppWhiteSpace.hSm,
          if (state.providerOptions.isEmpty)
            const _InlineStatus(
              message: AppStrings.providerSetupRequired,
              icon: OutlinedSvgAssets.noSymbol,
              isError: true,
            )
          else
            _ProviderSelector(
              options: state.providerOptions,
              selectedId: draft.providerName?.dbValue,
              onChanged: (value) {
                final option = state.providerOptions.firstWhere(
                  (candidate) => candidate.providerName.dbValue == value,
                );
                controller.updateDraft(
                  draft.copyWith(
                    providerName: option.providerName,
                    selectedModel: option.models.firstOrNull?.id,
                    clearSelectedModel: option.models.isEmpty,
                  ),
                );
              },
            ),
          if (selectedProvider != null) ...[
            AppWhiteSpace.hLg,
            const AppSectionHeader(title: AppStrings.model),
            AppWhiteSpace.hSm,
            if (selectedProvider.models.isEmpty)
              const _InlineStatus(
                message: AppStrings.providerCapabilityUnavailable,
                icon: OutlinedSvgAssets.noSymbol,
                isError: true,
              )
            else ...[
              _ModelSelector(
                models: selectedProvider.models,
                selectedModelId: draft.selectedModel,
                onChanged: (value) {
                  controller.updateDraft(draft.copyWith(selectedModel: value));
                },
              ),
              if (draft.selectedModel != null) ...[
                AppWhiteSpace.hSm,
                _ModelDetails(
                  provider: selectedProvider,
                  selectedModelId: draft.selectedModel!,
                ),
              ],
            ],
          ],
          AppWhiteSpace.hLg,
          const AppSectionHeader(title: AppStrings.apiKey),
          AppWhiteSpace.hSm,
          _ApiKeyField(
            value: draft.apiKey ?? '',
            onChanged: (value) {
              controller.updateDraft(draft.copyWith(apiKey: value));
            },
          ),
          if (state.validationMessage != null) ...[
            AppWhiteSpace.hSm,
            _InlineStatus(
              message: state.validationMessage!,
              icon: OutlinedSvgAssets.exclamationCircle,
              isError: true,
            ),
          ],
          if (state.errorMessage != null) ...[
            AppWhiteSpace.hSm,
            _InlineStatus(
              message: state.errorMessage!,
              icon: OutlinedSvgAssets.signalSlash,
              isError: true,
            ),
          ],
          if (state.isTesting) ...[
            AppWhiteSpace.hSm,
            const _InlineStatus(
              message: AppStrings.byokTestingKey,
              icon: OutlinedSvgAssets.arrowPath,
            ),
          ],
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving || state.isTesting
                  ? null
                  : controller.save,
              child: state.isSaving || state.isTesting
                  ? const SizedBox(
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizing.strokeWidth,
                      ),
                    )
                  : const Text(AppStrings.saveKey),
            ),
          ),
          AppWhiteSpace.hMd,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text(AppStrings.skipAiForNow),
            ),
          ),
          AppWhiteSpace.hXl,
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String configId,
    ByokSetupController controller,
  ) {
    AppDialog.show<void>(
      context,
      title: AppStrings.deleteKey,
      content: const Text(AppStrings.deleteKeyConfirmation),
      actions: [
        Builder(
          builder: (dialogContext) => TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text(AppStrings.cancel),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            onPressed: () {
              dialogContext.pop();
              controller.deleteConfig(configId);
            },
            child: const Text(AppStrings.deleteKey),
          ),
        ),
      ],
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.config,
    required this.onSetActive,
    required this.onDelete,
  });

  final ByokConfigViewData config;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final connectionStatus = _connectionStatus(config);
    final connectionIsValid =
        config.hasKey &&
        (config.lastValidationStatus == ProviderValidationStatus.valid ||
            config.lastValidationStatus == null);

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          AppListTile(
            title: config.displayName ?? config.providerName.dbValue,
            subtitle: config.selectedModel,
            leadingAsset: OutlinedSvgAssets.key,
            trailing: config.isActive
                ? const _StatusPill(label: AppStrings.active, available: true)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ConnectionStatus(
                    label: connectionStatus,
                    available: connectionIsValid,
                  ),
                ),
                if (!config.isActive)
                  TextButton(
                    onPressed: onSetActive,
                    child: const Text(AppStrings.makeActive),
                  ),
                AppIconButton(
                  key: ValueKey('byok-delete-${config.id}'),
                  asset: OutlinedSvgAssets.trash,
                  semanticLabel: AppStrings.deleteKey,
                  color: context.colorScheme.error,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _connectionStatus(ByokConfigViewData config) {
    if (!config.hasKey) return AppStrings.providerKeyRequired;
    return switch (config.lastValidationStatus) {
      ProviderValidationStatus.invalid =>
        AppErrorStrings.byokKeyValidationFailed,
      ProviderValidationStatus.rateLimited =>
        AppErrorStrings.rateLimitedMessage,
      ProviderValidationStatus.unknown =>
        AppStrings.providerCapabilityUnavailable,
      ProviderValidationStatus.valid => AppStrings.keySaved,
      null => AppStrings.keySaved,
    };
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available
        ? context.colorScheme.tertiary
        : context.colorScheme.error;

    return Row(
      children: [
        SvgPicture.asset(
          available
              ? OutlinedSvgAssets.checkCircle
              : OutlinedSvgAssets.noSymbol,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        AppWhiteSpace.wXs,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = available
        ? context.colorScheme.tertiaryContainer
        : context.colorScheme.errorContainer;
    final foregroundColor = available
        ? context.colorScheme.onTertiaryContainer
        : context.colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<ByokProviderOption> options;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          _ProviderOptionCard(
            option: options[index],
            selected: options[index].providerName.dbValue == selectedId,
            onTap: () => onChanged(options[index].providerName.dbValue),
          ),
          if (index < options.length - 1) AppWhiteSpace.hSm,
        ],
      ],
    );
  }
}

class _ProviderOptionCard extends StatelessWidget {
  const _ProviderOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ByokProviderOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final selectedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryContainer;
    final selectedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryContainer;
    final foreground = selected
        ? selectedForeground
        : context.colorScheme.onSurface;

    return Semantics(
      key: ValueKey('byok-provider-${option.id}'),
      button: true,
      selected: selected,
      label: option.displayName,
      child: Material(
        color: selected
            ? selectedBackground
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AppSizing.iconXxl,
                  height: AppSizing.iconXxl,
                  decoration: BoxDecoration(
                    color: selected
                        ? foreground.withValues(alpha: 0.12)
                        : context.colorScheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.sparkles,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                ),
                AppWhiteSpace.wMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.displayName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppWhiteSpace.hXxs,
                      Text(
                        option.description,
                        style: AppTextStyles.bodySm.copyWith(
                          color: selected
                              ? selectedForeground
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected) ...[
                  AppWhiteSpace.wSm,
                  SvgPicture.asset(
                    OutlinedSvgAssets.checkCircle,
                    key: ValueKey('byok-provider-${option.id}-selected'),
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.models,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<ByokModelOption> models;
  final String? selectedModelId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: models
          .map(
            (model) => _ModelPill(
              model: model,
              selected: model.id == selectedModelId,
              onTap: () => onChanged(model.id),
            ),
          )
          .toList(),
    );
  }
}

class _ModelPill extends StatelessWidget {
  const _ModelPill({
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final ByokModelOption model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final selectedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryContainer;
    final selectedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryContainer;

    return Semantics(
      key: ValueKey('byok-model-${model.id}'),
      button: true,
      selected: selected,
      label: model.displayName,
      child: Material(
        color: selected
            ? selectedBackground
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.buttonVertical,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  SvgPicture.asset(
                    OutlinedSvgAssets.check,
                    key: ValueKey('byok-model-${model.id}-selected'),
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      selectedForeground,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wXs,
                ],
                Text(
                  model.displayName,
                  style: AppTextStyles.labelMd.copyWith(
                    color: selected
                        ? selectedForeground
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModelDetails extends StatelessWidget {
  const _ModelDetails({required this.provider, required this.selectedModelId});

  final ByokProviderOption provider;
  final String selectedModelId;

  @override
  Widget build(BuildContext context) {
    final selectedModel = provider.models
        .where((model) => model.id == selectedModelId)
        .firstOrNull;
    if (selectedModel == null) return const SizedBox.shrink();

    final hasMoreCapable = provider.models.any(
      (model) =>
          model.totalCostPer1kTokens > selectedModel.totalCostPer1kTokens,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailLine(
            icon: OutlinedSvgAssets.bolt,
            text:
                '${AppStrings.estimatedCostPerWorkout}${selectedModel.estimatedCostPerWorkout}',
          ),
          if (hasMoreCapable) ...[
            AppWhiteSpace.hSm,
            const _DetailLine(
              icon: OutlinedSvgAssets.sparkles,
              text: AppStrings.byokMoreCapableModelsHint,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wXs,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({
    required this.message,
    required this.icon,
    this.isError = false,
  });

  final String message;
  final String icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isError
        ? context.colorScheme.errorContainer
        : context.colorScheme.tertiaryContainer;
    final foregroundColor = isError
        ? context.colorScheme.onErrorContainer
        : context.colorScheme.onTertiaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMd.copyWith(color: foregroundColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiKeyField extends StatefulWidget {
  const _ApiKeyField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ApiKeyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: const ValueKey('byok-api-key-field'),
      controller: _controller,
      hintText: AppStrings.apiKeyHint,
      obscureText: true,
      enableObscureToggle: true,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(AppSpacing.buttonVertical),
        child: SvgPicture.asset(
          OutlinedSvgAssets.lockClosed,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
