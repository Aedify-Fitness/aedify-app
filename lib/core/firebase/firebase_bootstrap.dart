import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseBootstrap {
  Future<void> initialize() async {
    await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
  }

  Future<bool> get isInitialized async => Firebase.apps.isNotEmpty;
}
