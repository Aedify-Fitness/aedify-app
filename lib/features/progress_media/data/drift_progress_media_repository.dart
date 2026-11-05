import 'dart:async';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/core/storage/local_file_record_service.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_storage_policy.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:drift/drift.dart';

/// Atomic local metadata writes over the M1 database and managed-file wrappers.
class DriftProgressMediaRepository implements ProgressMediaRepository {
  DriftProgressMediaRepository({
    required AppDatabase database,
    required LocalFileStore fileStore,
    DateTime Function()? now,
  }) : _db = database,
       _files = fileStore,
       _records = LocalFileRecordService(
         dao: LocalFileRecordDao(database),
         fileStore: fileStore,
       ),
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final LocalFileStore _files;
  final LocalFileRecordService _records;
  final DateTime Function() _now;

  @override
  Future<void> saveSession(ProgressMediaSessionDraft draft) => _safe(() async {
    ProgressMediaStoragePolicy.validate(draft);
    await _db.transaction(() async {
      if (await (_db.select(
            _db.progressMediaSessions,
          )..where((row) => row.id.equals(draft.id))).getSingleOrNull() !=
          null) {
        throw ProgressMediaFailure.conflict;
      }
      final sizes = <String, int>{};
      for (final item in draft.items) {
        final existing =
            await (_db.select(_db.progressMediaItems)..where(
                  (row) =>
                      row.id.equals(item.id) |
                      row.localRelativePath.equals(item.relativePath),
                ))
                .get();
        if (existing.isNotEmpty ||
            await _records.getByRelativePath(item.relativePath) != null) {
          throw ProgressMediaFailure.conflict;
        }
        final stat = await _files.statManagedFile(item.relativePath);
        if (stat == null) throw ProgressMediaFailure.missing;
        if (stat.size <= 0) throw ProgressMediaFailure.invalid;
        sizes[item.id] = stat.size;
      }
      final now = _now();
      final reminders = await _reminderRow();
      final isFirst = (await (_timelineQuery()..limit(1)).get()).isEmpty;
      final hasPhoto = draft.items.any(
        (item) => item.type == ProgressMediaItemType.photo,
      );
      final hasVideo = draft.items.any(
        (item) => item.type == ProgressMediaItemType.video,
      );
      final poses = draft.items
          .where((item) => item.type == ProgressMediaItemType.photo)
          .map((item) => item.pose)
          .toSet();
      final measurements = draft.measurements;
      if (measurements != null) {
        await _db
            .into(_db.progressMeasurementSnapshots)
            .insert(
              ProgressMeasurementSnapshotsCompanion.insert(
                id: draft.id,
                measuredAt: measurements.measuredAt,
                bodyweightKg: Value(measurements.bodyweightKg),
                waistCm: Value(measurements.waistCm),
                chestCm: Value(measurements.chestCm),
                hipsCm: Value(measurements.hipsCm),
                leftArmCm: Value(measurements.leftArmCm),
                rightArmCm: Value(measurements.rightArmCm),
                leftThighCm: Value(measurements.leftThighCm),
                rightThighCm: Value(measurements.rightThighCm),
              ),
            );
      }
      await _db
          .into(_db.progressMediaSessions)
          .insert(
            ProgressMediaSessionsCompanion.insert(
              id: draft.id,
              capturedAt: draft.capturedAt,
              mediaType:
                  (hasPhoto && hasVideo
                          ? ProgressMediaType.both
                          : hasPhoto
                          ? ProgressMediaType.photoSet
                          : ProgressMediaType.video)
                      .dbValue,
              isBaseline: Value(isFirst),
              isCompletePoseSet: Value(
                ProgressMediaStoragePolicy.photoPoses.every(poses.contains),
              ),
              bodyweightKg: Value(draft.bodyweightKg),
              bodyMeasurementSnapshotId: Value(
                measurements == null ? null : draft.id,
              ),
              notes: Value(draft.notes),
              reminderCadenceAtCapture: Value(
                reminders?.cadence ??
                    (reminders == null
                        ? null
                        : ProgressReminderCadence.off.dbValue),
              ),
              storageSizeBytes: sizes.values.fold(
                0,
                (total, size) => total + size,
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );
      // Insert parents before children, even when the caller supplies any order.
      final ordered = [...draft.items]
        ..sort((a, b) => _fileOrder(a.type).compareTo(_fileOrder(b.type)));
      for (final item in ordered) {
        final thumbnails = draft.items.where(
          (candidate) =>
              candidate.type == ProgressMediaItemType.thumbnail &&
              candidate.sourceMediaItemId == item.id,
        );
        await _db
            .into(_db.progressMediaItems)
            .insert(
              ProgressMediaItemsCompanion.insert(
                id: item.id,
                sessionId: draft.id,
                type: item.type.dbValue,
                pose: item.pose.dbValue,
                source: item.source.dbValue,
                localRelativePath: item.relativePath,
                thumbnailRelativePath: Value(
                  thumbnails.firstOrNull?.relativePath,
                ),
                sourceMediaItemId: Value(item.sourceMediaItemId),
                durationSeconds: Value(item.durationSeconds),
                width: Value(item.width),
                height: Value(item.height),
                fileSizeBytes: sizes[item.id]!,
                capturedAt: Value(item.capturedAt),
                createdAt: now,
              ),
            );
        await _records.registerManagedFile(
          category: FileCategory.media,
          ownerType: ProgressMediaStoragePolicy.fileOwnerType,
          ownerId: item.id,
          relativePath: item.relativePath,
          fileSizeBytes: sizes[item.id]!,
          width: item.width,
          height: item.height,
          durationSeconds: item.durationSeconds,
        );
      }
      final last = reminders?.lastSessionAt;
      await _db
          .into(_db.progressMediaReminderSettings)
          .insertOnConflictUpdate(
            ProgressMediaReminderSettingsCompanion.insert(
              id: const Value(ProgressMediaStoragePolicy.reminderId),
              enabled: Value(reminders?.enabled ?? false),
              cadence: Value(reminders?.cadence),
              lastSessionAt: Value(
                last != null && last.isAfter(draft.capturedAt)
                    ? last
                    : draft.capturedAt,
              ),
              nextReminderAt: Value(
                reminders?.enabled == true &&
                        (last == null || draft.capturedAt.isAfter(last))
                    ? ProgressReminderPolicy.next(
                        draft.capturedAt.toLocal(),
                        ProgressReminderCadence.fromDb(reminders!.cadence!),
                        now.toLocal(),
                      ).toUtc()
                    : reminders?.nextReminderAt,
              ),
              lastPromptedAt: Value(reminders?.lastPromptedAt),
              createdAt: reminders?.createdAt ?? now,
              updatedAt: now,
            ),
          );
    });
  });

  @override
  Future<List<ProgressMediaSession>> loadTimeline() => _safe(
    () async => List.unmodifiable((await _timelineQuery().get()).map(_session)),
  );

  @override
  Stream<List<ProgressMediaSession>> watchTimeline() => _timelineQuery()
      .watch()
      .map(
        (rows) => List<ProgressMediaSession>.unmodifiable(rows.map(_session)),
      )
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (_, _, sink) => sink.addError(
            ProgressMediaFailure.unavailable,
            StackTrace.current,
          ),
        ),
      );

  @override
  Future<ProgressMediaSessionDetails?> getSessionDetails(
    String sessionId,
  ) => _safe(
    () => _db.transaction(() async {
      final row =
          await (_timelineQuery()..where((row) => row.id.equals(sessionId)))
              .getSingleOrNull();
      if (row == null) return null;
      final rows =
          await (_db.select(_db.progressMediaItems)
                ..where(
                  (item) =>
                      item.sessionId.equals(sessionId) &
                      item.deletedAt.isNull(),
                )
                ..orderBy([(item) => OrderingTerm.asc(item.id)]))
              .get();
      final items = <ProgressMediaItem>[];
      for (final item in rows) {
        final file = ProgressMediaFileDraft(
          id: item.id,
          type: ProgressMediaItemType.fromDb(item.type),
          pose: ProgressMediaPose.fromDb(item.pose),
          source: ProgressMediaSource.fromDb(item.source),
          relativePath: item.localRelativePath,
          sourceMediaItemId: item.sourceMediaItemId,
          durationSeconds: item.durationSeconds,
          width: item.width,
          height: item.height,
          capturedAt: item.capturedAt?.toUtc(),
        );
        ProgressMediaStoragePolicy.validatePath(sessionId, file);
        final stat = await _files.statManagedFile(file.relativePath);
        final thumbnail = rows
            .where(
              (candidate) =>
                  candidate.type == ProgressMediaItemType.thumbnail.dbValue &&
                  candidate.sourceMediaItemId == item.id &&
                  candidate.localRelativePath == item.thumbnailRelativePath,
            )
            .firstOrNull;
        items.add(
          ProgressMediaItem(
            file: file,
            fileSizeBytes: item.fileSizeBytes,
            isFileAvailable: stat != null && stat.size == item.fileSizeBytes,
            thumbnailRelativePath: thumbnail?.localRelativePath,
          ),
        );
      }
      final snapshotId = row.bodyMeasurementSnapshotId;
      final snapshot = snapshotId == null
          ? null
          : await (_db.select(
              _db.progressMeasurementSnapshots,
            )..where((s) => s.id.equals(snapshotId))).getSingleOrNull();
      return ProgressMediaSessionDetails(
        session: _session(row),
        items: items,
        measurements: snapshot == null
            ? null
            : ProgressMeasurementSnapshot(
                measuredAt: snapshot.measuredAt.toUtc(),
                bodyweightKg: snapshot.bodyweightKg,
                waistCm: snapshot.waistCm,
                chestCm: snapshot.chestCm,
                hipsCm: snapshot.hipsCm,
                leftArmCm: snapshot.leftArmCm,
                rightArmCm: snapshot.rightArmCm,
                leftThighCm: snapshot.leftThighCm,
                rightThighCm: snapshot.rightThighCm,
              ),
      );
    }),
  );

  @override
  Future<ProgressMediaSession?> getBaselineSession() => _safe(() async {
    final row =
        await (_timelineQuery()..where((row) => row.isBaseline.equals(true)))
            .getSingleOrNull();
    return row == null ? null : _session(row);
  });

  @override
  Future<ProgressMediaSession?> getLatestSession() => _safe(() async {
    final rows = await (_timelineQuery()..limit(1)).get();
    return rows.isEmpty ? null : _session(rows.single);
  });

  @override
  Future<List<ProgressMediaPosePair>> getComparablePosePairs(
    String firstSessionId,
    String secondSessionId,
  ) => _safe(() async {
    final first = await getSessionDetails(firstSessionId);
    final second = await getSessionDetails(secondSessionId);
    if (first == null || second == null) throw ProgressMediaFailure.missing;
    final pairs = <ProgressMediaPosePair>[];
    for (final pose in ProgressMediaStoragePolicy.photoPoses) {
      final a = first.items
          .where(
            (i) =>
                i.file.type == ProgressMediaItemType.photo &&
                i.file.pose == pose,
          )
          .firstOrNull;
      final b = second.items
          .where(
            (i) =>
                i.file.type == ProgressMediaItemType.photo &&
                i.file.pose == pose,
          )
          .firstOrNull;
      if (a != null && b != null) {
        pairs.add(ProgressMediaPosePair(pose: pose, first: a, second: b));
      }
    }
    return List.unmodifiable(pairs);
  });

  @override
  Future<void> setBaseline(String sessionId) => _safe(
    () => _db.transaction(() async {
      final row =
          await (_timelineQuery()..where((row) => row.id.equals(sessionId)))
              .getSingleOrNull();
      if (row == null) throw ProgressMediaFailure.missing;
      final now = _now();
      await (_db.update(_db.progressMediaSessions)..where(
            (row) => row.isBaseline.equals(true) & row.deletedAt.isNull(),
          ))
          .write(
            ProgressMediaSessionsCompanion(
              isBaseline: const Value(false),
              updatedAt: Value(now),
            ),
          );
      await (_db.update(
        _db.progressMediaSessions,
      )..where((row) => row.id.equals(sessionId))).write(
        ProgressMediaSessionsCompanion(
          isBaseline: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }),
  );

  @override
  Future<void> updateNotes(String sessionId, String? notes) => _safe(() async {
    final count =
        await (_db.update(_db.progressMediaSessions)..where(
              (row) => row.id.equals(sessionId) & row.deletedAt.isNull(),
            ))
            .write(
              ProgressMediaSessionsCompanion(
                notes: Value(notes),
                updatedAt: Value(_now()),
              ),
            );
    if (count == 0) throw ProgressMediaFailure.missing;
  });

  @override
  Future<ProgressMediaReminderState> getReminderState() => _safe(() async {
    final row = await _reminderRow();
    if (row == null) return const ProgressMediaReminderState();
    return ProgressMediaReminderState(
      enabled: row.enabled,
      cadence: _cadence(row.cadence),
      lastSessionAt: row.lastSessionAt?.toUtc(),
      nextReminderAt: row.nextReminderAt?.toUtc(),
      lastPromptedAt: row.lastPromptedAt?.toUtc(),
    );
  });

  @override
  Future<ProgressMediaStorageUsage> getStorageUsage() => _safe(
    () => _db.transaction(() async {
      final sessions = await _timelineQuery().get();
      final ids = sessions.map((row) => row.id).toList();
      final items =
          await (_db.select(_db.progressMediaItems)..where(
                (row) => row.sessionId.isIn(ids) & row.deletedAt.isNull(),
              ))
              .get();
      return ProgressMediaStorageUsage(
        sessionCount: sessions.length,
        fileCount: items.length,
        totalBytes: items.fold(0, (total, item) => total + item.fileSizeBytes),
      );
    }),
  );

  SimpleSelectStatement<$ProgressMediaSessionsTable, ProgressMediaSessionRow>
  _timelineQuery() => _db.select(_db.progressMediaSessions)
    ..where((row) => row.deletedAt.isNull())
    ..orderBy([
      (row) => OrderingTerm.desc(row.capturedAt),
      (row) => OrderingTerm.asc(row.id),
    ]);

  Future<ProgressMediaReminderSettingsRow?> _reminderRow() =>
      (_db.select(_db.progressMediaReminderSettings)..where(
            (row) => row.id.equals(ProgressMediaStoragePolicy.reminderId),
          ))
          .getSingleOrNull();

  static ProgressMediaSession _session(ProgressMediaSessionRow row) =>
      ProgressMediaSession(
        id: row.id,
        capturedAt: row.capturedAt.toUtc(),
        mediaType: ProgressMediaType.fromDb(row.mediaType),
        isBaseline: row.isBaseline,
        isCompletePoseSet: row.isCompletePoseSet,
        storageSizeBytes: row.storageSizeBytes,
        bodyweightKg: row.bodyweightKg,
        notes: row.notes,
        reminderCadenceAtCapture: _cadence(row.reminderCadenceAtCapture),
        createdAt: row.createdAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
      );

  static ProgressReminderCadence? _cadence(String? value) => value == null
      ? null
      : ProgressReminderCadence.values.firstWhere((v) => v.dbValue == value);

  static int _fileOrder(ProgressMediaItemType type) => switch (type) {
    ProgressMediaItemType.photo || ProgressMediaItemType.video => 0,
    ProgressMediaItemType.videoFrame => 1,
    ProgressMediaItemType.thumbnail => 2,
  };

  static Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ProgressMediaFailure {
      rethrow;
    } catch (_) {
      throw ProgressMediaFailure.unavailable;
    }
  }
}
