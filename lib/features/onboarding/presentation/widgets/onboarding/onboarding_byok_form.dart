import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_byok_api_key_field.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_byok_setup_surface.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_input_label.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingByokFormState {
  const OnboardingByokFormState({
    this.selectedProvider,
    this.selectedModel,
    this.validationMessage,
    this.isSaving = false,
    this.hasSaved = false,
  });

  final AiProviderName? selectedProvider;
  final String? selectedModel;
  final String? validationMessage;
  final bool isSaving;
  final bool hasSaved;

  OnboardingByokFormState copyWith({
    AiProviderName? selectedProvider,
    String? selectedModel,
    String? validationMessage,
    bool? isSaving,
    bool? hasSaved,
    bool clearProvider = false,
    bool clearModel = false,
    bool clearValidationMessage = false,
  }) {
    return OnboardingByokFormState(
      selectedProvider: clearProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      selectedModel: clearModel ? null : (selectedModel ?? this.selectedModel),
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
    );
  }
}

class OnboardingByokFormNotifier extends Notifier<OnboardingByokFormState> {
  @override
  OnboardingByokFormState build() => const OnboardingByokFormState();

  void selectProvider(
    AiProviderName providerName,
    List<ByokProviderOption> options,
  ) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    state = state.copyWith(
      selectedProvider: providerName,
      selectedModel: _cheapestModelId(option),
      clearModel: option.models.isEmpty,
      clearValidationMessage: true,
    );
  }

  void selectModel(String? modelId) {
    state = state.copyWith(
      selectedModel: modelId,
      clearValidationMessage: true,
    );
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving, clearValidationMessage: saving);
  }

  void setFailure(String message) {
    state = state.copyWith(isSaving: false, validationMessage: message);
  }

  void clearValidationMessage() {
    if (state.validationMessage == null) return;
    state = state.copyWith(clearValidationMessage: true);
  }

  void markSaved() {
    state = state.copyWith(
      hasSaved: true,
      isSaving: false,
      clearValidationMessage: true,
    );
  }

  String? _cheapestModelId(ByokProviderOption option) {
    if (option.models.isEmpty) return null;
    var cheapest = option.models.first;
    for (final model in option.models.skip(1)) {
      if (model.totalCostPer1kTokens < cheapest.totalCostPer1kTokens) {
        cheapest = model;
      }
    }
    return cheapest.id;
  }
}

class OnboardingProviders {
  OnboardingProviders._();

  static final byokOptionsProvider =
      FutureProvider.autoDispose<List<ByokProviderOption>>((ref) {
        return ref
            .read(AppProviders.byokRepositoryProvider)
            .getProviderOptions();
      });

  static final byokFormProvider =
      NotifierProvider.autoDispose<
        OnboardingByokFormNotifier,
        OnboardingByokFormState
      >(OnboardingByokFormNotifier.new);
}

class OnboardingByokForm extends ConsumerStatefulWidget {
  const OnboardingByokForm({
    super.key,
    required this.options,
    required this.draft,
    required this.onUpdateDraft,
  });

  final List<ByokProviderOption> options;
  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  ConsumerState<OnboardingByokForm> createState() => _ByokFormWidgetState();
}

class _ByokFormWidgetState extends ConsumerState<OnboardingByokForm> {
  final _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final formState = ref.read(OnboardingProviders.byokFormProvider);
      if (formState.selectedProvider != null || widget.options.isEmpty) return;
      final openAiIndex = widget.options.indexWhere(
        (option) => option.providerName == AiProviderName.openai,
      );
      final initialOption = openAiIndex == -1
          ? widget.options.first
          : widget.options[openAiIndex];
      ref
          .read(OnboardingProviders.byokFormProvider.notifier)
          .selectProvider(initialOption.providerName, widget.options);
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final formState = ref.read(OnboardingProviders.byokFormProvider);
    final provider = formState.selectedProvider;
    final apiKey = _keyController.text.trim();
    if (provider == null || apiKey.isEmpty) return;

    final notifier = ref.read(OnboardingProviders.byokFormProvider.notifier);
    notifier.setSaving(true);

    final repository = ref.read(AppProviders.byokRepositoryProvider);
    try {
      final isValid = await repository.validateKey(
        providerName: provider,
        apiKey: apiKey,
      );
      if (!mounted) return;
      if (!isValid) {
        notifier.setFailure(AppErrorStrings.byokKeyValidationFailed);
        return;
      }
    } catch (_) {
      if (!mounted) return;
      notifier.setFailure(AppErrorStrings.byokValidationNetworkError);
      return;
    }

    try {
      await repository.saveConfig(
        ByokEditDraft(
          providerName: provider,
          selectedModel: formState.selectedModel,
          apiKey: apiKey,
          makeActive: true,
        ),
      );
      if (!mounted) return;
      widget.onUpdateDraft(widget.draft.copyWith(byokSkipped: false));
      _keyController.clear();
      notifier.markSaved();
    } catch (_) {
      if (!mounted) return;
      notifier.setFailure(AppErrorStrings.byokSaveFailedMessage);
    }
  }

  String _apiKeyLabelFor(AiProviderName? provider) {
    return switch (provider) {
      AiProviderName.openai => AppStrings.onboardingOpenAiApiKeyLabel,
      AiProviderName.anthropic => AppStrings.onboardingAnthropicApiKeyLabel,
      AiProviderName.google => AppStrings.onboardingGoogleApiKeyLabel,
      AiProviderName.otherSupported || null => AppStrings.apiKey,
    };
  }

  String _apiKeyHintFor(AiProviderName? provider) {
    return switch (provider) {
      AiProviderName.anthropic => AppStrings.onboardingAnthropicApiKeyHint,
      AiProviderName.google => AppStrings.onboardingGoogleApiKeyHint,
      AiProviderName.openai ||
      AiProviderName.otherSupported ||
      null => AppStrings.apiKeyHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(OnboardingProviders.byokFormProvider);
    final isDark = context.theme.brightness == Brightness.dark;
    final savedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryFixed;
    final savedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryFixed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!formState.hasSaved)
          OnboardingByokSetupSurface(
            key: const ValueKey<String>('onboarding_byok_setup_card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.onboardingSelectProvider,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                AppWhiteSpace.hLg,
                Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, i) {
                        return AppWhiteSpace.hMd;
                      },
                      itemCount: widget.options.length,
                      itemBuilder: (context, i) {
                        return Builder(
                          builder: (context) {
                            final option = widget.options[i];
                            final isSelected =
                                formState.selectedProvider ==
                                option.providerName;
                            return _OnboardingByokProviderCard(
                              option: option,
                              selected: isSelected,
                              onTap: () {
                                ref
                                    .read(
                                      OnboardingProviders
                                          .byokFormProvider
                                          .notifier,
                                    )
                                    .selectProvider(
                                      option.providerName,
                                      widget.options,
                                    );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                if (formState.selectedProvider != null) ...[
                  const OnboardingInputLabel(title: AppStrings.model),
                  AppWhiteSpace.hSm,
                  _OnboardingModelSelector(
                    options: widget.options,
                    providerName: formState.selectedProvider!,
                    selectedModelId: formState.selectedModel,
                    onChanged: (value) {
                      ref
                          .read(OnboardingProviders.byokFormProvider.notifier)
                          .selectModel(value);
                    },
                  ),
                ],
                AppWhiteSpace.hLg,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    _apiKeyLabelFor(formState.selectedProvider),
                    key: const ValueKey<String>(
                      'onboarding_byok_api_key_label',
                    ),
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppWhiteSpace.hSm,
                OnboardingByokApiKeyField(
                  controller: _keyController,
                  hintText: _apiKeyHintFor(formState.selectedProvider),
                  onChanged: (_) {
                    ref
                        .read(OnboardingProviders.byokFormProvider.notifier)
                        .clearValidationMessage();
                  },
                ),
                AppWhiteSpace.hSm,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    AppStrings.onboardingApiKeySecureHelper,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ),
                if (formState.validationMessage != null) ...[
                  AppWhiteSpace.hSm,
                  Text(
                    formState.validationMessage!,
                    key: const ValueKey<String>(
                      'onboarding_byok_validation_message',
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
                AppWhiteSpace.hXl,
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _keyController,
                  builder: (context, value, child) {
                    final canSave =
                        formState.selectedProvider != null &&
                        value.text.trim().isNotEmpty &&
                        !formState.isSaving;
                    return SizedBox(
                      width: double.infinity,
                      height: AppSizing.onboardingByokFieldHeight,
                      child: FilledButton(
                        key: const ValueKey<String>(
                          'onboarding_byok_secure_connection',
                        ),
                        onPressed: canSave ? _saveKey : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.secondary,
                          foregroundColor: context.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.defaultRadius,
                            ),
                          ),
                        ),
                        child: formState.isSaving
                            ? SizedBox(
                                width: AppSizing.iconSm,
                                height: AppSizing.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSizing.strokeWidth,
                                  color: context.colorScheme.onSecondary,
                                ),
                              )
                            : const Text(AppStrings.onboardingConnectProvider),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

        if (formState.hasSaved)
          Container(
            key: const ValueKey<String>('onboarding_byok_saved'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: savedBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.materialCheckCircle,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    savedForeground,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.byokOnboardingSaved,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: savedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (!formState.hasSaved) ...[
          AppWhiteSpace.hXl,
          const _OnboardingByokSecureDivider(),
        ],
      ],
    );
  }
}

class _OnboardingByokSecureDivider extends StatelessWidget {
  const _OnboardingByokSecureDivider();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: 0.3,
        child: Row(
          key: const ValueKey<String>('onboarding_byok_secure_divider'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizing.reviewStatusDot,
              height: AppSizing.reviewStatusDot,
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.fieldWidthSm,
              height: AppSizing.divider,
              color: context.colorScheme.outlineVariant,
            ),
            AppWhiteSpace.wSm,
            SvgPicture.asset(
              OutlinedSvgAssets.materialEncrypted,
              width: AppSizing.iconXxs,
              height: AppSizing.iconXxs,
              colorFilter: ColorFilter.mode(
                context.colorScheme.outline,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.fieldWidthSm,
              height: AppSizing.divider,
              color: context.colorScheme.outlineVariant,
            ),
            AppWhiteSpace.wSm,
            Container(
              width: AppSizing.reviewStatusDot,
              height: AppSizing.reviewStatusDot,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingByokProviderCard extends StatelessWidget {
  const _OnboardingByokProviderCard({
    required this.option,
    required this.onTap,
    required this.selected,
  });

  final bool selected;
  final VoidCallback onTap;
  final ByokProviderOption option;

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Semantics(
      button: true,
      selected: selected,
      label: option.displayName,
      excludeSemantics: true,
      child: AnimatedContainer(
        key: ValueKey<String>('onboarding_byok_provider_${option.id}'),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: AppSizing.onboardingByokProviderCardMinHeight,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerLow
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: AppSizing.iconXxl,
                  height: AppSizing.iconXxl,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(
                      alpha: 0.05,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    _iconForProvider(option.providerName),
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                AppWhiteSpace.hControlGap,
                Text(
                  option.displayName,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _iconForProvider(AiProviderName provider) {
    return switch (provider) {
      AiProviderName.openai => OutlinedSvgAssets.materialBolt,
      AiProviderName.anthropic => OutlinedSvgAssets.materialAutoAwesome,
      AiProviderName.google => OutlinedSvgAssets.materialCloud,
      AiProviderName.otherSupported => OutlinedSvgAssets.materialKey,
    };
  }
}

class _OnboardingModelSelector extends StatelessWidget {
  const _OnboardingModelSelector({
    required this.options,
    required this.providerName,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<ByokProviderOption> options;
  final AiProviderName providerName;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    final focusColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      borderSide: BorderSide(
        color: context.colorScheme.outlineVariant,
        width: AppSizing.divider,
      ),
    );
    return SizedBox(
      height: AppSizing.onboardingByokFieldHeight,
      child: DropdownButtonFormField<String>(
        key: ValueKey<AiProviderName>(providerName),
        initialValue: selectedModelId,
        isExpanded: true,
        icon: SvgPicture.asset(
          OutlinedSvgAssets.chevronDown,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colorScheme.surface,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: focusColor,
              width: AppSizing.strokeWidth,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonVertical,
          ),
        ),
        items: option.models.map<DropdownMenuItem<String>>((model) {
          return DropdownMenuItem(
            value: model.id,
            child: Text(model.displayName, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        style: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurface,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
