import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () => messenger.setMockMethodCallHandler(
      NativeAnalyticsCsvDestination.channel,
      null,
    ),
  );
  test(
    'only explicitly supplied bytes cross the destination boundary; saved/cancelled are distinct',
    () async {
      final destination = NativeAnalyticsCsvDestination();
      for (final saved in [true, false]) {
        messenger.setMockMethodCallHandler(
          NativeAnalyticsCsvDestination.channel,
          (call) async {
            expect(call.method, 'save');
            expect((call.arguments as Map).keys, ['bytes']);
            expect(call.arguments['bytes'], [1, 2, 3]);
            return saved;
          },
        );
        expect(
          await destination.save(Uint8List.fromList([1, 2, 3])),
          saved ? AnalyticsExportResult.saved : AnalyticsExportResult.cancelled,
        );
      }
    },
  );
  test(
    'missing plugin and raw native errors become fixed recoverable outcomes',
    () async {
      final destination = NativeAnalyticsCsvDestination();
      expect(
        await destination.save(Uint8List.fromList([1])),
        AnalyticsExportResult.unavailable,
      );
      messenger.setMockMethodCallHandler(
        NativeAnalyticsCsvDestination.channel,
        (_) async {
          throw PlatformException(
            code: 'PRIVATE_PATH_SENTINEL',
            message: 'PRIVATE_BYTES_SENTINEL',
          );
        },
      );
      expect(
        await destination.save(Uint8List.fromList([1])),
        AnalyticsExportResult.unavailable,
      );
      await expectLater(destination.cancel(), completes);
    },
  );
  test('empty/oversize payloads never call native code', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(NativeAnalyticsCsvDestination.channel, (
      _,
    ) async {
      calls++;
      return true;
    });
    final destination = NativeAnalyticsCsvDestination();
    expect(
      await destination.save(Uint8List(0)),
      AnalyticsExportResult.tooLarge,
    );
    expect(
      await destination.save(Uint8List(AnalyticsCsv.maxBytes + 1)),
      AnalyticsExportResult.tooLarge,
    );
    expect(calls, 0);
  });
}
