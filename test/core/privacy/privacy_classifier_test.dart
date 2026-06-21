import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';

void main() {
  group('PrivacyClassifier', () {
    late PrivacyClassifier classifier;

    setUp(() {
      classifier = const PrivacyClassifier();
    });

    test('allows public static in crashlytics', () {
      expect(
        classifier.isAllowedInCrashlytics(PrivacyClass.publicStatic),
        isTrue,
      );
    });

    test('allows diagnostic safe in crashlytics', () {
      expect(
        classifier.isAllowedInCrashlytics(PrivacyClass.diagnosticSafe),
        isTrue,
      );
    });

    test('rejects local personal in crashlytics', () {
      expect(
        classifier.isAllowedInCrashlytics(PrivacyClass.localPersonal),
        isFalse,
      );
    });

    test('rejects secret in crashlytics', () {
      expect(classifier.isAllowedInCrashlytics(PrivacyClass.secret), isFalse);
    });

    test('allows public static in export', () {
      expect(classifier.isAllowedInExport(PrivacyClass.publicStatic), isTrue);
    });

    test('allows exportable plan content in export', () {
      expect(
        classifier.isAllowedInExport(PrivacyClass.exportablePlanContent),
        isTrue,
      );
    });

    test('rejects local personal in export', () {
      expect(classifier.isAllowedInExport(PrivacyClass.localPersonal), isFalse);
    });

    test('allows public static in logs', () {
      expect(classifier.isAllowedInLog(PrivacyClass.publicStatic), isTrue);
    });

    test('rejects secret in logs', () {
      expect(classifier.isAllowedInLog(PrivacyClass.secret), isFalse);
    });

    group('isDiagnosticFieldAllowed', () {
      test('allows known diagnostic fields', () {
        expect(classifier.isDiagnosticFieldAllowed('app_version'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('build_number'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('platform'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('os_version'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('device_model'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('screen_name'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('route_name'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('error_code'), isTrue);
        expect(classifier.isDiagnosticFieldAllowed('operation_name'), isTrue);
      });

      test('blocks forbidden fields', () {
        expect(classifier.isDiagnosticFieldAllowed('api_key'), isFalse);
        expect(classifier.isDiagnosticFieldAllowed('prompt'), isFalse);
        expect(classifier.isDiagnosticFieldAllowed('response'), isFalse);
        expect(classifier.isDiagnosticFieldAllowed('chat_history'), isFalse);
        expect(classifier.isDiagnosticFieldAllowed('file_path'), isFalse);
        expect(
          classifier.isDiagnosticFieldAllowed('body_measurements'),
          isFalse,
        );
        expect(classifier.isDiagnosticFieldAllowed('set_logs'), isFalse);
      });

      test('allows unknown fields as public static', () {
        expect(classifier.isDiagnosticFieldAllowed('unknown_field'), isTrue);
      });
    });

    group('classifyField', () {
      test('returns diagnosticSafe for allowed fields', () {
        expect(
          classifier.classifyField('app_version'),
          equals(PrivacyClass.diagnosticSafe),
        );
      });

      test('returns secret for forbidden fields', () {
        expect(
          classifier.classifyField('api_key'),
          equals(PrivacyClass.secret),
        );
        expect(classifier.classifyField('prompt'), equals(PrivacyClass.secret));
      });

      test('returns publicStatic for unknown fields', () {
        expect(
          classifier.classifyField('unknown'),
          equals(PrivacyClass.publicStatic),
        );
      });
    });
  });
}
