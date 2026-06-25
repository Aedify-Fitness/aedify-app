import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';
import 'package:aedify/core/db/daos/body_measurement_dao.dart';
import 'package:aedify/core/db/daos/exercise_audio_cache_dao.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/exercise_video_dao.dart';
import 'package:aedify/core/db/daos/library_meta_dao.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/firebase/firebase_auth_service.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/dio_client.dart';
import 'package:aedify/core/network/error_mapper.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/network/retry_policy.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/storage/local_file_record_service.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/core/storage/preferences_service.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:aedify/core/tts/exercise_tts_service.dart';
import 'package:aedify/core/tts/flutter_exercise_tts_service.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_step_audio_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_video_state_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_service.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/data/candidate_exercise_query_service.dart';
import 'package:aedify/features/exercise_library/data/custom_exercise_identity_service.dart';
import 'package:aedify/features/exercise_library/data/drift_candidate_exercise_query_service.dart';
import 'package:aedify/features/bodymap/application/bodymap_selection_controller.dart';
import 'package:aedify/features/onboarding/application/onboarding_controller.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:aedify/features/profile/application/profile_controller.dart';
import 'package:aedify/features/profile/data/drift_profile_repository.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/settings/application/settings_controller.dart';
import 'package:aedify/features/settings/data/drift_settings_repository.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// App-wide Riverpod provider definitions.
///
/// All providers are static members of [AppProviders] so they can be
/// referenced as `AppProviders.providerName` throughout the codebase.
/// This keeps the DI graph in a single, discoverable location while
/// avoiding top-level provider declarations.
class AppProviders {
  AppProviders._();

  static final firebaseBootstrapProvider = Provider<FirebaseBootstrap>((ref) {
    return FirebaseBootstrap();
  });

  static final appDatabaseProvider = Provider<AppDatabase>((ref) {
    return AppDatabase();
  });

  static final secureStorageProvider = Provider<SecureStorageService>((ref) {
    return SecureStorageService();
  });

  static final preferencesServiceProvider = Provider<PreferencesService>((ref) {
    return PreferencesService();
  });

  static final localFileStoreProvider = Provider<LocalFileStore>((ref) {
    return LocalFileStore();
  });

  static final errorMapperProvider = Provider<ErrorMapper>((ref) {
    return const ErrorMapper();
  });

  static final retryPolicyProvider = Provider<RetryPolicy>((ref) {
    return const RetryPolicy();
  });

  static final dioClientProvider = Provider<DioClient>((ref) {
    return DioClient(
      logger: ref.read(appLoggerProvider),
      errorMapper: ref.read(errorMapperProvider),
      retryPolicy: ref.read(retryPolicyProvider),
    );
  });

  static final networkStatusProvider = Provider<NetworkStatus>((ref) {
    return NetworkStatus();
  });

  static final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
    final featureFlags = ref.read(featureFlagsProvider);
    return CrashlyticsService(
      client: const FirebaseCrashlyticsClient(),
      classifier: ref.read(privacyClassifierProvider),
      enabled: featureFlags.crashlyticsEnabled,
    );
  });

  static final appLoggerProvider = Provider<AppLogger>((ref) {
    return AppLogger();
  });

  static final privacyClassifierProvider = Provider<PrivacyClassifier>((ref) {
    return const PrivacyClassifier();
  });

  static final featureFlagsProvider = Provider<FeatureFlags>((ref) {
    return FeatureFlags.defaultFlags;
  });

  static final onboardingRepositoryProvider = Provider<OnboardingRepository>((
    ref,
  ) {
    return DriftOnboardingRepository(
      database: ref.read(AppProviders.appDatabaseProvider),
    );
  });

  static final onboardingControllerProvider =
      AsyncNotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new,
      );

  static final onboardingStatusProvider = FutureProvider<OnboardingStatus>((
    ref,
  ) async {
    final repository = ref.read(onboardingRepositoryProvider);
    final complete = await repository.isOnboardingCompleted();
    return complete ? OnboardingStatus.complete : OnboardingStatus.incomplete;
  });

  static final aiAvailabilityProvider = Provider<AiAvailability>((ref) {
    return AiAvailability.missingKey;
  });

  static final draftGuardProvider = Provider<DraftGuard>((ref) {
    return DraftGuard.clear;
  });

  static final localFileRecordDaoProvider = Provider<LocalFileRecordDao>((ref) {
    return LocalFileRecordDao(ref.read(appDatabaseProvider));
  });

  static final localFileRecordServiceProvider =
      Provider<LocalFileRecordService>((ref) {
        return LocalFileRecordService(
          dao: ref.read(localFileRecordDaoProvider),
          fileStore: ref.read(localFileStoreProvider),
        );
      });

  static final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((
    ref,
  ) {
    return FirebaseAuthService();
  });

  static final firebaseStorageClientProvider = Provider<FirebaseStorageClient>((
    ref,
  ) {
    return FirebaseStorageClient();
  });

  static final exerciseDatasetDownloadServiceProvider =
      Provider<ExerciseDatasetDownloadService>((ref) {
        return ExerciseDatasetDownloadService(
          authService: ref.read(firebaseAuthServiceProvider),
          storageClient: ref.read(firebaseStorageClientProvider),
          fileStore: ref.read(localFileStoreProvider),
          logger: ref.read(appLoggerProvider),
        );
      });

  static final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
    return DriftExerciseRepository(
      database: ref.read(appDatabaseProvider),
      identityService: ref.read(customExerciseIdentityServiceProvider),
    );
  });

  static final customExerciseIdentityServiceProvider =
      Provider<CustomExerciseIdentityService>((ref) {
        return const CustomExerciseIdentityService();
      });

  static final exerciseSearchControllerProvider =
      NotifierProvider<ExerciseSearchController, ExerciseSearchState>(
        ExerciseSearchController.new,
      );

  static final exerciseDetailControllerProvider =
      FutureProvider.family<ExerciseDetailViewData?, int>((ref, id) {
        final repository = ref.read(exerciseRepositoryProvider);
        return repository.getExerciseDetail(id);
      });

  static final exerciseVideoStateControllerProvider =
      NotifierProvider<
        ExerciseVideoStateController,
        Map<String, ExerciseVideoPlaybackState>
      >(ExerciseVideoStateController.new);

  static final bodymapSelectionControllerProvider =
      NotifierProvider<BodymapSelectionController, BodymapSelectionState>(
        BodymapSelectionController.new,
      );

  static final candidateExerciseQueryServiceProvider =
      Provider<CandidateExerciseQueryService>((ref) {
        return DriftCandidateExerciseQueryService(
          database: ref.read(appDatabaseProvider),
        );
      });

  static final exerciseDaoProvider = Provider<ExerciseDao>((ref) {
    return ExerciseDao(ref.read(appDatabaseProvider));
  });

  static final exerciseVideoDaoProvider = Provider<ExerciseVideoDao>((ref) {
    return ExerciseVideoDao(ref.read(appDatabaseProvider));
  });

  static final libraryMetaDaoProvider = Provider<LibraryMetaDao>((ref) {
    return LibraryMetaDao(ref.read(appDatabaseProvider));
  });

  static final exerciseDatasetSyncControllerProvider =
      AsyncNotifierProvider<
        ExerciseDatasetSyncController,
        ExerciseDatasetSyncState
      >(ExerciseDatasetSyncController.new);

  static final exerciseTtsServiceProvider = Provider<ExerciseTtsService>((ref) {
    return FlutterExerciseTtsService(
      flutterTts: FlutterTts(),
      fileStore: ref.read(localFileStoreProvider),
    );
  });

  static final exerciseAudioCacheDaoProvider = Provider<ExerciseAudioCacheDao>((
    ref,
  ) {
    return ExerciseAudioCacheDao(ref.read(appDatabaseProvider));
  });

  static final exerciseStepAudioControllerProvider =
      NotifierProvider<
        ExerciseStepAudioController,
        Map<String, ExerciseStepAudioState>
      >(ExerciseStepAudioController.new);

  // Profile DAOs
  static final userProfileDaoProvider = Provider<UserProfileDao>((ref) {
    return UserProfileDao(ref.read(appDatabaseProvider));
  });

  static final strengthAnchorDaoProvider = Provider<StrengthAnchorDao>((ref) {
    return StrengthAnchorDao(ref.read(appDatabaseProvider));
  });

  static final bodyMeasurementDaoProvider = Provider<BodyMeasurementDao>((ref) {
    return BodyMeasurementDao(ref.read(appDatabaseProvider));
  });

  static final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
    return AppSettingsDao(ref.read(appDatabaseProvider));
  });

  // Profile repository and controller
  static final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
    return DriftProfileRepository(
      database: ref.read(appDatabaseProvider),
      userProfileDao: ref.read(userProfileDaoProvider),
      appSettingsDao: ref.read(appSettingsDaoProvider),
      strengthAnchorDao: ref.read(strengthAnchorDaoProvider),
      bodyMeasurementDao: ref.read(bodyMeasurementDaoProvider),
    );
  });

  static final profileControllerProvider =
      AsyncNotifierProvider<ProfileController, ProfileState>(
        ProfileController.new,
      );

  // Settings
  static final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
    return DriftSettingsRepository(
      appSettingsDao: ref.read(appSettingsDaoProvider),
      featureFlags: ref.read(featureFlagsProvider),
    );
  });

  static final settingsControllerProvider =
      AsyncNotifierProvider<SettingsController, SettingsState>(
        SettingsController.new,
      );
}
