import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseBootstrapProvider = Provider<FirebaseBootstrap>((ref) {
  return FirebaseBootstrap();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final localFileStoreProvider = Provider<LocalFileStore>((ref) {
  return LocalFileStore();
});

final errorMapperProvider = Provider<ErrorMapper>((ref) {
  return const ErrorMapper();
});

final retryPolicyProvider = Provider<RetryPolicy>((ref) {
  return const RetryPolicy();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    logger: ref.read(appLoggerProvider),
    errorMapper: ref.read(errorMapperProvider),
    retryPolicy: ref.read(retryPolicyProvider),
  );
});

final networkStatusProvider = Provider<NetworkStatus>((ref) {
  return NetworkStatus();
});

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService();
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

final privacyClassifierProvider = Provider<PrivacyClassifier>((ref) {
  return const PrivacyClassifier();
});

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return FeatureFlags.defaultFlags;
});

final onboardingStatusProvider = Provider<OnboardingStatus>((ref) {
  return OnboardingStatus.incomplete;
});

final aiAvailabilityProvider = Provider<AiAvailability>((ref) {
  return AiAvailability.missingKey;
});

final draftGuardProvider = Provider<DraftGuard>((ref) {
  return DraftGuard.clear;
});

final localFileRecordDaoProvider = Provider<LocalFileRecordDao>((ref) {
  return LocalFileRecordDao(ref.read(appDatabaseProvider));
});

final localFileRecordServiceProvider = Provider<LocalFileRecordService>((ref) {
  return LocalFileRecordService(
    dao: ref.read(localFileRecordDaoProvider),
    fileStore: ref.read(localFileStoreProvider),
  );
});
