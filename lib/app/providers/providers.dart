import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/dio_client.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
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

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
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
