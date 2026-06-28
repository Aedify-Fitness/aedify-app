import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/domain/settings_view_data.dart';

abstract class SettingsRepository {
  Future<SettingsViewData> getSettings();

  Future<void> saveSettings(SettingsEditDraft draft);
}
