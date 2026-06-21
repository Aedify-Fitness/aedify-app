import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/privacy/redaction.dart';

void main() {
  group('Redaction', () {
    test('Redaction.sensitive returns placeholder for null', () {
      expect(Redaction.sensitive(null), '[REDACTED]');
    });

    test('Redaction.sensitive returns placeholder for any value', () {
      expect(Redaction.sensitive('sensitive-data'), '[REDACTED]');
    });

    test('Redaction.apiKey shows first 4 and last 4 chars', () {
      final result = Redaction.apiKey('sk-abc12345xyz');
      expect(result, 'sk-a...5xyz');
    });

    test('Redaction.apiKey returns placeholder for short key', () {
      expect(Redaction.apiKey('short'), '[REDACTED]');
    });

    test('Redaction.filePath shows last segment', () {
      final result = Redaction.filePath('/path/to/file.txt');
      expect(result, '.../file.txt');
    });

    test('Redaction.filePath returns placeholder for short path', () {
      expect(Redaction.filePath('file.txt'), '[REDACTED]');
    });

    group('valueForField', () {
      test('redacts sensitive fields', () {
        expect(
          Redaction.valueForField('api_key', 'sk-test'),
          equals('[REDACTED]'),
        );
        expect(
          Redaction.valueForField('prompt', 'my prompt'),
          equals('[REDACTED]'),
        );
        expect(
          Redaction.valueForField('file_path', '/secret/file'),
          equals('[REDACTED]'),
        );
      });

      test('passes through allowed fields', () {
        expect(
          Redaction.valueForField('app_version', '1.0.0'),
          equals('1.0.0'),
        );
        expect(Redaction.valueForField('platform', 'ios'), equals('ios'));
      });

      test('passes through unknown fields', () {
        expect(
          Redaction.valueForField('some_random_key', 'hello'),
          equals('hello'),
        );
      });

      test('returns null for null value', () {
        expect(Redaction.valueForField('api_key', null), isNull);
      });
    });

    group('metadata', () {
      test('redacts sensitive values in map', () {
        final result = Redaction.metadata({
          'api_key': 'sk-secret',
          'app_version': '1.0.0',
          'message': 'hello',
        });
        expect(result['api_key'], equals('[REDACTED]'));
        expect(result['app_version'], equals('1.0.0'));
        expect(result['message'], equals('hello'));
      });

      test('returns empty map for empty input', () {
        expect(Redaction.metadata({}), isEmpty);
      });
    });

    group('headers', () {
      test('redacts authorization header', () {
        final result = Redaction.headers({
          'Authorization': 'Bearer tokensecret123',
          'Content-Type': 'application/json',
        });
        expect(result['Authorization'], equals('[REDACTED]'));
        expect(result['Content-Type'], equals('application/json'));
      });

      test('redacts x-api-key header', () {
        final result = Redaction.headers({'X-API-Key': 'abc123'});
        expect(result['X-API-Key'], equals('[REDACTED]'));
      });

      test('redacts cookie header', () {
        final result = Redaction.headers({'Cookie': 'session=abc123'});
        expect(result['Cookie'], equals('[REDACTED]'));
      });

      test('passes through safe headers', () {
        final result = Redaction.headers({
          'Accept': 'application/json',
          'User-Agent': 'Aedify/1.0',
        });
        expect(result['Accept'], equals('application/json'));
        expect(result['User-Agent'], equals('Aedify/1.0'));
      });
    });

    group('queryParameters', () {
      test('redacts api_key parameter', () {
        final result = Redaction.queryParameters({
          'api_key': 'sk-secret',
          'page': '1',
        });
        expect(result['api_key'], equals('[REDACTED]'));
        expect(result['page'], equals('1'));
      });

      test('redacts token parameter', () {
        final result = Redaction.queryParameters({'token': 'abc123'});
        expect(result['token'], equals('[REDACTED]'));
      });

      test('passes through safe parameters', () {
        final result = Redaction.queryParameters({
          'limit': '20',
          'offset': '0',
        });
        expect(result['limit'], equals('20'));
        expect(result['offset'], equals('0'));
      });
    });
  });
}
