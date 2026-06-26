import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ByokSetupState {
  const ByokSetupState({
    required this.isLoading,
    required this.providerOptions,
    required this.configs,
    this.editDraft,
    this.errorCode,
    this.errorMessage,
    this.validationMessage,
    this.isSaving = false,
    this.isTesting = false,
  });

  final bool isLoading;
  final List<ByokProviderOption> providerOptions;
  final List<ByokConfigViewData> configs;
  final ByokEditDraft? editDraft;
  final String? errorCode;
  final String? errorMessage;
  final String? validationMessage;
  final bool isSaving;
  final bool isTesting;

  bool get hasError => errorCode != null;

  ByokSetupState copyWith({
    bool? isLoading,
    List<ByokProviderOption>? providerOptions,
    List<ByokConfigViewData>? configs,
    ByokEditDraft? editDraft,
    String? errorCode,
    String? errorMessage,
    String? validationMessage,
    bool? isSaving,
    bool? isTesting,
    bool clearDraft = false,
    bool clearError = false,
    bool clearValidationMessage = false,
  }) {
    return ByokSetupState(
      isLoading: isLoading ?? this.isLoading,
      providerOptions: providerOptions ?? this.providerOptions,
      configs: configs ?? this.configs,
      editDraft: clearDraft ? null : (editDraft ?? this.editDraft),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      isSaving: isSaving ?? this.isSaving,
      isTesting: isTesting ?? this.isTesting,
    );
  }

  static const ByokSetupState initial = ByokSetupState(
    isLoading: true,
    providerOptions: [],
    configs: [],
  );
}

class ByokSetupController extends AsyncNotifier<ByokSetupState> {
  @override
  Future<ByokSetupState> build() async {
    final repository = ref.read(AppProviders.byokRepositoryProvider);
    try {
      final providerOptions = await repository.getProviderOptions();
      final configs = await repository.getConfigs();
      return ByokSetupState(
        isLoading: false,
        providerOptions: providerOptions,
        configs: configs,
      );
    } catch (e) {
      return ByokSetupState(
        isLoading: false,
        providerOptions: [],
        configs: [],
        errorCode: 'byok_load_failed',
        errorMessage: AppErrorStrings.byokLoadFailedMessage,
      );
    }
  }

  void updateDraft(ByokEditDraft draft) {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        editDraft: draft,
        clearError: true,
        clearValidationMessage: true,
      ),
    );
  }

  Future<void> save() async {
    final current = state.requireValue;
    final draft = current.editDraft;

    if (draft?.apiKey == null || draft!.apiKey!.isEmpty) {
      state = AsyncData(
        current.copyWith(
          validationMessage: AppErrorStrings.byokEmptyKeyValidation,
          clearError: true,
        ),
      );
      return;
    }

    if (draft.providerName == null) {
      state = AsyncData(
        current.copyWith(
          validationMessage: AppErrorStrings.byokNoProviderValidation,
          clearError: true,
        ),
      );
      return;
    }

    state = AsyncData(current.copyWith(isTesting: true, clearError: true));

    try {
      final repository = ref.read(AppProviders.byokRepositoryProvider);
      final isValid = await repository.validateKey(
        providerName: draft.providerName!,
        apiKey: draft.apiKey!,
      );

      if (!isValid) {
        state = AsyncData(
          current.copyWith(
            isTesting: false,
            validationMessage: AppErrorStrings.byokKeyValidationFailed,
          ),
        );
        return;
      }

      state = AsyncData(current.copyWith(isSaving: true, isTesting: false));

      await repository.saveConfig(draft);
      final configs = await repository.getConfigs();
      state = AsyncData(
        current.copyWith(isSaving: false, configs: configs, clearDraft: true),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          isTesting: false,
          errorCode: 'byok_save_failed',
          errorMessage: AppErrorStrings.byokSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> rotateKey({
    required String configId,
    required String providerName,
    required String newApiKey,
  }) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    try {
      final repository = ref.read(AppProviders.byokRepositoryProvider);
      await repository.rotateKey(
        configId: configId,
        providerName: providerName,
        newApiKey: newApiKey,
      );
      final configs = await repository.getConfigs();
      state = AsyncData(current.copyWith(isSaving: false, configs: configs));
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorCode: 'byok_rotate_failed',
          errorMessage: AppErrorStrings.byokKeyRotationFailed,
        ),
      );
    }
  }

  Future<void> deleteConfig(String configId) async {
    final current = state.requireValue;
    try {
      final repository = ref.read(AppProviders.byokRepositoryProvider);
      await repository.deleteConfig(configId);
      final configs = await repository.getConfigs();
      state = AsyncData(current.copyWith(configs: configs));
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          errorCode: 'byok_delete_failed',
          errorMessage: AppErrorStrings.byokDeleteFailedMessage,
        ),
      );
    }
  }

  Future<void> setActiveConfig(String configId) async {
    final current = state.requireValue;
    try {
      final repository = ref.read(AppProviders.byokRepositoryProvider);
      await repository.setActiveConfig(configId);
      final configs = await repository.getConfigs();
      state = AsyncData(current.copyWith(configs: configs));
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          errorCode: 'byok_set_active_failed',
          errorMessage: AppErrorStrings.byokSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> reload() async {
    final repository = ref.read(AppProviders.byokRepositoryProvider);
    state = const AsyncData(ByokSetupState.initial);
    try {
      final providerOptions = await repository.getProviderOptions();
      final configs = await repository.getConfigs();
      state = AsyncData(
        ByokSetupState(
          isLoading: false,
          providerOptions: providerOptions,
          configs: configs,
        ),
      );
    } catch (e) {
      state = AsyncData(
        ByokSetupState(
          isLoading: false,
          providerOptions: [],
          configs: [],
          errorCode: 'byok_load_failed',
          errorMessage: AppErrorStrings.byokLoadFailedMessage,
        ),
      );
    }
  }
}
