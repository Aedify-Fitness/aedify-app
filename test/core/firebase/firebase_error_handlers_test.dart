import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/firebase/firebase_error_handlers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/privacy/fake_crashlytics_capture.dart';

void main() {
  test('global Flutter and platform errors pass through redaction', () {
    final capture = FakeCrashlyticsCapture();
    final handlers = FirebaseErrorHandlers(CrashlyticsService(client: capture));
    handlers.reportFlutterError(
      FlutterErrorDetails(
        exception: StateError('synthetic-private-sentinel'),
        context: ErrorDescription('synthetic-private-context'),
        informationCollector: () => [
          ErrorDescription('synthetic-private-info'),
        ],
      ),
    );
    expect(
      capture.recordedException.toString(),
      isNot(contains('synthetic-private')),
    );
    expect(capture.recordedReason, isNull);
    expect(
      handlers.reportPlatformError(
        StateError('synthetic-private-sentinel'),
        StackTrace.empty,
      ),
      isTrue,
    );
    expect(
      capture.recordedException.toString(),
      isNot(contains('synthetic-private')),
    );
  });

  test('disabled crash reporting remains disabled for global handlers', () {
    final capture = FakeCrashlyticsCapture();
    final handlers = FirebaseErrorHandlers(
      CrashlyticsService(client: capture, enabled: false),
    );
    handlers.reportFlutterError(
      FlutterErrorDetails(exception: StateError('private')),
    );
    handlers.reportPlatformError(StateError('private'), StackTrace.empty);
    expect(capture.recordedException, isNull);
  });
}
