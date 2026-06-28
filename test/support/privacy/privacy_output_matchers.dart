import 'package:flutter_test/flutter_test.dart';

class PrivacyOutputMatchers {
  const PrivacyOutputMatchers._();

  static Matcher doesNotContainAny(Iterable<String> values) {
    return _DoesNotContainAny(values);
  }

  static void expectNoLeakInString(String actual, Iterable<String> forbidden) {
    for (final value in forbidden) {
      expect(
        actual,
        isNot(contains(value)),
        reason: 'String should not contain "$value"',
      );
    }
  }

  static void expectNoLeakInMap(
    Map<String, Object?> actual,
    Iterable<String> forbidden,
  ) {
    for (final entry in actual.entries) {
      if (entry.value is String) {
        final str = entry.value as String;
        for (final value in forbidden) {
          expect(
            str,
            isNot(contains(value)),
            reason: 'Map entry "${entry.key}" should not contain "$value"',
          );
        }
      }
    }
  }
}

class _DoesNotContainAny extends Matcher {
  final Iterable<String> values;
  const _DoesNotContainAny(this.values);

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! String) return false;
    for (final value in values) {
      if (item.contains(value)) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description
        .add('a string not containing any of: ')
        .add(values.join(', '));
  }
}
