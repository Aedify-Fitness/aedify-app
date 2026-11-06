import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/bootstrap/progress_cleanup_job.dart';
import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_deletion_service.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/domain/progress_deletion.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _DeletionFixture f;
  setUp(() async {
    f = await _DeletionFixture.create();
  });
  tearDown(() => f.dispose());
  test(
    'delete a video cascades through frames and thumbnails, preserving photos and other sessions',
    () async {
      final a = await f.save(mixed: true);
      final b = await f.save();
      final before = (await f.repository.getSessionDetails(a))!;
      final video = before.items.firstWhere(
        (i) => i.file.type == ProgressMediaItemType.video,
      );
      final status = await f.deletion.deleteItem(a, video.file.id);
      expect(status.pending, isFalse);
      expect(status.sessionCount, 2);
      final remaining = (await f.repository.getSessionDetails(a))!;
      expect(remaining.session.mediaType, ProgressMediaType.photoSet);
      expect(
        remaining.items.map((i) => i.file.type),
        unorderedEquals([
          ProgressMediaItemType.photo,
          ProgressMediaItemType.thumbnail,
        ]),
      );
      expect((await f.repository.getSessionDetails(b))!.items, hasLength(2));
      for (final i in before.items.where(
        (i) => !remaining.items.any((r) => r.file.id == i.file.id),
      )) {
        expect(await f.files.statManagedFile(i.file.relativePath), isNull);
      }
      expect(await f.db.select(f.db.localFileRecords).get(), hasLength(4));
    },
  );
  test(
    'removing a pose updates completeness and storage totals without losing notes/snapshot',
    () async {
      final id = await f.save(complete: true);
      final before = (await f.repository.getSessionDetails(id))!;
      expect(before.session.isCompletePoseSet, isTrue);
      final front = before.items.firstWhere(
        (i) =>
            i.file.type == ProgressMediaItemType.photo &&
            i.file.pose == ProgressMediaPose.front,
      );
      await f.deletion.deleteItem(id, front.file.id);
      final after = (await f.repository.getSessionDetails(id))!;
      expect(after.session.isCompletePoseSet, isFalse);
      expect(after.items, hasLength(6));
      expect(after.session.notes, 'private-deletion-note-sentinel');
      expect(after.measurements?.waistCm, 80);
      expect(
        after.session.storageSizeBytes,
        after.items.fold<int>(0, (sum, i) => sum + i.fileSizeBytes),
      );
    },
  );
  test(
    'last original removes session, private metadata, snapshot, registrations and reminder state',
    () async {
      final id = await f.save();
      await ProgressReminderRepository(
        f.db,
      ).choose(ProgressReminderCadence.monthly, f.clock);
      final original = (await f.repository.getSessionDetails(
        id,
      ))!.items.firstWhere((i) => i.file.type.isOriginal);
      final stage = p.posix.join(
        'temp',
        'progress_photo_drafts',
        id,
        '${const Uuid().v4()}.jpg',
      );
      await f.files.writeManagedBytes(stage, Uint8List.fromList([5, 6]));
      final result = await f.deletion.deleteItem(id, original.file.id);
      expect(result.pending, isFalse);
      expect(result.sessionCount, 0);
      expect(await f.repository.getSessionDetails(id), isNull);
      expect(await f.db.select(f.db.progressMediaSessions).get(), isEmpty);
      expect(
        await f.db.select(f.db.progressMeasurementSnapshots).get(),
        isEmpty,
      );
      expect(
        await f.db.select(f.db.progressMediaReminderSettings).get(),
        isEmpty,
      );
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      expect(await f.files.statManagedFile(stage), isNull);
      await f.deletion.deleteItem(id, original.file.id);
      await f.deletion.deleteSession(id);
      await f.deletion.deleteAll();
      expect((await f.deletion.recover()).pending, isFalse);
    },
  );
  test(
    'baseline fallback and latest-date reminder reset are committed together',
    () async {
      final first = await f.save(capturedAt: DateTime.utc(2026, 10, 1, 12));
      final middle = await f.save(capturedAt: DateTime.utc(2026, 10, 15, 12));
      final latest = await f.save(capturedAt: DateTime.utc(2026, 11, 1, 12));
      await ProgressReminderRepository(
        f.db,
      ).choose(ProgressReminderCadence.monthly, f.clock);
      await f.deletion.deleteSession(first);
      expect((await f.repository.getBaselineSession())!.id, middle);
      await f.deletion.deleteSession(latest);
      final reminder = (await ProgressReminderRepository(f.db).load()).reminder;
      expect(reminder.lastSessionAt, DateTime.utc(2026, 10, 15, 12));
      expect(reminder.nextReminderAt, DateTime.utc(2026, 11, 15, 12));
      expect((await f.repository.getLatestSession())!.id, middle);
    },
  );
  test(
    'metadata transaction failure deletes no file and changes no derived state',
    () async {
      final id = await f.save(mixed: true);
      final before = await f.repository.getSessionDetails(id);
      await f.db.customStatement(
        "CREATE TRIGGER reject_delete BEFORE UPDATE OF deleted_at ON progress_media_sessions BEGIN SELECT RAISE(ABORT, 'private-deletion-sql-sentinel'); END",
      );
      await expectLater(
        f.deletion.deleteSession(id),
        throwsA(ProgressDeletionFailure.unavailable),
      );
      expect(
        (await f.repository.getSessionDetails(id))!.items,
        hasLength(before!.items.length),
      );
      expect(f.files.deleted, isEmpty);
      expect(
        (await f.db.select(f.db.progressMeasurementSnapshots).get()),
        hasLength(1),
      );
      await f.db.customStatement('DROP TRIGGER reject_delete');
      expect((await f.deletion.deleteSession(id)).pending, isFalse);
    },
  );
  test(
    'file failure hides data immediately and survives close/reopen for retry',
    () async {
      final id = await f.save();
      final details = (await f.repository.getSessionDetails(id))!;
      f.files.failPaths.addAll(details.items.map((i) => i.file.relativePath));
      final result = await f.deletion.deleteSession(id);
      expect(result.pending, isTrue);
      expect(result.pendingFiles, 2);
      expect(result.pendingBytes, 8);
      expect(await f.repository.loadTimeline(), isEmpty);
      final tombstone =
          (await f.db.select(f.db.progressMediaSessions).get()).single;
      expect(tombstone.notes, isNull);
      expect(tombstone.bodyweightKg, isNull);
      expect(tombstone.bodyMeasurementSnapshotId, isNull);
      await f.reopen();
      f.files.failPaths.clear();
      expect((await f.deletion.recover()).pending, isFalse);
      expect(await f.db.select(f.db.progressMediaItems).get(), isEmpty);
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
    },
  );
  test(
    'DB purge failure after unlink is recoverable with already-missing files',
    () async {
      final id = await f.save();
      await f.db.customStatement(
        "CREATE TRIGGER reject_purge BEFORE DELETE ON progress_media_items BEGIN SELECT RAISE(ABORT, 'private-purge-sentinel'); END",
      );
      expect((await f.deletion.deleteSession(id)).pending, isTrue);
      expect(f.files.deleted, isNotEmpty);
      await f.db.customStatement('DROP TRIGGER reject_purge');
      expect((await f.deletion.recover()).pending, isFalse);
      expect(await f.db.select(f.db.progressMediaItems).get(), isEmpty);
    },
  );
  test(
    'missing original/thumbnail files still purge all metadata idempotently',
    () async {
      final id = await f.save();
      for (final item in (await f.repository.getSessionDetails(id))!.items) {
        await f.files.deleteManagedRelativeFile(item.file.relativePath);
      }
      expect((await f.deletion.deleteSession(id)).pending, isFalse);
      expect((await f.deletion.recover()).pending, isFalse);
    },
  );
  test(
    'unsafe path, cross-owner registration and derived-item delete fail closed',
    () async {
      final id = await f.save();
      final before = (await f.repository.getSessionDetails(id))!;
      final thumb = before.items.firstWhere(
        (i) => i.file.type == ProgressMediaItemType.thumbnail,
      );
      await expectLater(
        f.deletion.deleteItem(id, thumb.file.id),
        throwsA(ProgressDeletionFailure.unavailable),
      );
      await f.db.customStatement(
        "UPDATE local_file_records SET owner_type = 'unrelated-feature'",
      );
      await expectLater(
        f.deletion.deleteSession(id),
        throwsA(ProgressDeletionFailure.unavailable),
      );
      expect(f.files.deleted, isEmpty);
      await f.db.customStatement(
        "UPDATE local_file_records SET owner_type = 'progress_media_item'",
      );
      await f.db.customStatement(
        "UPDATE progress_media_items SET local_relative_path = '../private-escape-sentinel' WHERE id = ?",
        [thumb.file.id],
      );
      await expectLater(
        f.deletion.deleteSession(id),
        throwsA(ProgressDeletionFailure.unavailable),
      );
      expect(f.files.deleted, isEmpty);
    },
  );
  test(
    'symlinks cannot unlink outside sandbox; cleanup remains pending until repaired',
    () async {
      final id = await f.save();
      final original = (await f.repository.getSessionDetails(
        id,
      ))!.items.firstWhere((i) => i.file.type.isOriginal);
      final path = await f.files.toAbsolutePath(original.file.relativePath);
      await File(path).delete();
      final outside = File(p.join(f.root.path, 'outside-sentinel.jpg'));
      await outside.writeAsBytes([4, 5, 6]);
      await Link(path).create(outside.path);
      expect((await f.deletion.deleteSession(id)).pending, isTrue);
      expect(await outside.readAsBytes(), [4, 5, 6]);
      await Link(path).delete();
      expect((await f.deletion.recover()).pending, isFalse);
      expect(await outside.readAsBytes(), [4, 5, 6]);
    },
  );
  test(
    'only aged unregistered owned artifacts are swept; fresh/active/foreign files survive',
    () async {
      final saved = await f.save();
      final orphanId = const Uuid().v4();
      final activeId = const Uuid().v4();
      f.active.add(activeId);
      final stale = p.posix.join(
        'media',
        'progress',
        'sessions',
        orphanId,
        'originals',
        '${const Uuid().v4()}.jpg',
      );
      final fresh = p.posix.join(
        'media',
        'progress',
        'sessions',
        orphanId,
        'originals',
        '${const Uuid().v4()}.jpg',
      );
      final active = p.posix.join(
        'temp',
        'progress_photo_drafts',
        activeId,
        '${const Uuid().v4()}.jpg',
      );
      final temp = p.posix.join(
        'temp',
        'progress_photo_drafts',
        orphanId,
        '${const Uuid().v4()}.png',
      );
      final partial = p.posix.join(
        'media',
        'progress',
        'sessions',
        orphanId,
        'originals',
        '${const Uuid().v4()}.jpg.${const Uuid().v4()}.partial',
      );
      const foreign = 'media/unrelated/private-other-feature.jpg';
      final unknown = p.posix.join(
        'media',
        'progress',
        'sessions',
        orphanId,
        'originals',
        'unknown-sentinel.jpg',
      );
      for (final file in [
        stale,
        fresh,
        active,
        temp,
        foreign,
        unknown,
        partial,
      ]) {
        await f.files.writeManagedBytes(file, Uint8List.fromList([7, 8, 9]));
      }
      for (final file in [stale, active, temp, foreign, unknown, partial]) {
        await File(
          await f.files.toAbsolutePath(file),
        ).setLastModified(f.clock.subtract(const Duration(days: 2)));
      }
      expect((await f.deletion.recover()).pending, isFalse);
      for (final file in [stale, temp, partial]) {
        expect(await f.files.statManagedFile(file), isNull);
      }
      for (final file in [fresh, active, foreign, unknown]) {
        expect(await f.files.statManagedFile(file), isNotNull);
      }
      expect(await f.repository.getSessionDetails(saved), isNotNull);
    },
  );
  test(
    'private notes, paths, bytes and failure payloads never enter the logger sink',
    () async {
      final id = await f.save();
      f.files.failPaths.addAll(
        (await f.repository.getSessionDetails(
          id,
        ))!.items.map((i) => i.file.relativePath),
      );
      expect((await f.deletion.deleteSession(id)).pending, isTrue);
      final output = f.logs.join(' ');
      for (final sentinel in [
        'private-deletion-note-sentinel',
        'private-delete-failure-sentinel',
        id,
        'originals',
        'thumbnails',
        '80',
      ]) {
        expect(output, isNot(contains(sentinel)));
      }
    },
  );
  test(
    'startup job waits for readiness and recovers persisted tombstones without a media screen',
    () async {
      final id = await f.save();
      f.files.failPaths.addAll(
        (await f.repository.getSessionDetails(
          id,
        ))!.items.map((i) => i.file.relativePath),
      );
      expect((await f.deletion.deleteSession(id)).pending, isTrue);
      f.files.failPaths.clear();
      final container = ProviderContainer(
        overrides: [
          AppBootstrap.controllerProvider.overrideWith(_CleanupBootstrap.new),
          ProgressDeletionProviders.serviceProvider.overrideWithValue(
            f.deletion,
          ),
        ],
      );
      final sub = container.listen(ProgressCleanupJob.provider, (_, _) {});
      expect(await f.db.select(f.db.progressMediaItems).get(), hasLength(2));
      (container.read(AppBootstrap.controllerProvider.notifier)
              as _CleanupBootstrap)
          .ready();
      for (var i = 0; i < 100; i++) {
        if ((await f.db.select(f.db.progressMediaItems).get()).isEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(await f.db.select(f.db.progressMediaItems).get(), isEmpty);
      sub.close();
      container.dispose();
    },
  );
}

class _DeletionFiles extends LocalFileStore {
  _DeletionFiles(String base, List<String> logs)
    : super(
        basePath: base,
        logger: AppLogger(
          sink: (message, {required name, required level, error, stackTrace}) {
            logs.add('$message $error $stackTrace');
          },
        ),
      );
  final failPaths = <String>{};
  final deleted = <String>[];
  @override
  Future<void> deleteManagedRelativeFile(String path) async {
    if (failPaths.contains(path)) {
      throw FileSystemException('private-delete-failure-sentinel', path);
    }
    await super.deleteManagedRelativeFile(path);
    deleted.add(path);
  }
}

class _DeletionFixture {
  _DeletionFixture(this.root, this.dbFile)
    : db = AppDatabase(NativeDatabase(dbFile)) {
    files = _DeletionFiles(p.join(root.path, 'sandbox'), logs);
  }
  final Directory root;
  final File dbFile;
  AppDatabase db;
  final logs = <String>[];
  late final _DeletionFiles files;
  final active = <String>{};
  final clock = DateTime.now().toUtc();
  static Future<_DeletionFixture> create() async {
    final root = await Directory.systemTemp.createTemp('m6_delete_');
    return _DeletionFixture(root, File(p.join(root.path, 'fixture.sqlite')));
  }

  DriftProgressMediaRepository get repository => DriftProgressMediaRepository(
    database: db,
    fileStore: files,
    now: () => DateTime.utc(2026, 11, 5, 12),
  );
  ProgressMediaDeletionService get deletion => ProgressMediaDeletionService(
    database: db,
    files: files,
    now: () => DateTime.utc(2026, 11, 5, 12).isBefore(clock)
        ? clock
        : DateTime.utc(2026, 11, 5, 12),
    activeDrafts: () => active,
  );
  Future<String> save({
    bool mixed = false,
    bool complete = false,
    DateTime? capturedAt,
  }) async {
    final id = const Uuid().v4();
    final items = <ProgressMediaFileDraft>[];
    void add(
      ProgressMediaItemType type,
      ProgressMediaPose pose, {
      String? parent,
    }) {
      final item = const Uuid().v4();
      items.add(
        ProgressMediaFileDraft(
          id: item,
          type: type,
          pose: pose,
          source: type.isOriginal
              ? ProgressMediaSource.gallery
              : type == ProgressMediaItemType.videoFrame
              ? ProgressMediaSource.extractedFrame
              : ProgressMediaSource.generatedThumbnail,
          sourceMediaItemId: parent,
          durationSeconds: type == ProgressMediaItemType.video ? 2 : null,
          relativePath: p.posix.join(
            'media',
            'progress',
            'sessions',
            id,
            type.isOriginal
                ? 'originals'
                : type == ProgressMediaItemType.thumbnail
                ? 'thumbnails'
                : 'frames',
            '$item${type == ProgressMediaItemType.video ? '.mp4' : '.jpg'}',
          ),
        ),
      );
    }

    for (final pose
        in complete
            ? [
                ProgressMediaPose.front,
                ProgressMediaPose.back,
                ProgressMediaPose.leftSide,
                ProgressMediaPose.rightSide,
              ]
            : [ProgressMediaPose.front]) {
      add(ProgressMediaItemType.photo, pose);
      final parent = items.last.id;
      add(ProgressMediaItemType.thumbnail, pose, parent: parent);
    }
    if (mixed) {
      add(ProgressMediaItemType.video, ProgressMediaPose.allSidesVideo);
      final video = items.last.id;
      add(
        ProgressMediaItemType.thumbnail,
        ProgressMediaPose.allSidesVideo,
        parent: video,
      );
      add(
        ProgressMediaItemType.videoFrame,
        ProgressMediaPose.front,
        parent: video,
      );
      final frame = items.last.id;
      add(
        ProgressMediaItemType.thumbnail,
        ProgressMediaPose.front,
        parent: frame,
      );
    }
    for (final item in items) {
      await files.writeManagedBytes(
        item.relativePath,
        Uint8List.fromList([1, 2, 3, 4]),
      );
    }
    await repository.saveSession(
      ProgressMediaSessionDraft(
        id: id,
        capturedAt: capturedAt ?? DateTime.utc(2026, 11, 1, 12),
        notes: 'private-deletion-note-sentinel',
        bodyweightKg: 80,
        measurements: ProgressMeasurementSnapshot(
          measuredAt: DateTime.utc(2026, 11, 1),
          waistCm: 80,
        ),
        items: items,
      ),
    );
    return id;
  }

  Future<void> reopen() async {
    await db.close();
    db = AppDatabase(NativeDatabase(dbFile));
  }

  Future<void> dispose() async {
    await db.close();
    await root.delete(recursive: true);
  }
}

class _CleanupBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.initializing();
  void ready() => state = const BootstrapState.success();
}
