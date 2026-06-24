class AppErrorStrings {
  AppErrorStrings._();

  static const String storageErrorMessage = 'Storage error';
  static const String downloadFailedMessage = 'Download failed';
  static const String anonymousSignInFailedMessage = 'Anonymous sign-in failed';
  static const String notFoundMessage = 'The requested resource was not found.';
  static const String secureStorageUnavailableMessage =
      'Secure storage is unavailable.';
  static const String rateLimitedMessage =
      'Please wait a moment and try again.';
  static const String unexpectedStatusMessage =
      'Something went wrong. Please try again.';
  static const String unknownNetworkErrorMessage =
      'Something went wrong. Please try again.';
  static const String unauthorizedMessage =
      'Please check your credentials and try again.';
  static const String serverErrorMessage =
      'A server error occurred. Please try again later.';
  static const String forbiddenMessage =
      'You do not have permission to perform this action.';
  static const String badCertificateMessage =
      'A security error occurred. Please try again later.';
  static const String networkUnreachableMessage =
      'Could not connect. Please check your internet connection.';
  static const String networkTimeoutMessage =
      'Connection timed out. Please check your connection and try again.';

  // Profile
  static const String profileLoadFailedMessage = 'Could not load profile.';
  static const String profileSaveFailedMessage =
      'Could not save profile changes.';
  static const String profileValidationFailedMessage =
      'Please correct the highlighted profile fields.';

  // Onboarding
  static const String onboardingSaveFailedMessage =
      'Could not save onboarding data.';
  static const String onboardingLoadFailedMessage =
      'Could not load onboarding progress.';

  // TTS / Audio Cache
  static const String audioGenerationFailedMessage =
      'Could not generate step audio.';
  static const String ttsUnavailableMessage =
      'Text-to-speech is not available on this device.';
  static const String audioPlaybackFailedMessage = 'Could not play step audio.';
}
