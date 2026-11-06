import 'dart:async';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/progress_media_storage_policy.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_deletion.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

/// Existing deleted_at rows form a durable, retryable file-deletion queue.
/// No filesystem delete happens until the logical transaction commits.
class ProgressMediaDeletionService {
  ProgressMediaDeletionService({
    required AppDatabase database,
    required LocalFileStore files,
    required DateTime Function() now,
    Set<String> Function()? activeDrafts,
  }) : _db = database,
       _files = files,
       _now = now,
       _activeDrafts = activeDrafts ?? _none;
  final AppDatabase _db;
  final LocalFileStore _files;
  final DateTime Function() _now;
  final Set<String> Function() _activeDrafts;
  Future<void> _tail = Future.value();
  static Set<String> _none() => const {};
  static const orphanAge = Duration(days: 1);
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  Future<ProgressCleanupStatus> deleteSession(String id) => _serial(() async {
    await _mark(sessionId: id);
    return _finish();
  });
  Future<ProgressCleanupStatus> deleteItem(String sessionId, String itemId) =>
      _serial(() async {
        await _mark(sessionId: sessionId, itemId: itemId);
        return _finish();
      });
  Future<ProgressCleanupStatus> deleteAll() => _serial(() async {
    await _mark(all: true);
    return _finish();
  });
  Future<ProgressCleanupStatus> recover() => _serial(_cleanup);
  Future<ProgressCleanupStatus> status() => _serial(() => _status());
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _tail.then((_) async {
      try {
        return await action();
      } catch (_) {
        throw ProgressDeletionFailure.unavailable;
      }
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> _mark({
    String? sessionId,
    String? itemId,
    bool all = false,
  }) => _db.transaction(() async {
    if (!all &&
        (!_uuid.hasMatch(sessionId ?? '') ||
            (itemId != null && !_uuid.hasMatch(itemId)))) {
      throw ProgressDeletionFailure.unavailable;
    }
    final sessions =
        await (_db.select(_db.progressMediaSessions)..where(
              (s) => all ? const Constant(true) : s.id.equals(sessionId!),
            ))
            .get();
    for (final session in sessions) {
      final rows = await (_db.select(
        _db.progressMediaItems,
      )..where((i) => i.sessionId.equals(session.id))).get();
      final target = itemId == null
          ? null
          : rows.where((r) => r.id == itemId).firstOrNull;
      if (itemId != null && target == null) {
        continue; // Repeated deletion is a no-op.
      }
      if (target != null &&
          !ProgressMediaItemType.fromDb(target.type).isOriginal) {
        throw ProgressDeletionFailure.unavailable;
      }
      final selected = itemId == null
          ? rows.map((r) => r.id).toSet()
          : <String>{itemId};
      var grew = true;
      while (grew) {
        grew = false;
        for (final row in rows) {
          if (selected.contains(row.sourceMediaItemId) &&
              selected.add(row.id)) {
            grew = true;
          }
        }
      }
      for (final row in rows.where((r) => selected.contains(r.id))) {
        await _validate(row);
      }
      final now = _now();
      await (_db.update(_db.progressMediaItems)
            ..where((r) => r.id.isIn(selected) & r.deletedAt.isNull()))
          .write(ProgressMediaItemsCompanion(deletedAt: Value(now)));
      final remaining = rows
          .where((r) => r.deletedAt == null && !selected.contains(r.id))
          .toList();
      final originals = remaining
          .where((r) => ProgressMediaItemType.fromDb(r.type).isOriginal)
          .toList();
      if (originals.isEmpty) {
        // Even malformed leftover derivatives are hidden and retain cleanup intent.
        for (final row in remaining) {
          await _validate(row);
        }
        await (_db.update(_db.progressMediaItems)..where(
              (r) => r.sessionId.equals(session.id) & r.deletedAt.isNull(),
            ))
            .write(ProgressMediaItemsCompanion(deletedAt: Value(now)));
        final snapshot = session.bodyMeasurementSnapshotId;
        await (_db.update(
          _db.progressMediaSessions,
        )..where((s) => s.id.equals(session.id))).write(
          ProgressMediaSessionsCompanion(
            deletedAt: Value(session.deletedAt ?? now),
            isBaseline: const Value(false),
            notes: const Value(null),
            bodyweightKg: const Value(null),
            bodyMeasurementSnapshotId: const Value(null),
            storageSizeBytes: const Value(0),
            updatedAt: Value(now),
          ),
        );
        if (snapshot != null) {
          await (_db.delete(
            _db.progressMeasurementSnapshots,
          )..where((s) => s.id.equals(snapshot))).go();
        }
      } else {
        final photos = originals
            .where((r) => r.type == ProgressMediaItemType.photo.dbValue)
            .toList();
        final video = originals.any(
          (r) => r.type == ProgressMediaItemType.video.dbValue,
        );
        await (_db.update(
          _db.progressMediaSessions,
        )..where((s) => s.id.equals(session.id))).write(
          ProgressMediaSessionsCompanion(
            mediaType: Value(
              photos.isEmpty
                  ? ProgressMediaType.video.dbValue
                  : video
                  ? ProgressMediaType.both.dbValue
                  : ProgressMediaType.photoSet.dbValue,
            ),
            isCompletePoseSet: Value(
              ProgressMediaStoragePolicy.photoPoses.every(
                (pose) => photos.any((r) => r.pose == pose.dbValue),
              ),
            ),
            storageSizeBytes: Value(
              remaining.fold(0, (sum, r) => sum + r.fileSizeBytes),
            ),
            updatedAt: Value(now),
          ),
        );
      }
    }
    await _reconcileMetadata();
  });

  Future<void> _reconcileMetadata() async {
    final remaining =
        await (_db.select(_db.progressMediaSessions)
              ..where((s) => s.deletedAt.isNull())
              ..orderBy([
                (s) => OrderingTerm.asc(s.capturedAt),
                (s) => OrderingTerm.asc(s.id),
              ]))
            .get();
    if (remaining.isEmpty) {
      await _db.delete(_db.progressMediaReminderSettings).go();
      return;
    }
    if (!remaining.any((s) => s.isBaseline)) {
      await (_db.update(
        _db.progressMediaSessions,
      )..where((s) => s.id.equals(remaining.first.id))).write(
        ProgressMediaSessionsCompanion(
          isBaseline: const Value(true),
          updatedAt: Value(_now()),
        ),
      );
    }
    final reminder = await _db
        .select(_db.progressMediaReminderSettings)
        .getSingleOrNull();
    final latest = remaining.last.capturedAt;
    if (reminder != null && reminder.lastSessionAt != latest) {
      final cadence = reminder.cadence == null
          ? null
          : ProgressReminderCadence.fromDb(reminder.cadence!);
      await _db
          .update(_db.progressMediaReminderSettings)
          .write(
            ProgressMediaReminderSettingsCompanion(
              lastSessionAt: Value(latest),
              nextReminderAt: Value(
                reminder.enabled &&
                        cadence != null &&
                        cadence != ProgressReminderCadence.off
                    ? ProgressReminderPolicy.next(
                        latest.toLocal(),
                        cadence,
                        _now().toLocal(),
                      ).toUtc()
                    : null,
              ),
              updatedAt: Value(_now()),
            ),
          );
    }
  }

  Future<void> _validate(ProgressMediaItemRow row) async {
    ProgressMediaStoragePolicy.validatePath(
      row.sessionId,
      ProgressMediaFileDraft(
        id: row.id,
        type: ProgressMediaItemType.fromDb(row.type),
        pose: ProgressMediaPose.fromDb(row.pose),
        source: ProgressMediaSource.fromDb(row.source),
        relativePath: row.localRelativePath,
      ),
    );
    final registrations = await (_db.select(
      _db.localFileRecords,
    )..where((r) => r.localRelativePath.equals(row.localRelativePath))).get();
    if (registrations.any(
      (r) =>
          r.category != FileCategory.media.path ||
          r.ownerType != ProgressMediaStoragePolicy.fileOwnerType ||
          r.ownerId != row.id,
    )) {
      throw ProgressDeletionFailure.unavailable;
    }
    final other =
        await (_db.select(_db.progressMediaItems)..where(
              (r) =>
                  r.localRelativePath.equals(row.localRelativePath) &
                  r.id.equals(row.id).not(),
            ))
            .get();
    if (other.isNotEmpty) throw ProgressDeletionFailure.unavailable;
  }

  Future<ProgressCleanupStatus> _finish() async {
    try {
      return await _cleanup();
    } catch (_) {
      return const ProgressCleanupStatus(retryNeeded: true);
    }
  }

  Future<void> _sessionDrafts(String sessionId) async {
    if (_activeDrafts().contains(sessionId)) {
      throw ProgressDeletionFailure.unavailable;
    }
    final root = p.posix.join('temp', 'progress_photo_drafts', sessionId);
    for (final entry in await _files.listManagedFiles(root)) {
      final parts = p.posix.split(entry.relativePath);
      if (parts.length != 4 || !_ownedName(parts.last)) {
        throw ProgressDeletionFailure.unavailable;
      }
      await _files.deleteManagedRelativeFile(entry.relativePath);
    }
    await _files.removeEmptyManagedDirectories(root);
  }

  static const _extensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.webp',
    '.mp4',
    '.mov',
  ];
  static bool _ownedName(String name) {
    final stem = p.posix.basenameWithoutExtension(name);
    if (_uuid.hasMatch(stem) && _extensions.contains(p.posix.extension(name))) {
      return true;
    }
    final parts = name.split('.');
    return parts.length == 4 &&
        _uuid.hasMatch(parts[0]) &&
        _extensions.contains('.${parts[1]}') &&
        _uuid.hasMatch(parts[2]) &&
        parts[3] == 'partial';
  }

  Future<ProgressCleanupStatus> _cleanup() async {
    var failed = false;
    var pending = await (_db.select(
      _db.progressMediaItems,
    )..where((r) => r.deletedAt.isNotNull())).get();
    // Children are purged first; a failed child keeps its parent retryable.
    while (pending.isNotEmpty) {
      final leaves = pending
          .where(
            (r) => !pending.any((child) => child.sourceMediaItemId == r.id),
          )
          .toList();
      if (leaves.isEmpty) {
        failed = true;
        break;
      }
      var progressed = false;
      for (final row in leaves) {
        try {
          await _validate(row);
          final liveChildren = await (_db.select(
            _db.progressMediaItems,
          )..where((r) => r.sourceMediaItemId.equals(row.id))).get();
          if (liveChildren.isNotEmpty) {
            failed = true;
            continue;
          }
          await _files.deleteManagedRelativeFile(row.localRelativePath);
          await _db.transaction(() async {
            await (_db.delete(_db.localFileRecords)..where(
                  (r) =>
                      r.ownerType.equals(
                        ProgressMediaStoragePolicy.fileOwnerType,
                      ) &
                      r.ownerId.equals(row.id) &
                      r.localRelativePath.equals(row.localRelativePath),
                ))
                .go();
            await (_db.delete(_db.progressMediaItems)
                  ..where((r) => r.id.equals(row.id) & r.deletedAt.isNotNull()))
                .go();
          });
          pending.removeWhere((r) => r.id == row.id);
          progressed = true;
        } catch (_) {
          failed = true;
        }
      }
      if (!progressed) break;
    }
    final sessions = await (_db.select(
      _db.progressMediaSessions,
    )..where((s) => s.deletedAt.isNotNull())).get();
    for (final session in sessions) {
      try {
        final items = await (_db.select(
          _db.progressMediaItems,
        )..where((i) => i.sessionId.equals(session.id))).get();
        if (items.isNotEmpty) continue;
        await _sessionDrafts(session.id);
        await _files.removeEmptyManagedDirectories(
          p.posix.join('media', 'progress', 'sessions', session.id),
        );
        await (_db.delete(_db.progressMediaSessions)
              ..where((s) => s.id.equals(session.id) & s.deletedAt.isNotNull()))
            .go();
      } catch (_) {
        failed = true;
      }
    }
    try {
      await _orphans();
    } catch (_) {
      failed = true;
    }
    return _status(retryNeeded: failed);
  }

  Future<void> _orphans() async {
    final rows = await _db.select(_db.progressMediaItems).get();
    final registrations = await _db.select(_db.localFileRecords).get();
    final protected = {
      ...rows.map((r) => r.localRelativePath),
      ...registrations.map((r) => r.localRelativePath),
    };
    final drafts = _activeDrafts();
    for (final root in [
      'media/progress/sessions',
      'temp/progress_photo_drafts',
    ]) {
      for (final entry in await _files.listManagedFiles(root)) {
        final parts = p.posix.split(entry.relativePath);
        final id = root.startsWith('media')
            ? (parts.length == 6 ? parts[3] : null)
            : (parts.length == 4 ? parts[2] : null);
        if (id == null ||
            !_uuid.hasMatch(id) ||
            drafts.contains(id) ||
            protected.contains(entry.relativePath) ||
            _now().difference(entry.modified) < orphanAge) {
          continue;
        }
        if (!_ownedName(p.posix.basename(entry.relativePath))) continue;
        if (root.startsWith('media') &&
            !const ['originals', 'thumbnails', 'frames'].contains(parts[4])) {
          continue;
        }
        // Recheck current ownership immediately before unlinking a stale orphan.
        final item = await (_db.select(
          _db.progressMediaItems,
        )..where((r) => r.localRelativePath.equals(entry.relativePath))).get();
        final record = await (_db.select(
          _db.localFileRecords,
        )..where((r) => r.localRelativePath.equals(entry.relativePath))).get();
        if (item.isEmpty && record.isEmpty && !_activeDrafts().contains(id)) {
          await _files.deleteManagedRelativeFile(entry.relativePath);
        }
      }
    }
  }

  Future<ProgressCleanupStatus> _status({bool retryNeeded = false}) async {
    final sessions = await (_db.select(
      _db.progressMediaSessions,
    )..where((s) => s.deletedAt.isNull())).get();
    final items = await (_db.select(
      _db.progressMediaItems,
    )..where((i) => i.deletedAt.isNotNull())).get();
    final deletedSessions = await (_db.select(
      _db.progressMediaSessions,
    )..where((s) => s.deletedAt.isNotNull())).get();
    return ProgressCleanupStatus(
      sessionCount: sessions.length,
      activeBytes: sessions.fold(0, (sum, s) => sum + s.storageSizeBytes),
      pendingFiles: items.length,
      pendingBytes: items.fold(0, (sum, i) => sum + i.fileSizeBytes),
      retryNeeded: retryNeeded || deletedSessions.isNotEmpty,
    );
  }
}
