import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';

class SettingsViewData {
  const SettingsViewData({
    required this.preferredUnits,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.workoutTimerSoundEnabled,
    required this.exerciseAudioEnabled,
    required this.crashlyticsEnabled,
    required this.redactionStrictMode,
    required this.diagnosticsEnabled,
    required this.aiEnabled,
    required this.importsEnabled,
    required this.sharingEnabled,
    required this.progressMediaEnabled,
    required this.physiqueAnalysisEnabled,
  });

  final PreferredUnit preferredUnits;
  final ThemeModeSetting themeMode;
  final bool notificationsEnabled;
  final bool workoutTimerSoundEnabled;
  final bool exerciseAudioEnabled;
  final bool crashlyticsEnabled;
  final bool redactionStrictMode;
  final bool diagnosticsEnabled;
  final bool aiEnabled;
  final bool importsEnabled;
  final bool sharingEnabled;
  final bool progressMediaEnabled;
  final bool physiqueAnalysisEnabled;
}
