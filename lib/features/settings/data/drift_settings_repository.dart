import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/domain/settings_view_data.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'package:drift/drift.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository({
    required AppSettingsDao appSettingsDao,
    required FeatureFlags featureFlags,
  }) : _appSettingsDao = appSettingsDao,
       _featureFlags = featureFlags;

  final AppSettingsDao _appSettingsDao;
  final FeatureFlags _featureFlags;

  @override
  Future<SettingsViewData> getSettings() async {
    final row = await _appSettingsDao.getSettings();
    return SettingsViewData(
      preferredUnits: PreferredUnit.fromDb(row?.preferredUnits ?? 'metric'),
      themeMode: ThemeModeSetting.fromDb(row?.themeMode),
      notificationsEnabled: row?.notificationsEnabled ?? true,
      workoutTimerSoundEnabled: row?.workoutTimerSoundEnabled ?? true,
      exerciseAudioEnabled: row?.exerciseAudioEnabled ?? false,
      crashlyticsEnabled: row?.crashlyticsEnabled ?? true,
      redactionStrictMode: row?.redactionStrictMode ?? true,
      diagnosticsEnabled: _featureFlags.diagnosticsEnabled,
      aiEnabled: _featureFlags.aiEnabled,
      importsEnabled: _featureFlags.importsEnabled,
      sharingEnabled: _featureFlags.sharingEnabled,
      progressMediaEnabled: _featureFlags.progressMediaEnabled,
      physiqueAnalysisEnabled: _featureFlags.physiqueAnalysisEnabled,
    );
  }

  @override
  Future<void> saveSettings(SettingsEditDraft draft) async {
    final now = DateTime.now();
    await _appSettingsDao.upsertSettings(
      AppSettingsCompanion(
        id: const Value('default'),
        preferredUnits: Value(draft.preferredUnits.dbValue),
        themeMode: Value(draft.themeMode.dbValue),
        notificationsEnabled: Value(draft.notificationsEnabled),
        workoutTimerSoundEnabled: Value(draft.workoutTimerSoundEnabled),
        exerciseAudioEnabled: Value(draft.exerciseAudioEnabled),
        crashlyticsEnabled: Value(draft.crashlyticsEnabled),
        redactionStrictMode: Value(draft.redactionStrictMode),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
