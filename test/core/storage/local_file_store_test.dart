import 'dart:io';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late LocalFileStore store;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('local_file_store_test_');
    store = LocalFileStore(basePath: tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalFileStore', () {
    test('categoryDir creates and returns directory', () async {
      final dir = await store.categoryDir(FileCategory.media);
      expect(await dir.exists(), isTrue);
      expect(dir.path, contains('media'));
    });

    test('same categoryDir returns existing directory', () async {
      final dir1 = await store.categoryDir(FileCategory.media);
      final dir2 = await store.categoryDir(FileCategory.media);
      expect(dir1.path, equals(dir2.path));
    });

    test('fileAt creates file in category dir', () async {
      final file = await store.fileAt(FileCategory.media, 'test.jpg');
      expect(await file.exists(), isFalse);
      await file.create();
      expect(await file.exists(), isTrue);
    });

    test('clearCategory deletes and recreates directory', () async {
      final dir = await store.categoryDir(FileCategory.temp);
      final file = await store.fileAt(FileCategory.temp, 'test.txt');
      await file.create();
      expect(await file.exists(), isTrue);

      await store.clearCategory(FileCategory.temp);
      expect(await dir.exists(), isTrue);
      expect(await file.exists(), isFalse);
    });

    test('deleteFile removes file if exists', () async {
      final file = await store.fileAt(FileCategory.temp, 'delete-me.txt');
      await file.create();
      expect(await file.exists(), isTrue);

      await store.deleteFile(file.path);
      expect(await file.exists(), isFalse);
    });

    test('deleteFile does not throw if file missing', () async {
      await expectLater(store.deleteFile('/nonexistent/file.txt'), completes);
    });

    test('ensureCoreDirectories creates all category dirs', () async {
      await store.ensureCoreDirectories();
      for (final cat in FileCategory.values) {
        final dir = Directory(p.join(tempDir.path, cat.path));
        expect(await dir.exists(), isTrue, reason: 'Missing: ${cat.path}');
      }
      expect(
        await Directory(
          p.join(
            tempDir.path,
            'media',
            'progress',
            'sessions',
            'bootstrap',
            'originals',
          ),
        ).exists(),
        isTrue,
      );
    });

    test('subDir creates nested subdirectory', () async {
      final dir = await store.subDir(FileCategory.media, 'sub/test');
      expect(await dir.exists(), isTrue);
      expect(dir.path, contains('sub/test'));
    });

    test('toRelativePath converts absolute to relative', () async {
      final absolute = p.join(tempDir.path, 'media', 'test.jpg');
      final relative = await store.toRelativePath(absolute);
      expect(relative, equals(p.join('media', 'test.jpg')));
    });

    test('toAbsolutePath converts relative to absolute', () async {
      final absolute = await store.toAbsolutePath('media/test.jpg');
      expect(absolute, equals(p.join(tempDir.path, 'media', 'test.jpg')));
    });

    test('nested helper directories are created', () async {
      final originals = await store.progressSessionOriginalsDir('session-1');
      final extracted = await store.importExtractedDir('draft-1');
      final exports = await store.aedifyPlanExportDir();

      expect(await originals.exists(), isTrue);
      expect(
        originals.path,
        contains(p.join('media', 'progress', 'sessions', 'session-1')),
      );
      expect(await extracted.exists(), isTrue);
      expect(
        extracted.path,
        contains(p.join('imports', 'temp', 'draft-1', 'extracted')),
      );
      expect(await exports.exists(), isTrue);
      expect(exports.path, contains(p.join('exports', 'temp', 'aedifyplan')));
    });

    test(
      'cleanupStartupTemporaryArtifacts clears temp import and export roots',
      () async {
        final importFile = File(
          p.join(
            (await store.importExtractedDir('draft-2')).path,
            'payload.txt',
          ),
        );
        await importFile.create(recursive: true);
        final exportFile = File(
          p.join((await store.aedifyPlanExportDir()).path, 'plan.aedifyplan'),
        );
        await exportFile.create(recursive: true);

        await store.cleanupStartupTemporaryArtifacts();

        expect(await importFile.exists(), isFalse);
        expect(await exportFile.exists(), isFalse);
        expect(
          await (await store.categoryDir(FileCategory.media)).exists(),
          isTrue,
        );
      },
    );

    test(
      'cleanupStartupTemporaryArtifacts does not remove durable roots',
      () async {
        final durableFile = File(
          p.join(
            (await store.progressSessionOriginalsDir('session-3')).path,
            'image.jpg',
          ),
        );
        await durableFile.create(recursive: true);

        await store.cleanupStartupTemporaryArtifacts();

        expect(await durableFile.exists(), isTrue);
      },
    );
  });
}
