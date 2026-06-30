import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/ai_model_capability_dao.dart';
import 'package:aedify/core/db/daos/ai_provider_config_dao.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';
import 'package:aedify/core/db/daos/body_measurement_dao.dart';
import 'package:aedify/core/db/daos/exercise_audio_cache_dao.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/core/db/daos/program_dao.dart';
import 'package:aedify/core/db/daos/program_workout_template_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/program_week_dao.dart';
import 'package:aedify/core/db/daos/program_workout_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/saved_workout_dao.dart';
import 'package:aedify/core/db/daos/saved_workout_exercise_dao.dart';
import 'package:aedify/core/db/daos/saved_workout_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/program_revision_dao.dart';
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
import 'package:aedify/features/exercise_library/data/dataset/exercise_library_importer.dart';
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
import 'package:aedify/features/profile/data/default_profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/drift_profile_repository.dart';
import 'package:aedify/features/profile/data/profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/settings/application/byok_setup_controller.dart';
import 'package:aedify/features/settings/application/settings_controller.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/data/default_provider_gate_service.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/drift_provider_capability_repository.dart';
import 'package:aedify/features/settings/data/drift_settings_repository.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_gate_service.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:aedify/features/settings/application/provider_capability_controller.dart';
import 'package:aedify/features/settings/application/provider_capability_state.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/data/drift_programme_repository.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/data/drift_saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_controller.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_validator.dart';
import 'package:aedify/features/workout_builder/application/load_workout_draft_use_case.dart';
import 'package:aedify/features/workout_builder/application/save_workout_draft_use_case.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/programme_builder_validator.dart';
import 'package:aedify/features/programmes/application/load_programme_builder_draft_use_case.dart';
import 'package:aedify/features/programmes/application/save_programme_builder_draft_use_case.dart';
import 'package:aedify/features/workout_execution/data/drift_workout_session_repository.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
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

  static final exerciseLibraryImporterProvider =
      Provider<ExerciseLibraryImporter>((ref) {
        return ExerciseLibraryImporter(
          database: ref.read(appDatabaseProvider),
          exerciseDao: ref.read(exerciseDaoProvider),
          exerciseVideoDao: ref.read(exerciseVideoDaoProvider),
          libraryMetaDao: ref.read(libraryMetaDaoProvider),
        );
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
      strengthAnchorDao: ref.read(strengthAnchorDaoProvider),
    );
  });

  static final profileControllerProvider =
      AsyncNotifierProvider<ProfileController, ProfileState>(
        ProfileController.new,
      );

  static final profileCandidatePreferencesServiceProvider =
      Provider<ProfileCandidatePreferencesService>((ref) {
        return DefaultProfileCandidatePreferencesService(
          profileRepository: ref.read(profileRepositoryProvider),
        );
      });

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

  // BYOK
  static final aiProviderConfigDaoProvider = Provider<AiProviderConfigDao>((
    ref,
  ) {
    return AiProviderConfigDao(ref.read(appDatabaseProvider));
  });

  static final byokRepositoryProvider = Provider<ByokRepository>((ref) {
    return DriftByokRepository(
      configDao: ref.read(aiProviderConfigDaoProvider),
      secureStorageService: ref.read(secureStorageProvider),
    );
  });

  static final byokSetupControllerProvider =
      AsyncNotifierProvider<ByokSetupController, ByokSetupState>(
        ByokSetupController.new,
      );

  // Provider capability
  static final aiModelCapabilityDaoProvider = Provider<AiModelCapabilityDao>((
    ref,
  ) {
    return AiModelCapabilityDao(ref.read(appDatabaseProvider));
  });

  static final providerCapabilityRepositoryProvider =
      Provider<ProviderCapabilityRepository>((ref) {
        return DriftProviderCapabilityRepository(
          capabilityDao: ref.read(aiModelCapabilityDaoProvider),
        );
      });

  static final providerGateServiceProvider = Provider<ProviderGateService>((
    ref,
  ) {
    return DefaultProviderGateService(
      byokRepository: ref.read(byokRepositoryProvider),
      capabilityRepository: ref.read(providerCapabilityRepositoryProvider),
      networkStatus: ref.read(networkStatusProvider),
    );
  });

  static final providerCapabilityControllerProvider =
      AsyncNotifierProvider.family<
        ProviderCapabilityController,
        ProviderCapabilityState,
        ({AiProviderName providerName, String modelName})
      >((arg) => ProviderCapabilityController(arg.providerName, arg.modelName));

  // M4 DAO providers
  static final programDaoProvider = Provider<ProgramDao>((ref) {
    return ProgramDao(ref.read(appDatabaseProvider));
  });

  static final programWorkoutTemplateDaoProvider =
      Provider<ProgramWorkoutTemplateDao>((ref) {
        return ProgramWorkoutTemplateDao(ref.read(appDatabaseProvider));
      });

  static final programTemplateExerciseDaoProvider =
      Provider<ProgramTemplateExerciseDao>((ref) {
        return ProgramTemplateExerciseDao(ref.read(appDatabaseProvider));
      });

  static final programTemplateExerciseSetDaoProvider =
      Provider<ProgramTemplateExerciseSetDao>((ref) {
        return ProgramTemplateExerciseSetDao(ref.read(appDatabaseProvider));
      });

  static final programWeekDaoProvider = Provider<ProgramWeekDao>((ref) {
    return ProgramWeekDao(ref.read(appDatabaseProvider));
  });

  static final programWorkoutDaoProvider = Provider<ProgramWorkoutDao>((ref) {
    return ProgramWorkoutDao(ref.read(appDatabaseProvider));
  });

  static final programExerciseDaoProvider = Provider<ProgramExerciseDao>((ref) {
    return ProgramExerciseDao(ref.read(appDatabaseProvider));
  });

  static final programExerciseSetDaoProvider = Provider<ProgramExerciseSetDao>((
    ref,
  ) {
    return ProgramExerciseSetDao(ref.read(appDatabaseProvider));
  });

  static final savedWorkoutDaoProvider = Provider<SavedWorkoutDao>((ref) {
    return SavedWorkoutDao(ref.read(appDatabaseProvider));
  });

  static final savedWorkoutExerciseDaoProvider =
      Provider<SavedWorkoutExerciseDao>((ref) {
        return SavedWorkoutExerciseDao(ref.read(appDatabaseProvider));
      });

  static final savedWorkoutExerciseSetDaoProvider =
      Provider<SavedWorkoutExerciseSetDao>((ref) {
        return SavedWorkoutExerciseSetDao(ref.read(appDatabaseProvider));
      });

  static final workoutSessionDaoProvider = Provider<WorkoutSessionDao>((ref) {
    return WorkoutSessionDao(ref.read(appDatabaseProvider));
  });

  static final workoutSessionExerciseDaoProvider =
      Provider<WorkoutSessionExerciseDao>((ref) {
        return WorkoutSessionExerciseDao(ref.read(appDatabaseProvider));
      });

  static final setLogDaoProvider = Provider<SetLogDao>((ref) {
    return SetLogDao(ref.read(appDatabaseProvider));
  });

  static final programRevisionDaoProvider = Provider<ProgramRevisionDao>((ref) {
    return ProgramRevisionDao(ref.read(appDatabaseProvider));
  });

  // M4 repository providers
  static final programmeRepositoryProvider = Provider<ProgrammeRepository>((
    ref,
  ) {
    return DriftProgrammeRepository(
      database: ref.read(appDatabaseProvider),
      programDao: ref.read(programDaoProvider),
      programWorkoutTemplateDao: ref.read(programWorkoutTemplateDaoProvider),
      programTemplateExerciseDao: ref.read(programTemplateExerciseDaoProvider),
      programTemplateExerciseSetDao: ref.read(
        programTemplateExerciseSetDaoProvider,
      ),
      programWeekDao: ref.read(programWeekDaoProvider),
      programWorkoutDao: ref.read(programWorkoutDaoProvider),
      programExerciseDao: ref.read(programExerciseDaoProvider),
      programExerciseSetDao: ref.read(programExerciseSetDaoProvider),
      programRevisionDao: ref.read(programRevisionDaoProvider),
    );
  });

  static final savedWorkoutRepositoryProvider =
      Provider<SavedWorkoutRepository>((ref) {
        return DriftSavedWorkoutRepository(
          database: ref.read(appDatabaseProvider),
          savedWorkoutDao: ref.read(savedWorkoutDaoProvider),
          savedWorkoutExerciseDao: ref.read(savedWorkoutExerciseDaoProvider),
          savedWorkoutExerciseSetDao: ref.read(
            savedWorkoutExerciseSetDaoProvider,
          ),
        );
      });

  static final workoutSessionRepositoryProvider =
      Provider<WorkoutSessionRepository>((ref) {
        return DriftWorkoutSessionRepository(
          database: ref.read(appDatabaseProvider),
          workoutSessionDao: ref.read(workoutSessionDaoProvider),
          workoutSessionExerciseDao: ref.read(
            workoutSessionExerciseDaoProvider,
          ),
          setLogDao: ref.read(setLogDaoProvider),
        );
      });

  static final workoutBuilderValidatorProvider =
      Provider<WorkoutBuilderValidator>((ref) {
        return const WorkoutBuilderValidator();
      });

  static final loadWorkoutDraftUseCaseProvider =
      Provider<LoadWorkoutDraftUseCase>((ref) {
        return LoadWorkoutDraftUseCase(
          savedWorkoutRepository: ref.read(savedWorkoutRepositoryProvider),
        );
      });

  static final saveWorkoutDraftUseCaseProvider =
      Provider<SaveWorkoutDraftUseCase>((ref) {
        return SaveWorkoutDraftUseCase(
          savedWorkoutRepository: ref.read(savedWorkoutRepositoryProvider),
        );
      });

  static final workoutBuilderControllerProvider =
      AsyncNotifierProvider.family<
        WorkoutBuilderController,
        WorkoutBuilderState,
        ({WorkoutBuilderMode mode, String? savedWorkoutId})
      >((arg) => WorkoutBuilderController(arg.mode, arg.savedWorkoutId));

  // Programme builder
  static final programmeBuilderValidatorProvider =
      Provider<ProgrammeBuilderValidator>((ref) {
        return const ProgrammeBuilderValidator();
      });

  static final loadProgrammeBuilderDraftUseCaseProvider =
      Provider<LoadProgrammeBuilderDraftUseCase>((ref) {
        return LoadProgrammeBuilderDraftUseCase(
          programmeRepository: ref.read(programmeRepositoryProvider),
        );
      });

  static final saveProgrammeBuilderDraftUseCaseProvider =
      Provider<SaveProgrammeBuilderDraftUseCase>((ref) {
        return SaveProgrammeBuilderDraftUseCase(
          programmeRepository: ref.read(programmeRepositoryProvider),
        );
      });

  static final programmeBuilderControllerProvider =
      AsyncNotifierProvider.family<
        ProgrammeBuilderController,
        ProgrammeBuilderState,
        ({ProgrammeBuilderMode mode, String? programmeId})
      >((arg) => ProgrammeBuilderController(arg.mode, arg.programmeId));
}
