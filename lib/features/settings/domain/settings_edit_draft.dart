import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';

class SettingsEditDraft {
  const SettingsEditDraft({
    this.preferredUnits = PreferredUnit.metric,
    this.themeMode = ThemeModeSetting.system,
    this.notificationsEnabled = true,
    this.workoutTimerSoundEnabled = true,
    this.exerciseAudioEnabled = false,
    this.crashlyticsEnabled = true,
    this.redactionStrictMode = true,
  });

  final PreferredUnit preferredUnits;
  final ThemeModeSetting themeMode;
  final bool notificationsEnabled;
  final bool workoutTimerSoundEnabled;
  final bool exerciseAudioEnabled;
  final bool crashlyticsEnabled;
  final bool redactionStrictMode;

  SettingsEditDraft copyWith({
    PreferredUnit? preferredUnits,
    ThemeModeSetting? themeMode,
    bool? notificationsEnabled,
    bool? workoutTimerSoundEnabled,
    bool? exerciseAudioEnabled,
    bool? crashlyticsEnabled,
    bool? redactionStrictMode,
  }) {
    return SettingsEditDraft(
      preferredUnits: preferredUnits ?? this.preferredUnits,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      workoutTimerSoundEnabled:
          workoutTimerSoundEnabled ?? this.workoutTimerSoundEnabled,
      exerciseAudioEnabled: exerciseAudioEnabled ?? this.exerciseAudioEnabled,
      crashlyticsEnabled: crashlyticsEnabled ?? this.crashlyticsEnabled,
      redactionStrictMode: redactionStrictMode ?? this.redactionStrictMode,
    );
  }
}
