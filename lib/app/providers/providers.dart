import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
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
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_video_state_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_service.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/data/candidate_exercise_query_service.dart';
import 'package:aedify/features/exercise_library/data/drift_candidate_exercise_query_service.dart';
import 'package:aedify/features/bodymap/application/bodymap_selection_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
    return OnboardingStatus.incomplete;
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
    return DriftExerciseRepository(database: ref.read(appDatabaseProvider));
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
}
