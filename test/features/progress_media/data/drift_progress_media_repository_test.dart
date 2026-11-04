import 'dart:io';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_storage_policy.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:aedify/shared/constants/directory_constants.dart';

void main() {
  late ProgressMediaFixture f;

  setUp(() async {
    f = ProgressMediaFixture(await Directory.systemTemp.createTemp('m6_data_'));
  });
  tearDown(() async {
    await f.db.close();
    await f.directory.delete(recursive: true);
  });

  test(
    'invalid structures, values and ownership fail before any metadata write',
    () async {
      final original = f.item(1, 101);
      final invalid = [
        f.draft(1, items: []),
        f.draft(1, items: [original, original]),
        f.draft(1, items: [f.item(2, 101)]),
        f.draft(
          1,
          items: [f.item(1, 101, relativePath: '/private/secret.jpg')],
        ),
        f.draft(1, items: [f.item(1, 101, relativePath: '../outside.jpg')]),
        f.draft(
          1,
          items: [f.item(1, 101, relativePath: r'C:\private\secret.jpg')],
        ),
        f.draft(
          1,
          items: [
            f.item(1, 101, source: ProgressMediaSource.generatedThumbnail),
          ],
        ),
        f.draft(1, items: [f.item(1, 101, parent: 102)]),
        f.draft(1, items: [f.item(1, 101, width: -1)]),
        f.draft(1, items: [f.item(1, 101, durationSeconds: 30)]),
        f.draft(
          1,
          items: [f.item(1, 101, pose: ProgressMediaPose.allSidesVideo)],
        ),
        f.draft(1, items: [f.item(1, 101, type: ProgressMediaItemType.video)]),
        f.draft(
          1,
          items: [
            original,
            f.item(
              1,
              102,
              type: ProgressMediaItemType.videoFrame,
              source: ProgressMediaSource.extractedFrame,
              parent: 101,
            ),
          ],
        ),
        f.draft(
          1,
          items: [
            original,
            f.item(
              1,
              102,
              type: ProgressMediaItemType.thumbnail,
              source: ProgressMediaSource.generatedThumbnail,
              parent: 999,
            ),
          ],
        ),
        f.draft(
          1,
          items: [
            original,
            f.item(
              1,
              102,
              type: ProgressMediaItemType.thumbnail,
              pose: ProgressMediaPose.back,
              source: ProgressMediaSource.generatedThumbnail,
              parent: 101,
            ),
          ],
        ),
        f.draft(
          1,
          items: [
            original,
            f.item(
              1,
              102,
              type: ProgressMediaItemType.thumbnail,
              source: ProgressMediaSource.generatedThumbnail,
              parent: 101,
            ),
            f.item(
              1,
              103,
              type: ProgressMediaItemType.thumbnail,
              source: ProgressMediaSource.generatedThumbnail,
              parent: 101,
            ),
          ],
        ),
        f.draft(
          1,
          items: [
            f.item(
              1,
              102,
              type: ProgressMediaItemType.thumbnail,
              source: ProgressMediaSource.generatedThumbnail,
              parent: 101,
            ),
          ],
        ),
        for (final value in [double.nan, double.infinity, -1.0, 0.0])
          f.draft(1, bodyweightKg: value),
        f.draft(
          1,
          measurements: ProgressMeasurementSnapshot(
            measuredAt: ProgressMediaFixture.now,
            waistCm: double.nan,
          ),
        ),
      ];
      for (final draft in invalid) {
        await expectLater(
          f.repository.saveSession(draft),
          throwsA(ProgressMediaFailure.invalid),
        );
      }
      expect(await f.repository.loadTimeline(), isEmpty);
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      expect(
        await f.db.select(f.db.progressMediaReminderSettings).get(),
        isEmpty,
      );
    },
  );

  test('save rejects a symlink to media outside the sandbox', () async {
    final draft = f.draft(1);
    final outside = await Directory.systemTemp.createTemp('m6_outside_');
    addTearDown(() => outside.delete(recursive: true));
    final target = File(p.join(outside.path, 'synthetic.jpg'));
    await target.writeAsBytes([1, 2, 3]);
    final link = Link(
      await f.files.toAbsolutePath(draft.items.single.relativePath),
    );
    await link.parent.create(recursive: true);
    await link.create(target.path);
    await expectLater(
      f.repository.saveSession(draft),
      throwsA(ProgressMediaFailure.unavailable),
    );
    expect(await f.repository.loadTimeline(), isEmpty);
    expect(await target.readAsBytes(), [1, 2, 3]);
  });

  test(
    'concurrent saves commit separately with exactly one baseline',
    () async {
      final a = f.draft(1);
      final b = f.draft(2);
      await f.stage(a);
      await f.stage(b);
      await Future.wait([
        f.repository.saveSession(a),
        f.repository.saveSession(b),
      ]);
      final sessions = await f.repository.loadTimeline();
      expect(sessions.length, 2);
      expect(sessions.where((session) => session.isBaseline).length, 1);
      expect((await f.db.select(f.db.localFileRecords).get()).length, 2);
    },
  );

  test(
    'thumbnail graph saves with foreign keys enabled, including child-first input',
    () async {
      await f.db.customStatement('PRAGMA foreign_keys = ON');
      await f.save(
        1,
        items: [
          f.item(
            1,
            103,
            type: ProgressMediaItemType.thumbnail,
            source: ProgressMediaSource.generatedThumbnail,
            parent: 102,
          ),
          f.item(
            1,
            102,
            type: ProgressMediaItemType.videoFrame,
            source: ProgressMediaSource.extractedFrame,
            parent: 101,
          ),
          f.item(
            1,
            101,
            type: ProgressMediaItemType.video,
            pose: ProgressMediaPose.allSidesVideo,
            durationSeconds: 30,
          ),
        ],
      );
      expect(
        await f.db.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    },
  );

  test(
    'stale or unowned thumbnail pointers never leave the repository',
    () async {
      final draft = await f.save(1);
      await f.db
          .update(f.db.progressMediaItems)
          .write(
            const ProgressMediaItemsCompanion(
              thumbnailRelativePath: Value('/private/thumbnail-sentinel.jpg'),
            ),
          );
      expect(
        (await f.repository.getSessionDetails(
          draft.id,
        ))!.items.single.thumbnailRelativePath,
        isNull,
      );
    },
  );

  test(
    'empty storage has no baseline, latest, files or eligible reminder',
    () async {
      expect(await f.repository.loadTimeline(), isEmpty);
      expect(await f.repository.getBaselineSession(), isNull);
      expect(await f.repository.getLatestSession(), isNull);
      expect(
        await f.repository.getSessionDetails(ProgressMediaFixture.id(1)),
        isNull,
      );
      final reminders = await f.repository.getReminderState();
      expect(reminders.canPrompt, isFalse);
      expect(reminders.enabled, isFalse);
      expect(reminders.nextReminderAt, isNull);
      final usage = await f.repository.getStorageUsage();
      expect(
        [usage.sessionCount, usage.fileCount, usage.totalBytes],
        [0, 0, 0],
      );
    },
  );

  test(
    'first partial photo session registers local file and baseline',
    () async {
      final draft = await f.save(1);
      final details = (await f.repository.getSessionDetails(draft.id))!;
      expect(details.session.isBaseline, isTrue);
      expect(details.session.isCompletePoseSet, isFalse);
      expect(details.session.mediaType, ProgressMediaType.photoSet);
      expect(details.items.single.file.pose, ProgressMediaPose.front);
      expect(details.items.single.isFileAvailable, isTrue);
      expect(details.session.storageSizeBytes, 4);
      final record = (await f.db.select(f.db.localFileRecords).get()).single;
      expect(record.ownerType, ProgressMediaStoragePolicy.fileOwnerType);
      expect(record.ownerId, draft.items.single.id);
      expect(record.localRelativePath, draft.items.single.relativePath);
      expect(p.isAbsolute(record.localRelativePath), isFalse);
      final reminders = await f.repository.getReminderState();
      expect(reminders.canPrompt, isTrue);
      expect(reminders.enabled, isFalse);
      expect(reminders.cadence, isNull);
      expect(reminders.nextReminderAt, isNull);
      expect(reminders.lastPromptedAt, isNull);
      expect(reminders.lastSessionAt, draft.capturedAt);
    },
  );

  test(
    'four original poses mark complete; thumbnail has one file registration',
    () async {
      final original = f.item(1, 101);
      final thumb = f.item(
        1,
        105,
        type: ProgressMediaItemType.thumbnail,
        source: ProgressMediaSource.generatedThumbnail,
        parent: 101,
      );
      final draft = await f.save(
        1,
        items: [
          thumb,
          original,
          f.item(1, 102, pose: ProgressMediaPose.back),
          f.item(1, 103, pose: ProgressMediaPose.leftSide),
          f.item(1, 104, pose: ProgressMediaPose.rightSide),
        ],
      );
      final details = (await f.repository.getSessionDetails(draft.id))!;
      expect(details.session.isCompletePoseSet, isTrue);
      expect(
        details.items
            .firstWhere((i) => i.file.id == original.id)
            .thumbnailRelativePath,
        thumb.relativePath,
      );
      expect(details.session.storageSizeBytes, 20);
      expect((await f.db.select(f.db.localFileRecords).get()).length, 5);
      final usage = await f.repository.getStorageUsage();
      expect(
        [usage.sessionCount, usage.fileCount, usage.totalBytes],
        [1, 5, 20],
      );
    },
  );

  test(
    'video and mixed sessions retain duration, source and derived file parents',
    () async {
      final video = f.item(
        1,
        101,
        type: ProgressMediaItemType.video,
        pose: ProgressMediaPose.allSidesVideo,
        source: ProgressMediaSource.gallery,
        durationSeconds: 30,
      );
      final frame = f.item(
        1,
        102,
        type: ProgressMediaItemType.videoFrame,
        pose: ProgressMediaPose.unknown,
        source: ProgressMediaSource.extractedFrame,
        parent: 101,
      );
      final thumb = f.item(
        1,
        103,
        type: ProgressMediaItemType.thumbnail,
        pose: ProgressMediaPose.allSidesVideo,
        source: ProgressMediaSource.generatedThumbnail,
        parent: 101,
      );
      await f.save(1, items: [thumb, frame, video]);
      final details = (await f.repository.getSessionDetails(
        ProgressMediaFixture.id(1),
      ))!;
      expect(details.session.mediaType, ProgressMediaType.video);
      expect(
        details.items
            .firstWhere((i) => i.file.id == video.id)
            .file
            .durationSeconds,
        30,
      );
      expect(
        details.items
            .firstWhere((i) => i.file.id == frame.id)
            .file
            .sourceMediaItemId,
        video.id,
      );
      await f.save(
        2,
        items: [
          f.item(2, 201),
          f.item(
            2,
            202,
            type: ProgressMediaItemType.video,
            pose: ProgressMediaPose.allSidesVideo,
            durationSeconds: 45,
          ),
        ],
      );
      expect(
        (await f.repository.getSessionDetails(
          ProgressMediaFixture.id(2),
        ))!.session.mediaType,
        ProgressMediaType.both,
      );
    },
  );

  test(
    'snapshot values and notes survive changes to measurement history',
    () async {
      final now = ProgressMediaFixture.now;
      await f.db
          .into(f.db.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              id: 'profile-measurement',
              measuredAt: now,
              waistCm: const Value(80),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final draft = f.draft(
        1,
        bodyweightKg: 75,
        notes: 'private-note-sentinel',
        measurements: ProgressMeasurementSnapshot(
          measuredAt: now,
          waistCm: 80,
          bodyweightKg: 75,
        ),
      );
      await f.stage(draft);
      await f.repository.saveSession(draft);
      await f.db
          .update(f.db.bodyMeasurements)
          .write(const BodyMeasurementsCompanion(waistCm: Value(90)));
      final details = (await f.repository.getSessionDetails(draft.id))!;
      expect(details.measurements!.waistCm, 80);
      expect(details.measurements!.bodyweightKg, 75);
      expect(details.session.bodyweightKg, 75);
      expect(details.session.notes, 'private-note-sentinel');
      await f.repository.updateNotes(draft.id, null);
      expect(
        (await f.repository.getSessionDetails(draft.id))!.session.notes,
        isNull,
      );
    },
  );

  test(
    'latest uses capture date, first saved remains baseline, old imports do not regress reminder state',
    () async {
      await f.save(1);
      await f.save(
        2,
        capturedAt: ProgressMediaFixture.now.subtract(const Duration(days: 30)),
      );
      expect((await f.repository.loadTimeline()).map((s) => s.id), [
        ProgressMediaFixture.id(1),
        ProgressMediaFixture.id(2),
      ]);
      expect(
        (await f.repository.getBaselineSession())!.id,
        ProgressMediaFixture.id(1),
      );
      expect(
        (await f.repository.getLatestSession())!.id,
        ProgressMediaFixture.id(1),
      );
      expect(
        (await f.repository.getReminderState()).lastSessionAt,
        ProgressMediaFixture.now,
      );
      await f.repository.setBaseline(ProgressMediaFixture.id(2));
      expect(
        (await f.repository.getBaselineSession())!.id,
        ProgressMediaFixture.id(2),
      );
      expect(
        (await f.repository.loadTimeline()).where((s) => s.isBaseline).length,
        1,
      );
    },
  );

  test(
    'same-pose pairs exclude unknown, unmatched poses, videos and thumbnails',
    () async {
      await f.save(
        1,
        items: [
          f.item(1, 101),
          f.item(1, 102, pose: ProgressMediaPose.back),
          f.item(1, 103, pose: ProgressMediaPose.unknown),
        ],
      );
      await f.save(
        2,
        items: [
          f.item(2, 201),
          f.item(2, 202, pose: ProgressMediaPose.leftSide),
          f.item(2, 203, pose: ProgressMediaPose.unknown),
        ],
      );
      final pairs = await f.repository.getComparablePosePairs(
        ProgressMediaFixture.id(1),
        ProgressMediaFixture.id(2),
      );
      expect(pairs.single.pose, ProgressMediaPose.front);
      expect(pairs.single.first.file.id, ProgressMediaFixture.id(101));
      expect(pairs.single.second.file.id, ProgressMediaFixture.id(201));
      expect(() => pairs.clear(), throwsUnsupportedError);
    },
  );

  test(
    'missing or changed file preserves metadata with recoverable availability',
    () async {
      final draft = await f.save(1);
      final file = File(
        await f.files.toAbsolutePath(draft.items.single.relativePath),
      );
      await file.writeAsBytes([1]);
      expect(
        (await f.repository.getSessionDetails(
          draft.id,
        ))!.items.single.isFileAvailable,
        isFalse,
      );
      await file.delete();
      final details = (await f.repository.getSessionDetails(draft.id))!;
      expect(details.items.single.isFileAvailable, isFalse);
      expect(details.session.isBaseline, isTrue);
      expect((await f.repository.getStorageUsage()).totalBytes, 4);
    },
  );

  test(
    'missing staging file does not create any metadata or reminder eligibility',
    () async {
      await expectLater(
        f.repository.saveSession(f.draft(1)),
        throwsA(ProgressMediaFailure.missing),
      );
      expect(await f.repository.loadTimeline(), isEmpty);
      expect(
        await f.db.select(f.db.progressMeasurementSnapshots).get(),
        isEmpty,
      );
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      expect((await f.repository.getReminderState()).canPrompt, isFalse);
    },
  );

  test('empty files fail without metadata writes', () async {
    final draft = f.draft(1);
    await f.stage(draft, size: 0);
    await expectLater(
      f.repository.saveSession(draft),
      throwsA(ProgressMediaFailure.invalid),
    );
    expect(await f.repository.loadTimeline(), isEmpty);
  });

  test(
    'duplicate session is a conflict and cannot overwrite files or notes',
    () async {
      final draft = await f.save(1);
      await expectLater(
        f.repository.saveSession(draft),
        throwsA(ProgressMediaFailure.conflict),
      );
      expect((await f.repository.loadTimeline()).length, 1);
      expect((await f.db.select(f.db.localFileRecords).get()).length, 1);
    },
  );

  test('registered path from another owner fails closed', () async {
    final draft = f.draft(1);
    await f.stage(draft);
    await f.db
        .into(f.db.localFileRecords)
        .insert(
          LocalFileRecordsCompanion.insert(
            category: 'media',
            ownerType: 'another-owner',
            localRelativePath: draft.items.single.relativePath,
            fileSizeBytes: 4,
            createdAt: ProgressMediaFixture.now,
          ),
        );
    await expectLater(
      f.repository.saveSession(draft),
      throwsA(ProgressMediaFailure.conflict),
    );
    expect(await f.repository.loadTimeline(), isEmpty);
  });

  test(
    'late SQL failure rolls back sessions, snapshots, files and reminder state; staged files remain for retry',
    () async {
      final draft = f.draft(
        1,
        measurements: ProgressMeasurementSnapshot(
          measuredAt: ProgressMediaFixture.now,
          waistCm: 80,
        ),
      );
      await f.stage(draft);
      await f.db.customStatement(
        "CREATE TRIGGER fail_reminder BEFORE INSERT ON progress_media_reminder_settings BEGIN SELECT RAISE(ABORT, 'private-sql-sentinel'); END",
      );
      await expectLater(
        f.repository.saveSession(draft),
        throwsA(ProgressMediaFailure.unavailable),
      );
      expect(await f.repository.loadTimeline(), isEmpty);
      expect(await f.db.select(f.db.progressMediaItems).get(), isEmpty);
      expect(
        await f.db.select(f.db.progressMeasurementSnapshots).get(),
        isEmpty,
      );
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      expect((await f.repository.getReminderState()).canPrompt, isFalse);
      expect(
        await File(
          await f.files.toAbsolutePath(draft.items.single.relativePath),
        ).exists(),
        isTrue,
      );
      await f.db.customStatement('DROP TRIGGER fail_reminder');
      await f.repository.saveSession(draft);
      expect((await f.repository.getBaselineSession())!.id, draft.id);
    },
  );

  test('failed baseline switch restores previous baseline', () async {
    await f.save(1);
    await f.save(2);
    await f.db.customStatement(
      "CREATE TRIGGER fail_baseline BEFORE UPDATE ON progress_media_sessions WHEN NEW.id = '${ProgressMediaFixture.id(2)}' BEGIN SELECT RAISE(ABORT, 'private-baseline-sentinel'); END",
    );
    await expectLater(
      f.repository.setBaseline(ProgressMediaFixture.id(2)),
      throwsA(ProgressMediaFailure.unavailable),
    );
    expect(
      (await f.repository.getBaselineSession())!.id,
      ProgressMediaFixture.id(1),
    );
  });

  test(
    'database enforces one active baseline even for writes outside the repository',
    () async {
      await f.save(1);
      await f.save(2);
      await expectLater(
        (f.db.update(
          f.db.progressMediaSessions,
        )..where((s) => s.id.equals(ProgressMediaFixture.id(2)))).write(
          const ProgressMediaSessionsCompanion(isBaseline: Value(true)),
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        (await f.repository.loadTimeline()).where((s) => s.isBaseline).length,
        1,
      );
    },
  );

  test(
    'deleted sessions/items are excluded from reads, comparison and usage',
    () async {
      final a = await f.save(1);
      final b = await f.save(2);
      await (f.db.update(
        f.db.progressMediaItems,
      )..where((i) => i.id.equals(b.items.single.id))).write(
        ProgressMediaItemsCompanion(deletedAt: Value(ProgressMediaFixture.now)),
      );
      expect((await f.repository.getSessionDetails(b.id))!.items, isEmpty);
      expect(await f.repository.getComparablePosePairs(a.id, b.id), isEmpty);
      await (f.db.update(
        f.db.progressMediaSessions,
      )..where((s) => s.id.equals(a.id))).write(
        ProgressMediaSessionsCompanion(
          deletedAt: Value(ProgressMediaFixture.now),
        ),
      );
      expect(await f.repository.getSessionDetails(a.id), isNull);
      expect(await f.repository.getBaselineSession(), isNull);
      expect((await f.repository.loadTimeline()).length, 1);
      expect((await f.repository.getStorageUsage()).totalBytes, 0);
    },
  );

  test(
    'missing session mutations and comparisons return safe failure',
    () async {
      final id = ProgressMediaFixture.id(1);
      await expectLater(
        f.repository.setBaseline(id),
        throwsA(ProgressMediaFailure.missing),
      );
      await expectLater(
        f.repository.updateNotes(id, 'private'),
        throwsA(ProgressMediaFailure.missing),
      );
      await expectLater(
        f.repository.getComparablePosePairs(id, id),
        throwsA(ProgressMediaFailure.missing),
      );
    },
  );

  test('filesystem failures expose no raw paths or messages', () async {
    final repository = DriftProgressMediaRepository(
      database: f.db,
      fileStore: _FailingFiles(),
    );
    final draft = f.draft(1);
    await expectLater(
      repository.saveSession(draft),
      throwsA(ProgressMediaFailure.unavailable),
    );
    expect(
      ProgressMediaFailure.unavailable.toString(),
      isNot(contains('private')),
    );
    expect(
      ProgressMediaFailure.unavailable.message,
      isNot(contains('private')),
    );
    expect(await f.repository.loadTimeline(), isEmpty);
  });

  test('timeline stream emits committed saves and note changes', () async {
    final events = <List<ProgressMediaSession>>[];
    final subscription = f.repository.watchTimeline().listen(events.add);
    addTearDown(subscription.cancel);
    await _AsyncChecks.waitUntil(() => events.isNotEmpty);
    expect(events.last, isEmpty);
    await f.save(1);
    await _AsyncChecks.waitUntil(() => events.last.isNotEmpty);
    await f.repository.updateNotes(ProgressMediaFixture.id(1), 'changed');
    await _AsyncChecks.waitUntil(() => events.last.single.notes == 'changed');
    expect(events.last.single.isBaseline, isTrue);
  });

  test('timeline stream maps SQL failures to safe errors', () async {
    await f.db.readiness();
    await f.db.customStatement('DROP TABLE progress_media_sessions');
    await expectLater(
      f.repository.watchTimeline(),
      emitsError(ProgressMediaFailure.unavailable),
    );
  });

  test(
    'file-backed reopen preserves notes, snapshot, baseline and file registrations',
    () async {
      final databaseFile = File(p.join(f.directory.path, 'reopen.sqlite'));
      await f.db.close();
      var db = AppDatabase(NativeDatabase(databaseFile));
      f = ProgressMediaFixture(f.directory, database: db);
      final draft = f.draft(
        1,
        notes: 'local-note',
        measurements: ProgressMeasurementSnapshot(
          measuredAt: ProgressMediaFixture.now,
          hipsCm: 95,
        ),
      );
      await f.stage(draft);
      await f.repository.saveSession(draft);
      await db.close();
      db = AppDatabase(NativeDatabase(databaseFile));
      f = ProgressMediaFixture(f.directory, database: db);
      final details = (await f.repository.getSessionDetails(draft.id))!;
      expect(details.session.isBaseline, isTrue);
      expect(details.session.notes, 'local-note');
      expect(details.measurements!.hipsCm, 95);
      expect(details.items.single.isFileAvailable, isTrue);
      expect(
        (await db.select(db.localFileRecords).get()).single.ownerId,
        draft.items.single.id,
      );
      expect((await f.repository.getReminderState()).canPrompt, isTrue);
      expect((await db.select(db.schemaMigrationsLog).get()).length, 1);
    },
  );
}

class _FailingFiles extends LocalFileStore {
  @override
  Future<FileStat?> statManagedFile(String relativePath) async =>
      throw const FileSystemException(
        'private-note-sentinel',
        '/private/media-sentinel',
      );
}

abstract final class _AsyncChecks {
  static Future<void> waitUntil(bool Function() condition) async {
    for (var i = 0; i < 100; i++) {
      if (condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Expected committed local stream state');
  }
}

class ProgressMediaFixture {
  ProgressMediaFixture(this.directory, {AppDatabase? database})
    : db = database ?? AppDatabase(NativeDatabase.memory()),
      files = LocalFileStore(basePath: directory.path);

  final Directory directory;
  final AppDatabase db;
  final LocalFileStore files;
  static final now = DateTime.utc(2026, 11, 4, 12);

  DriftProgressMediaRepository get repository => DriftProgressMediaRepository(
    database: db,
    fileStore: files,
    now: () => now,
  );

  static String id(int number) =>
      '00000000-0000-4000-8000-${number.toString().padLeft(12, '0')}';

  ProgressMediaFileDraft item(
    int session,
    int number, {
    ProgressMediaItemType type = ProgressMediaItemType.photo,
    ProgressMediaPose pose = ProgressMediaPose.front,
    ProgressMediaSource source = ProgressMediaSource.camera,
    int? parent,
    String? relativePath,
    int? durationSeconds,
    int? width,
  }) => ProgressMediaFileDraft(
    id: id(number),
    type: type,
    pose: pose,
    source: source,
    sourceMediaItemId: parent == null ? null : id(parent),
    durationSeconds: durationSeconds,
    width: width,
    relativePath:
        relativePath ??
        p.posix.join(
          DirectoryConstants.media,
          DirectoryConstants.progress,
          DirectoryConstants.sessions,
          id(session),
          switch (type) {
            ProgressMediaItemType.photo ||
            ProgressMediaItemType.video => DirectoryConstants.originals,
            ProgressMediaItemType.thumbnail => DirectoryConstants.thumbnails,
            ProgressMediaItemType.videoFrame => DirectoryConstants.frames,
          },
          '${id(number)}${type == ProgressMediaItemType.video ? '.mp4' : '.jpg'}',
        ),
  );

  ProgressMediaSessionDraft draft(
    int session, {
    List<ProgressMediaFileDraft>? items,
    DateTime? capturedAt,
    double? bodyweightKg,
    ProgressMeasurementSnapshot? measurements,
    String? notes,
  }) => ProgressMediaSessionDraft(
    id: id(session),
    capturedAt: capturedAt ?? now,
    items: items ?? [item(session, session + 100)],
    bodyweightKg: bodyweightKg,
    measurements: measurements,
    notes: notes,
  );

  Future<void> stage(ProgressMediaSessionDraft draft, {int size = 4}) async {
    for (final item in draft.items) {
      final file = File(await files.toAbsolutePath(item.relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(List.filled(size, 1));
    }
  }

  Future<ProgressMediaSessionDraft> save(
    int session, {
    List<ProgressMediaFileDraft>? items,
    DateTime? capturedAt,
  }) async {
    final value = draft(session, items: items, capturedAt: capturedAt);
    await stage(value);
    await repository.saveSession(value);
    return value;
  }
}
