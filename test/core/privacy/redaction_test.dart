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
  });
}
