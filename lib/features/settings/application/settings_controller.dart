import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/domain/settings_view_data.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  const SettingsState({
    required this.isLoading,
    this.viewData,
    this.editDraft,
    this.errorCode,
    this.errorMessage,
    this.isSaving = false,
  });

  final bool isLoading;
  final SettingsViewData? viewData;
  final SettingsEditDraft? editDraft;
  final String? errorCode;
  final String? errorMessage;
  final bool isSaving;

  bool get hasError => errorCode != null;

  SettingsState copyWith({
    bool? isLoading,
    SettingsViewData? viewData,
    SettingsEditDraft? editDraft,
    String? errorCode,
    String? errorMessage,
    bool? isSaving,
    bool clearViewData = false,
    bool clearEditDraft = false,
    bool clearError = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      viewData: clearViewData ? null : (viewData ?? this.viewData),
      editDraft: clearEditDraft ? null : (editDraft ?? this.editDraft),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  static const SettingsState initial = SettingsState(isLoading: true);
}

class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final repository = ref.read(AppProviders.settingsRepositoryProvider);
    try {
      final viewData = await repository.getSettings();
      return SettingsState(
        isLoading: false,
        viewData: viewData,
        editDraft: SettingsEditDraft(
          preferredUnits: viewData.preferredUnits,
          themeMode: viewData.themeMode,
          notificationsEnabled: viewData.notificationsEnabled,
          workoutTimerSoundEnabled: viewData.workoutTimerSoundEnabled,
          exerciseAudioEnabled: viewData.exerciseAudioEnabled,
          crashlyticsEnabled: viewData.crashlyticsEnabled,
          redactionStrictMode: viewData.redactionStrictMode,
        ),
      );
    } catch (e) {
      return SettingsState(
        isLoading: false,
        errorCode: AppErrorCodes.settingsLoadFailed,
        errorMessage: AppErrorStrings.settingsLoadFailedMessage,
      );
    }
  }

  void updateDraft(SettingsEditDraft draft) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(editDraft: draft, clearError: true));
  }

  Future<void> save() async {
    final current = state.requireValue;
    if (current.editDraft == null) return;

    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    try {
      final repository = ref.read(AppProviders.settingsRepositoryProvider);
      await repository.saveSettings(current.editDraft!);
      final updated = await repository.getSettings();
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          viewData: updated,
          editDraft: SettingsEditDraft(
            preferredUnits: updated.preferredUnits,
            themeMode: updated.themeMode,
            notificationsEnabled: updated.notificationsEnabled,
            workoutTimerSoundEnabled: updated.workoutTimerSoundEnabled,
            exerciseAudioEnabled: updated.exerciseAudioEnabled,
            crashlyticsEnabled: updated.crashlyticsEnabled,
            redactionStrictMode: updated.redactionStrictMode,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorCode: AppErrorCodes.settingsSaveFailed,
          errorMessage: AppErrorStrings.settingsSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> reload() async {
    final repository = ref.read(AppProviders.settingsRepositoryProvider);
    state = const AsyncData(SettingsState.initial);
    try {
      final viewData = await repository.getSettings();
      state = AsyncData(
        SettingsState(
          isLoading: false,
          viewData: viewData,
          editDraft: SettingsEditDraft(
            preferredUnits: viewData.preferredUnits,
            themeMode: viewData.themeMode,
            notificationsEnabled: viewData.notificationsEnabled,
            workoutTimerSoundEnabled: viewData.workoutTimerSoundEnabled,
            exerciseAudioEnabled: viewData.exerciseAudioEnabled,
            crashlyticsEnabled: viewData.crashlyticsEnabled,
            redactionStrictMode: viewData.redactionStrictMode,
          ),
        ),
      );
    } catch (e) {
      state = AsyncData(
        SettingsState(
          isLoading: false,
          errorCode: AppErrorCodes.settingsLoadFailed,
          errorMessage: AppErrorStrings.settingsLoadFailedMessage,
        ),
      );
    }
  }
}
