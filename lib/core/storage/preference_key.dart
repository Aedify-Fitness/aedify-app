enum PreferenceKey {
  onboardingCompleted('onboarding_completed'),
  lastSeenVersion('last_seen_version'),
  themeMode('theme_mode'),
  selectedLocale('selected_locale'),
  aiDefaultProvider('ai_default_provider'),
  aiDefaultModel('ai_default_model'),
  hasCompletedSetup('has_completed_setup'),
  lastAnalyticsSync('last_analytics_sync'),
  lastPlateauCheck('last_plateau_check'),
  onboardingStep('onboarding_step');

  final String key;
  const PreferenceKey(this.key);
}
