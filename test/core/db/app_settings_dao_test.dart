import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';

void main() {
  late AppDatabase db;
  late AppSettingsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AppSettingsDao(db);
  });

  tearDown(() {
    db.close();
  });

  group('AppSettingsDao', () {
    test('getSettings returns null initially', () async {
      final settings = await dao.getSettings();
      expect(settings, isNull);
    });

    test('upsertSettings saves and reloads settings', () async {
      final now = DateTime.now();
      await dao.upsertSettings(
        AppSettingsCompanion(
          id: const Value('default'),
          preferredUnits: const Value('imperial'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final settings = await dao.getSettings();
      expect(settings, isNotNull);
      expect(settings!.preferredUnits, equals('imperial'));
    });
  });
}
