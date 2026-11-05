class AppErrorStrings {
  AppErrorStrings._();
  static const progressSavedPreview =
      'This preview could not be opened. Retry or view another check-in.';
  static const progressSavedVideo =
      'This video could not be played. Retry or view another check-in.';
  static const progressSavedMissing =
      'The original file is missing. Your check-in details are still saved on this device.';

  static const progressVideoMicrophone =
      'Microphone access is blocked. Allow it in device settings to record, or import a video without audio.';
  static const progressVideoUnsupported =
      'This video source or format is unavailable. Choose a supported MP4 or MOV video.';
  static const progressVideoInvalid =
      'This file could not be opened as a video. Choose another MP4 or MOV file.';
  static const progressVideoTooLong =
      'This video exceeds the selected time limit. Choose a shorter video or increase the limit.';
  static const progressVideoTooLarge =
      'Choose a video no larger than 100 MiB. On Android 8.0, use 16 megapixels or less.';
  static const progressVideoPreview =
      'Could not play this video. Retry the preview or replace the video before saving.';
  static const progressPhotoPermission =
      'Camera or photo access is blocked. Allow access in your device settings, or choose another source.';
  static const progressPhotoUnsupported =
      'This photo source is unavailable on this device. Try the photo library.';
  static const progressPhotoInvalid =
      'This file could not be opened as a photo. Choose a JPEG, PNG, WebP or supported HEIC photo.';
  static const progressPhotoTooLarge =
      'Choose a photo smaller than 20 MB and 64 megapixels.';
  static const progressPhotoCleanup =
      'Could not remove the temporary photo. Try again before leaving.';
  static const progressPhotoBodyweight =
      'Enter a positive bodyweight, or leave it empty.';
  static const progressMediaInvalid =
      'Check the progress media and measurements before saving.';
  static const progressMediaMissing =
      'This progress media is no longer available. Choose the file again.';
  static const progressMediaConflict =
      'This progress session or file is already saved. Refresh and try again.';
  static const progressMediaUnavailable =
      'Could not access progress media. Try again.';
  static const analyticsLoadFailed =
      'Could not load your training trends. Try again.';
  static const plateauLoadFailed =
      'Could not check recent training. Your charts are still available.';
  static const plateauDismissFailed =
      'Could not dismiss this signal. Try again.';
  static const weightSuggestionUnavailable =
      'Could not load a weight estimate. You can still log manually.';
  static const weightSuggestionTargetInvalid =
      'Enter 1–10 reps and an RPE from 6 to 10.';
  static const datasetUpdateRequired =
      'Update Aedify to use this exercise dataset.';
  static const draftProgrammeRequiresPublishing =
      'Publish the programme before activating it.';

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

  // Settings
  static const String settingsLoadFailedMessage = 'Could not load settings.';
  static const String settingsSaveFailedMessage = 'Could not save settings.';

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

  // Exercise library
  static const String exercisePreferenceSaveFailed =
      'Could not save this exercise preference. Please try again.';

  // TTS / Audio Cache
  static const String audioGenerationFailedMessage =
      'Could not generate step audio.';
  static const String ttsUnavailableMessage =
      'Text-to-speech is not available on this device.';
  static const String audioPlaybackFailedMessage = 'Could not play step audio.';

  // BYOK
  static const String byokLoadFailedMessage =
      'Could not load AI provider settings.';
  static const String byokSaveFailedMessage =
      'Could not save provider configuration.';
  static const String byokDeleteFailedMessage =
      'Could not delete provider configuration.';
  static const String byokKeyRotationFailed = 'Could not rotate API key.';
  static const String byokEmptyKeyValidation = 'Please enter a valid API key.';
  static const String byokNoProviderValidation = 'Please select a provider.';
  static const String byokKeyValidationFailed =
      'Key rejected by provider. Check the key and try again.';
  static const String byokValidationNetworkError =
      'Could not reach provider to validate key. Check your connection and try again.';

  // Provider capability
  static const String providerCapabilityUnknownMessage =
      'Could not determine provider capabilities.';
  static const String providerCapabilityLoadFailedMessage =
      'Could not load provider capability information.';

  // Workout execution and history
  static const workoutHistoryCorrectionInvalid =
      'Check the logged results: reps, duration and distance must be positive, weight cannot be negative, and RPE must be 1–10.';
  static const workoutHistoryCorrectionFailed =
      'Could not save the correction. Try again.';
  static const workoutHistoryCorrectionConflict =
      'This log has changed. Close this editor and reopen it to use the latest results.';
  static const workoutHistoryCorrectionMissing =
      'This completed session is no longer available. Close this editor and refresh history.';
  static const workoutStartFailed = 'Could not start the workout. Try again.';
  static const workoutCannotRepeat =
      'This completed workout is no longer available to repeat.';
  static const workoutNoCompletedSets =
      'Log at least one set before finishing. You can pause or discard '
      'this workout instead.';
  static const workoutInvalidCompletedSets =
      'Check the actual results for your completed sets before finishing.';
  static const workoutActualsInvalid =
      'Use positive reps, time and distance, weight of zero or more, '
      'RPE from 1 to 10, and RIR from 0 to 5.';

  // Workout builder
  static String workoutNotFoundWithId(String savedWorkoutId) =>
      'Saved workout not found: $savedWorkoutId';

  // Programme builder
  static String programmeNotFoundWithId(String programmeId) =>
      'Programme not found: $programmeId';
}
