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
      expect(
        classifier.isAllowedInExport(PrivacyClass.publicStatic),
        isTrue,
      );
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
  });
}
