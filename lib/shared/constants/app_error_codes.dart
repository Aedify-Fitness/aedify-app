class AppErrorCodes {
  AppErrorCodes._();

  // Workout Builder Validator
  static const String missingName = 'missing_name';
  static const String noExercises = 'no_exercises';
  static const String noSets = 'no_sets';
  static const String invalidRepsMin = 'invalid_reps_min';
  static const String invalidRepsMax = 'invalid_reps_max';
  static const String invalidRepsExact = 'invalid_reps_exact';
  static const String invalidWeight = 'invalid_weight';
  static const String invalidRpeMin = 'invalid_rpe_min';
  static const String invalidRpeMax = 'invalid_rpe_max';
  static const String rpeRange = 'rpe_range';
  static const String invalidRir = 'invalid_rir';
  static const String invalidRest = 'invalid_rest';

  // Network
  static const String networkTimeout = 'network_timeout';
  static const String requestCancelled = 'request_cancelled';
  static const String networkUnreachable = 'network_unreachable';
  static const String badCertificate = 'bad_certificate';
  static const String unknownNetworkError = 'unknown_network_error';
  static const String unauthorized = 'unauthorized';
  static const String forbidden = 'forbidden';
  static const String notFound = 'not_found';
  static const String rateLimited = 'rate_limited';
  static const String serverError = 'server_error';
  static const String unexpectedStatus = 'unexpected_status';

  // General
  static const String startupError = 'startup_error';
  static const String unknown = 'unknown';

  // Workout Builder
  static const String loadFailed = 'load_failed';
  static const String saveFailed = 'save_failed';

  // Exercise Library
  static const String searchFailed = 'search_failed';

  // Profile
  static const String profileLoadFailed = 'profile_load_failed';
  static const String profileSaveFailed = 'profile_save_failed';

  // Settings
  static const String settingsLoadFailed = 'settings_load_failed';
  static const String settingsSaveFailed = 'settings_save_failed';

  // BYOK
  static const String byokLoadFailed = 'byok_load_failed';
  static const String byokSaveFailed = 'byok_save_failed';
  static const String byokRotateFailed = 'byok_rotate_failed';
  static const String byokDeleteFailed = 'byok_delete_failed';
  static const String byokSetActiveFailed = 'byok_set_active_failed';

  // Provider Capability
  static const String capabilityLoadFailed = 'capability_load_failed';

  // Onboarding
  static const String onboardingSaveFailed = 'onboarding_save_failed';
  static const String onboardingClearFailed = 'onboarding_clear_failed';
  static const String onboardingLoadFailed = 'onboarding_load_failed';

  // Audio/TTS
  static const String ttsUnavailable = 'tts_unavailable';
  static const String audioPlaybackFailed = 'audio_playback_failed';

  // Programme Builder
  static const String programmeSaveFailed = 'programme_save_failed';
  static const String programmeLoadFailed = 'programme_load_failed';
  static const String noWeeks = 'no_weeks';
  static const String noSlots = 'no_slots';
  static const String noTemplates = 'no_templates';
  static const String missingTemplate = 'missing_template';
  static const String nonSequentialWeek = 'non_sequential_week';

  // Key Validation
  static const String unsupportedProvider = 'unsupported_provider';
  static const String invalidKey = 'invalid_key';
  static const String validationFailed = 'validation_failed';
}
