import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/shared/constants/db_constants.dart';

void main() {
  group('Migration', () {
    test('onCreate seeds schema_meta and logs migration', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final metaRows = await db.select(db.schemaMeta).get();
      expect(
        metaRows.where((r) => r.key == DbConstants.driftSchemaVersionKey),
        isNotEmpty,
      );

      final logRows = await db.select(db.schemaMigrationsLog).get();
      expect(logRows, isNotEmpty);
      expect(logRows.first.fromVersion, equals(0));
      expect(logRows.first.toVersion, equals(2));

      db.close();
    });

    test('all tables are accessible after creation', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final fileRecords = await db.select(db.localFileRecords).get();
      expect(fileRecords, isEmpty);

      final logRows = await db.select(db.schemaMigrationsLog).get();
      expect(logRows, isNotEmpty);

      db.close();
    });
  });
}
