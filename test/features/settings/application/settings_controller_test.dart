import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/domain/settings_view_data.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsRepository implements SettingsRepository {
  SettingsViewData? _stored;

  @override
  Future<SettingsViewData> getSettings() async {
    if (_stored == null) {
      return SettingsViewData(
        preferredUnits: PreferredUnit.metric,
        themeMode: ThemeModeSetting.system,
        notificationsEnabled: true,
        workoutTimerSoundEnabled: true,
        exerciseAudioEnabled: false,
        crashlyticsEnabled: true,
        redactionStrictMode: true,
        diagnosticsEnabled: false,
        aiEnabled: true,
        importsEnabled: true,
        sharingEnabled: true,
        progressMediaEnabled: true,
        physiqueAnalysisEnabled: true,
      );
    }
    return _stored!;
  }

  @override
  Future<void> saveSettings(SettingsEditDraft draft) async {
    _stored = SettingsViewData(
      preferredUnits: draft.preferredUnits,
      themeMode: draft.themeMode,
      notificationsEnabled: draft.notificationsEnabled,
      workoutTimerSoundEnabled: draft.workoutTimerSoundEnabled,
      exerciseAudioEnabled: draft.exerciseAudioEnabled,
      crashlyticsEnabled: draft.crashlyticsEnabled,
      redactionStrictMode: draft.redactionStrictMode,
      diagnosticsEnabled: false,
      aiEnabled: true,
      importsEnabled: true,
      sharingEnabled: true,
      progressMediaEnabled: true,
      physiqueAnalysisEnabled: true,
    );
  }
}

class _FailingRepository implements SettingsRepository {
  @override
  Future<SettingsViewData> getSettings() async {
    throw Exception('connection failed');
  }

  @override
  Future<void> saveSettings(SettingsEditDraft draft) async {
    throw Exception('write failed');
  }
}

void main() {
  group('SettingsController', () {
    test('initial build loads settings', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.settingsRepositoryProvider.overrideWith(
            (ref) => _FakeSettingsRepository(),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.settingsControllerProvider.notifier,
      );

      await controller.build();

      final state = container.read(AppProviders.settingsControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.isLoading, isFalse);
      expect(state.requireValue.viewData, isNotNull);
      expect(
        state.requireValue.viewData!.preferredUnits,
        equals(PreferredUnit.metric),
      );
    });

    test('updateDraft updates local edit state', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.settingsRepositoryProvider.overrideWith(
            (ref) => _FakeSettingsRepository(),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.settingsControllerProvider.notifier,
      );

      await controller.build();
      controller.updateDraft(
        const SettingsEditDraft(preferredUnits: PreferredUnit.imperial),
      );

      final state = container.read(AppProviders.settingsControllerProvider);
      expect(state.requireValue.editDraft, isNotNull);
      expect(
        state.requireValue.editDraft!.preferredUnits,
        equals(PreferredUnit.imperial),
      );
    });

    test('save persists settings', () async {
      final fake = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          AppProviders.settingsRepositoryProvider.overrideWith((ref) => fake),
        ],
      );

      final controller = container.read(
        AppProviders.settingsControllerProvider.notifier,
      );

      await controller.build();
      controller.updateDraft(
        const SettingsEditDraft(preferredUnits: PreferredUnit.imperial),
      );
      await controller.save();

      final state = container.read(AppProviders.settingsControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.isSaving, isFalse);
      expect(
        state.requireValue.viewData!.preferredUnits,
        equals(PreferredUnit.imperial),
      );
    });

    test('save surfaces error state on repository failure', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.settingsRepositoryProvider.overrideWith(
            (ref) => _FailingRepository(),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.settingsControllerProvider.notifier,
      );

      await controller.build();
      controller.updateDraft(const SettingsEditDraft());
      await controller.save();

      final state = container.read(AppProviders.settingsControllerProvider);
      expect(state.requireValue.hasError, isTrue);
      expect(
        state.requireValue.errorMessage,
        equals(AppErrorStrings.settingsSaveFailedMessage),
      );
    });

    test('reload refreshes settings state', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.settingsRepositoryProvider.overrideWith(
            (ref) => _FakeSettingsRepository(),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.settingsControllerProvider.notifier,
      );

      await controller.build();
      await controller.reload();

      final state = container.read(AppProviders.settingsControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.isLoading, isFalse);
      expect(state.requireValue.viewData, isNotNull);
    });
  });
}
