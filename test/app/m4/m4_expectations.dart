import 'package:flutter_test/flutter_test.dart';

class M4Expectations {
  M4Expectations._();

  static void expectHistoryContainsSessionName(
    String name,
    List<dynamic> historyItems,
  ) {
    expect(
      historyItems.any((item) => item.name == name),
      isTrue,
      reason: 'History should contain session: $name',
    );
  }

  static void expectNoCrashFailure() {
    // The test harness itself ensures this by reaching the assertion
  }
}
