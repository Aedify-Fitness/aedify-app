enum PreferenceKey {
  onboardingCompleted('onboarding_completed'),
  hasSeenOnboardingIntro('has_seen_onboarding_intro'),
  lastSelectedTab('last_selected_tab'),
  themeMode('theme_mode'),
  lastOpenedLibraryFilter('last_opened_library_filter'),
  featureFlagOverrides('feature_flag_overrides');

  final String key;
  const PreferenceKey(this.key);
}
