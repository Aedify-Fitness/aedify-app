import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/application/byok_setup_controller.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
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
          if (state.hasError) {
            return _ErrorView(
              message:
                  state.errorMessage ?? AppErrorStrings.byokLoadFailedMessage,
              onRetry: () => ref
                  .read(AppProviders.byokSetupControllerProvider.notifier)
                  .reload(),
            );
          }
          return _ByokContentView(state: state, ref: ref);
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
  const _ByokContentView({required this.state, required this.ref});

  final ByokSetupState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.byokSetupControllerProvider.notifier,
    );
    final draft = state.editDraft ?? const ByokEditDraft();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.errorMessage != null)
            _ErrorBanner(message: state.errorMessage!),
          if (state.validationMessage != null)
            _ValidationBanner(message: state.validationMessage!),

          // Existing configs
          if (state.configs.isNotEmpty) ...[
            Text(
              AppStrings.savedProviders,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hSm,
            ...state.configs.map(
              (config) => _ConfigCard(
                config: config,
                onSetActive: () => controller.setActiveConfig(config.id),
                onDelete: () => _confirmDelete(context, config.id, controller),
              ),
            ),
            AppWhiteSpace.hLg,
          ],

          // Provider selector
          Text(
            AppStrings.provider,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
          _ProviderSelector(
            options: state.providerOptions,
            selectedId: draft.providerName?.dbValue,
            onChanged: (value) {
              final option = state.providerOptions.firstWhere(
                (o) => o.providerName.dbValue == value,
              );
              controller.updateDraft(
                draft.copyWith(
                  providerName: option.providerName,
                  selectedModel: option.models.isNotEmpty
                      ? option.models.first.id
                      : null,
                ),
              );
            },
          ),
          AppWhiteSpace.hMd,

          // Model selector
          if (draft.providerName != null) ...[
            Text(
              AppStrings.model,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hSm,
            _ModelSelector(
              providerName: draft.providerName!,
              options: state.providerOptions,
              selectedModelId: draft.selectedModel,
              onChanged: (value) {
                controller.updateDraft(draft.copyWith(selectedModel: value));
              },
            ),
            if (draft.selectedModel != null) ...[
              AppWhiteSpace.hXs,
              _CostIndicator(
                options: state.providerOptions,
                providerName: draft.providerName!,
                selectedModelId: draft.selectedModel!,
              ),
              if (draft.selectedModel != null)
                _MoreCapableHint(
                  options: state.providerOptions,
                  providerName: draft.providerName!,
                  selectedModelId: draft.selectedModel!,
                ),
            ],
            AppWhiteSpace.hMd,
          ],

          // API key input
          Text(
            AppStrings.apiKey,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
          _ApiKeyField(
            value: draft.apiKey ?? '',
            onChanged: (value) {
              controller.updateDraft(draft.copyWith(apiKey: value));
            },
          ),
          AppWhiteSpace.hMd,

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving || state.isTesting
                  ? null
                  : () => controller.save(),
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
          if (state.isTesting) ...[
            AppWhiteSpace.hSm,
            Center(
              child: Text(
                AppStrings.byokTestingKey,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          AppWhiteSpace.hLg,

          // Skip AI for now
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteKey),
        content: const Text(AppStrings.deleteKeyConfirmation),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ctx.pop();
              controller.deleteConfig(configId);
            },
            child: const Text(AppStrings.deleteKey),
          ),
        ],
      ),
    );
  }
}

class _CostIndicator extends StatelessWidget {
  const _CostIndicator({
    required this.options,
    required this.providerName,
    required this.selectedModelId,
  });

  final List<ByokProviderOption> options;
  final AiProviderName providerName;
  final String selectedModelId;

  @override
  Widget build(BuildContext context) {
    final option = options.firstWhere((o) => o.providerName == providerName);

    final models = option.models;
    final selectedModel = models
        .where((m) => m.id == selectedModelId)
        .firstOrNull;

    if (selectedModel == null) return const SizedBox.shrink();

    return Row(
      children: [
        SvgPicture.asset(
          OutlinedSvgAssets.bolt,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wXs,
        Text(
          '${AppStrings.estimatedCostPerWorkout}${selectedModel.estimatedCostPerWorkout}',
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MoreCapableHint extends StatelessWidget {
  const _MoreCapableHint({
    required this.options,
    required this.providerName,
    required this.selectedModelId,
  });

  final List<ByokProviderOption> options;
  final AiProviderName providerName;
  final String selectedModelId;

  @override
  Widget build(BuildContext context) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    final models = option.models;
    final selectedModel = models
        .where((m) => m.id == selectedModelId)
        .firstOrNull;

    if (selectedModel == null) return const SizedBox.shrink();

    final hasMoreCapable = models.any(
      (m) => m.totalCostPer1kTokens > selectedModel.totalCostPer1kTokens,
    );

    if (!hasMoreCapable) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.bolt,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.wXs,
          Text(
            AppStrings.byokMoreCapableModelsHint,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onErrorContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onTertiaryContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.config,
    required this.onSetActive,
    required this.onDelete,
  });

  final dynamic config;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: config.isActive
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  config.displayName ?? config.providerName.dbValue,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              if (config.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    AppStrings.active,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          if (config.selectedModel != null) ...[
            AppWhiteSpace.hXs,
            Text(
              config.selectedModel,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (config.hasKey) ...[
            AppWhiteSpace.hXs,
            Text(
              AppStrings.keySaved,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.tertiary,
              ),
            ),
          ],
          AppWhiteSpace.hSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!config.isActive)
                TextButton(
                  onPressed: onSetActive,
                  child: const Text(AppStrings.makeActive),
                ),
              TextButton(
                onPressed: onDelete,
                child: Text(
                  AppStrings.deleteKey,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
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

  final List<dynamic> options;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = option.providerName.dbValue == selectedId;
        return ChoiceChip(
          label: Text(option.displayName),
          selected: isSelected,
          onSelected: (_) => onChanged(option.providerName.dbValue),
        );
      }).toList(),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.providerName,
    required this.options,
    required this.selectedModelId,
    required this.onChanged,
  });

  final AiProviderName providerName;
  final List<ByokProviderOption> options;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final byokOption = options.firstWhere(
      (o) => o.providerName == providerName,
    );
    final models = byokOption.models;
    return DropdownButtonFormField<String>(
      initialValue: selectedModelId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: models.map<DropdownMenuItem<String>>((model) {
        return DropdownMenuItem(
          value: model.id,
          child: Text(model.displayName),
        );
      }).toList(),
      onChanged: onChanged,
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
  final _obscured = ValueNotifier<bool>(true);

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
    _obscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscured,
      builder: (context, obscured, child) {
        return TextFormField(
          controller: _controller,
          obscureText: obscured,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            hintText: AppStrings.apiKeyHint,
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                obscured ? OutlinedSvgAssets.eye : OutlinedSvgAssets.eyeSlash,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              onPressed: () => _obscured.value = !obscured,
            ),
          ),
        );
      },
    );
  }
}
