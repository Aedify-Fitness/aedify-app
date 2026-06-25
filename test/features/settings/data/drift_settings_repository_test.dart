import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';
import 'package:aedify/features/settings/data/drift_settings_repository.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftSettingsRepository(
      appSettingsDao: AppSettingsDao(db),
      featureFlags: FeatureFlags.defaultFlags,
    );
  });

  tearDown(() {
    db.close();
  });

  group('DriftSettingsRepository', () {
    test('getSettings returns defaults when no row exists', () async {
      final settings = await repository.getSettings();

      expect(settings.preferredUnits, equals(PreferredUnit.metric));
      expect(settings.themeMode, equals(ThemeModeSetting.system));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.workoutTimerSoundEnabled, isTrue);
      expect(settings.exerciseAudioEnabled, isFalse);
      expect(settings.crashlyticsEnabled, isTrue);
      expect(settings.redactionStrictMode, isTrue);
      expect(settings.diagnosticsEnabled, isFalse);
    });

    test('saveSettings persists durable settings', () async {
      await repository.saveSettings(
        const SettingsEditDraft(
          preferredUnits: PreferredUnit.imperial,
          themeMode: ThemeModeSetting.dark,
          notificationsEnabled: false,
          workoutTimerSoundEnabled: false,
          exerciseAudioEnabled: true,
          crashlyticsEnabled: false,
          redactionStrictMode: false,
        ),
      );

      final settings = await repository.getSettings();
      expect(settings.preferredUnits, equals(PreferredUnit.imperial));
      expect(settings.themeMode, equals(ThemeModeSetting.dark));
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.workoutTimerSoundEnabled, isFalse);
      expect(settings.exerciseAudioEnabled, isTrue);
      expect(settings.crashlyticsEnabled, isFalse);
      expect(settings.redactionStrictMode, isFalse);
    });

    test('feature flags are exposed as status-only values', () async {
      final repoWithFlags = DriftSettingsRepository(
        appSettingsDao: AppSettingsDao(db),
        featureFlags: const FeatureFlags(
          diagnosticsEnabled: true,
          aiEnabled: false,
          importsEnabled: false,
          sharingEnabled: true,
          progressMediaEnabled: false,
          physiqueAnalysisEnabled: true,
        ),
      );

      final settings = await repoWithFlags.getSettings();
      expect(settings.diagnosticsEnabled, isTrue);
      expect(settings.aiEnabled, isFalse);
      expect(settings.importsEnabled, isFalse);
      expect(settings.sharingEnabled, isTrue);
      expect(settings.progressMediaEnabled, isFalse);
      expect(settings.physiqueAnalysisEnabled, isTrue);
    });
  });
}
