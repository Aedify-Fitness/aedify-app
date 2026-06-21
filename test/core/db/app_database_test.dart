import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';

void main() {
  group('AppDatabase', () {
    test('schema version is 1', () {
      final db = AppDatabase();
      expect(db.schemaVersion, equals(1));
      db.close();
    });
  });
}
