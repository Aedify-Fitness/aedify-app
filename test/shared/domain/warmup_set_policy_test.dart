import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/warmup_set_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarmupSetPolicy', () {
    late WarmupSetPolicy policy;

    setUp(() {
      policy = const WarmupSetPolicy();
    });

    test('isWarmup returns true for warmup set type', () {
      expect(policy.isWarmup(SetType.warmup), isTrue);
    });

    test('isWarmup returns false for working set type', () {
      expect(policy.isWarmup(SetType.working), isFalse);
    });

    test('isWorking returns true for working set type', () {
      expect(policy.isWorking(SetType.working), isTrue);
    });

    test('isWorking returns false for warmup set type', () {
      expect(policy.isWorking(SetType.warmup), isFalse);
    });

    test('shouldBeExcludedFromFutureAnalytics returns true for warmup', () {
      expect(
        policy.shouldBeExcludedFromFutureAnalytics(SetType.warmup),
        isTrue,
      );
    });

    test('shouldBeExcludedFromFutureAnalytics returns false for working', () {
      expect(
        policy.shouldBeExcludedFromFutureAnalytics(SetType.working),
        isFalse,
      );
    });
  });
}
