import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';

void main() {
  late AppDatabase db;
  late LocalFileRecordDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = LocalFileRecordDao(db);
  });

  tearDown(() {
    db.close();
  });

  group('LocalFileRecordDao', () {
    test('insert and retrieve by relative path', () async {
      final now = DateTime.now();
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-1'),
          localRelativePath: 'media/sessions/session-1/original.jpg',
          fileSizeBytes: 1024,
          contentHash: Value('abc123'),
          mimeType: Value('image/jpeg'),
          createdAt: now,
        ),
      );

      final record = await dao.getByRelativePath(
        'media/sessions/session-1/original.jpg',
      );
      expect(record, isNotNull);
      expect(record!.category, equals('media'));
      expect(record.ownerType, equals('session'));
      expect(record.ownerId, equals('session-1'));
      expect(record.fileSizeBytes, equals(1024));
      expect(record.contentHash, equals('abc123'));
    });

    test('insert and retrieve by owner', () async {
      final now = DateTime.now();
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-2'),
          localRelativePath: 'media/sessions/session-2/original.jpg',
          fileSizeBytes: 2048,
          createdAt: now,
        ),
      );
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-2'),
          localRelativePath: 'media/sessions/session-2/thumb.jpg',
          fileSizeBytes: 512,
          createdAt: now,
        ),
      );

      final records = await dao.getByOwner('session', ownerId: 'session-2');
      expect(records.length, equals(2));
    });

    test('getByOwner without ownerId returns all for type', () async {
      final now = DateTime.now();
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-a'),
          localRelativePath: 'a.jpg',
          fileSizeBytes: 100,
          createdAt: now,
        ),
      );
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-b'),
          localRelativePath: 'b.jpg',
          fileSizeBytes: 200,
          createdAt: now,
        ),
      );

      final records = await dao.getByOwner('session');
      expect(records.length, equals(2));
    });

    test('delete by relative path', () async {
      final now = DateTime.now();
      final path = 'media/sessions/session-3/del.jpg';
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-3'),
          localRelativePath: path,
          fileSizeBytes: 300,
          createdAt: now,
        ),
      );

      final deleted = await dao.deleteByRelativePath(path);
      expect(deleted, equals(1));

      final record = await dao.getByRelativePath(path);
      expect(record, isNull);
    });

    test('delete by owner', () async {
      final now = DateTime.now();
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('delete-me'),
          localRelativePath: 'd1.jpg',
          fileSizeBytes: 100,
          createdAt: now,
        ),
      );
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('delete-me'),
          localRelativePath: 'd2.jpg',
          fileSizeBytes: 200,
          createdAt: now,
        ),
      );

      final deleted = await dao.deleteByOwner('session', ownerId: 'delete-me');
      expect(deleted, equals(2));

      final remaining = await dao.getByOwner('session', ownerId: 'delete-me');
      expect(remaining, isEmpty);
    });

    test('markVerified sets lastVerifiedAt', () async {
      final now = DateTime.now();
      final path = 'media/sessions/session-4/verify.jpg';
      await dao.insertFileRecord(
        LocalFileRecordsCompanion.insert(
          category: 'media',
          ownerType: 'session',
          ownerId: Value('session-4'),
          localRelativePath: path,
          fileSizeBytes: 400,
          createdAt: now,
        ),
      );

      await dao.markVerified(path);
      final record = await dao.getByRelativePath(path);
      expect(record!.lastVerifiedAt, isNotNull);
    });
  });
}
