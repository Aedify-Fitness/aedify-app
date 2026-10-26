import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/firebase/firebase_error_handlers.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseBootstrap {
  FirebaseBootstrap({CrashlyticsService? crashlyticsService})
    : _crashlytics = crashlyticsService ?? CrashlyticsService(enabled: false);

  final CrashlyticsService _crashlytics;
  static final _logger = AppLogger(name: 'FirebaseBootstrap');

  Future<void> initialize() async {
    _logger.info('initialize');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _crashlytics.enabled,
      );
      FirebaseErrorHandlers(_crashlytics).install();
      _logger.info('initialize — complete');
    } catch (e) {
      _logger.error('initialize failed', error: e);
      rethrow;
    }
  }

  Future<bool> get isInitialized async => Firebase.apps.isNotEmpty;
}
