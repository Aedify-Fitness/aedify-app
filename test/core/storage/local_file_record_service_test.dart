import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/core/storage/local_file_record_service.dart';
import 'package:aedify/core/storage/local_file_store.dart';

void main() {
  late AppDatabase db;
  late LocalFileRecordDao dao;
  late LocalFileStore fileStore;
  late LocalFileRecordService service;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = LocalFileRecordDao(db);
    tempDir = Directory.systemTemp.createTempSync('file_record_service_');
    fileStore = LocalFileStore(basePath: tempDir.path);
    service = LocalFileRecordService(dao: dao, fileStore: fileStore);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalFileRecordService', () {
    test('registerManagedFile creates record and returns file', () async {
      final file = await fileStore.fileAt(
        FileCategory.media,
        'register-test.jpg',
      );
      await file.create();
      final relativePath = await fileStore.toRelativePath(file.path);
      final actualSize = await file.length();

      final record = await service.registerManagedFile(
        category: FileCategory.media,
        ownerType: 'test',
        ownerId: 'test-1',
        relativePath: relativePath,
        fileSizeBytes: actualSize,
        mimeType: 'image/jpeg',
      );

      expect(record.localRelativePath, equals(relativePath));
      expect(record.fileSizeBytes, equals(actualSize));
      expect(record.ownerType, equals('test'));
      expect(record.ownerId, equals('test-1'));
    });

    test('getByRelativePath returns null for missing', () async {
      final result = await service.getByRelativePath('nonexistent');
      expect(result, isNull);
    });

    test('deleteManagedFile removes record and file', () async {
      final file = await fileStore.fileAt(
        FileCategory.temp,
        'delete-service-test.txt',
      );
      await file.create();
      final relativePath = await fileStore.toRelativePath(file.path);

      await service.registerManagedFile(
        category: FileCategory.temp,
        ownerType: 'test',
        relativePath: relativePath,
        fileSizeBytes: 0,
      );

      expect(await service.getByRelativePath(relativePath), isNotNull);
      expect(await file.exists(), isTrue);

      await service.deleteManagedFile(relativePath);

      expect(await service.getByRelativePath(relativePath), isNull);
      expect(await file.exists(), isFalse);
    });

    test('deleteManagedFilesForOwner removes all records and files', () async {
      for (var i = 0; i < 3; i++) {
        final file = await fileStore.fileAt(
          FileCategory.temp,
          'bulk-delete-$i.txt',
        );
        await file.create();
        final path = await fileStore.toRelativePath(file.path);
        await service.registerManagedFile(
          category: FileCategory.temp,
          ownerType: 'bulk',
          ownerId: 'bulk-owner',
          relativePath: path,
          fileSizeBytes: 0,
        );
      }

      expect(
        (await service.getByOwner('bulk', ownerId: 'bulk-owner')).length,
        equals(3),
      );

      await service.deleteManagedFilesForOwner('bulk', ownerId: 'bulk-owner');

      expect(
        (await service.getByOwner('bulk', ownerId: 'bulk-owner')).length,
        equals(0),
      );
    });

    test('verifyManagedFile sets lastVerifiedAt', () async {
      final file = await fileStore.fileAt(
        FileCategory.temp,
        'verify-test.txt',
      );
      await file.create();
      final path = await fileStore.toRelativePath(file.path);
      await service.registerManagedFile(
        category: FileCategory.temp,
        ownerType: 'test',
        relativePath: path,
        fileSizeBytes: 0,
      );

      await service.verifyManagedFile(path);
      final record = await service.getByRelativePath(path);
      expect(record!.lastVerifiedAt, isNotNull);
    });
  });
}
