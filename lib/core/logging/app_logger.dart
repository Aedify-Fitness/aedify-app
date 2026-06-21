import 'dart:developer' as dev;
import 'package:aedify/core/privacy/privacy_classifier.dart';

class AppLogger {
  static const loggerName = 'aedify';
  AppLogger({PrivacyClassifier? classifier, this.name = AppLogger.loggerName});

  final String name;

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warn(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
