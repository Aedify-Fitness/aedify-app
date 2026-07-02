import 'package:flutter/foundation.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseBootstrap {
  static final _logger = AppLogger(name: 'FirebaseBootstrap');

  Future<void> initialize() async {
    _logger.info('initialize');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      _logger.info('initialize — complete');
    } catch (e) {
      _logger.error('initialize failed', error: e);
      rethrow;
    }
  }

  Future<bool> get isInitialized async => Firebase.apps.isNotEmpty;
}
