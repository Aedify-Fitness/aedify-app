import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_storage_policy.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/shared/constants/directory_constants.dart';
import 'package:path/path.dart' as p;

abstract final class ProgressPhotoLimits {
  static const maxBytes = 20 * 1024 * 1024;
  static const maxPixels = 64 * 1000 * 1000;
  static const thumbnailEdge = 512;
}

/// Decodes locally and produces a bounded, metadata-free PNG preview.
class ProgressPhotoProcessor {
  Future<({String extension, int width, int height, Uint8List preview})> decode(
    Uint8List bytes,
  ) async {
    final extension = _extension(bytes);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final width = descriptor.width;
      final height = descriptor.height;
      if (width <= 0 ||
          height <= 0 ||
          width * height > ProgressPhotoLimits.maxPixels) {
        throw ProgressPhotoFailure.tooLarge;
      }
      final scale = math.min(
        1.0,
        ProgressPhotoLimits.thumbnailEdge / math.max(width, height),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (width * scale).round()),
        targetHeight: math.max(1, (height * scale).round()),
      );
      if (codec.frameCount != 1) throw ProgressPhotoFailure.invalid;
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw ProgressPhotoFailure.invalid;
      return (
        extension: extension,
        width: width,
        height: height,
        preview: data.buffer.asUint8List(),
      );
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }

  static String _extension(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71) {
      return '.png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      return '.jpg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return '.webp';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp' &&
        const [
          'heic',
          'heix',
          'hevc',
          'hevx',
          'mif1',
        ].contains(String.fromCharCodes(bytes.sublist(8, 12)))) {
      return '.heic';
    }
    throw ProgressPhotoFailure.invalid;
  }
}

/// Owns temporary photos and compensates failed durable saves through M1 wrappers.
class ProgressPhotoFileService {
  ProgressPhotoFileService({
    required LocalFileStore files,
    required ProgressMediaRepository repository,
    required String Function() newId,
    ProgressPhotoProcessor? processor,
  }) : _files = files,
       _repository = repository,
       _newId = newId,
       _processor = processor ?? ProgressPhotoProcessor();
  final LocalFileStore _files;
  final ProgressMediaRepository _repository;
  final String Function() _newId;
  final ProgressPhotoProcessor _processor;
  final Map<String, Set<String>> _temporary = {};
  final Map<String, Set<String>> _uncommitted = {};

  Future<PreparedProgressPhoto> prepare({
    required String sessionId,
    required ProgressMediaPose pose,
    required ProgressMediaSource source,
    required SelectedProgressPhoto selection,
  }) async {
    final created = <String>[];
    try {
      if (await selection.length() > ProgressPhotoLimits.maxBytes) {
        throw ProgressPhotoFailure.tooLarge;
      }
      final bytes = await selection.readBytes();
      if (bytes.isEmpty) throw ProgressPhotoFailure.invalid;
      if (bytes.length > ProgressPhotoLimits.maxBytes) {
        throw ProgressPhotoFailure.tooLarge;
      }
      final decoded = await _processor.decode(bytes);
      final originalId = _newId();
      final thumbnailId = _newId();
      final original = ProgressMediaFileDraft(
        id: originalId,
        type: ProgressMediaItemType.photo,
        pose: pose,
        source: source,
        relativePath: _durablePath(
          sessionId,
          DirectoryConstants.originals,
          '$originalId${decoded.extension}',
        ),
        width: decoded.width,
        height: decoded.height,
      );
      final staging = _temporaryPath(
        sessionId,
        '$originalId${decoded.extension}',
      );
      ProgressMediaStoragePolicy.validatePath(sessionId, original);
      created.add(staging);
      _temporary.putIfAbsent(sessionId, () => {}).add(staging);
      await _write(staging, bytes);
      final thumbnailPath = _temporaryPath(sessionId, '$thumbnailId.png');
      ProgressMediaFileDraft? thumbnail;
      try {
        created.add(thumbnailPath);
        _temporary[sessionId]!.add(thumbnailPath);
        await _files.writeManagedBytes(thumbnailPath, decoded.preview);
        thumbnail = ProgressMediaFileDraft(
          id: thumbnailId,
          type: ProgressMediaItemType.thumbnail,
          pose: pose,
          source: ProgressMediaSource.generatedThumbnail,
          sourceMediaItemId: originalId,
          relativePath: _durablePath(
            sessionId,
            DirectoryConstants.thumbnails,
            '$thumbnailId.png',
          ),
        );
      } catch (_) {
        // Keep the valid original and in-memory preview. Cleanup retries later.
      }
      return PreparedProgressPhoto(
        original: original,
        originalStagingPath: staging,
        preview: decoded.preview,
        thumbnail: thumbnail,
        thumbnailStagingPath: thumbnail == null ? null : thumbnailPath,
      );
    } on ProgressPhotoFailure {
      await _cleanupBestEffort(created);
      rethrow;
    } catch (_) {
      await _cleanupBestEffort(created);
      throw ProgressPhotoFailure.invalid;
    } finally {
      try {
        await selection.release();
      } catch (_) {
        /* Plugin cache is temporary. */
      }
    }
  }

  void trackDraftFile(String sessionId, String relativePath) {
    _temporary.putIfAbsent(sessionId, () => {}).add(relativePath);
  }

  Future<void> remove(PreparedProgressMedia photo) async {
    try {
      await _files.deleteManagedRelativeFile(photo.originalStagingPath);
      final thumbnail = photo.thumbnailStagingPath;
      if (thumbnail != null) await _files.deleteManagedRelativeFile(thumbnail);
    } catch (_) {
      throw ProgressPhotoFailure.cleanup;
    }
  }

  Future<void> discard(String sessionId) async {
    try {
      for (final path in _uncommitted[sessionId] ?? <String>{}) {
        await _files.deleteManagedRelativeFile(path);
      }
      for (final path in _temporary[sessionId] ?? <String>{}) {
        await _files.deleteManagedRelativeFile(path);
      }
      _uncommitted.remove(sessionId);
      _temporary.remove(sessionId);
    } catch (_) {
      throw ProgressPhotoFailure.cleanup;
    }
  }

  Future<void> save({
    required String sessionId,
    required DateTime capturedAt,
    required Iterable<PreparedProgressPhoto> photos,
    PreparedProgressVideo? video,
    ProgressVideoLimits videoLimits = const ProgressVideoLimits(),
    required String? notes,
    double? bodyweightKg,
  }) async {
    final pending = _uncommitted.putIfAbsent(sessionId, () => {});
    try {
      for (final path in pending.toList()) {
        await _files.deleteManagedRelativeFile(path);
        pending.remove(path);
      }
      final items = <ProgressMediaFileDraft>[];
      for (final photo in <PreparedProgressMedia>[...photos, ?video]) {
        final original = photo.original;
        pending.add(original.relativePath);
        await _files.copyManagedFile(
          photo.originalStagingPath,
          original.relativePath,
          maxBytes: original.type == ProgressMediaItemType.video
              ? videoLimits.maxBytes
              : ProgressPhotoLimits.maxBytes,
        );
        items.add(original);
        final thumbnail = photo.thumbnail;
        final staging = photo.thumbnailStagingPath;
        if (thumbnail != null && staging != null) {
          pending.add(thumbnail.relativePath);
          await _files.copyManagedFile(
            staging,
            thumbnail.relativePath,
            maxBytes: ProgressPhotoLimits.maxBytes,
          );
          items.add(thumbnail);
        }
      }
      await _repository.saveSession(
        ProgressMediaSessionDraft(
          id: sessionId,
          capturedAt: capturedAt,
          items: items,
          notes: notes,
          bodyweightKg: bodyweightKg,
        ),
      );
    } catch (_) {
      await _cleanupBestEffort(pending);
      throw ProgressPhotoFailure.storage;
    }
    // Metadata committed: never compensate/delete durable files after this point.
    _uncommitted.remove(sessionId);
    try {
      await discard(sessionId);
    } catch (_) {
      /* Startup removes temporary drafts. */
    }
  }

  Future<void> _cleanupBestEffort(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        await _files.deleteManagedRelativeFile(path);
      } catch (_) {
        /* Retain ownership for retry/startup. */
      }
    }
  }

  Future<void> _write(String path, Uint8List bytes) async {
    try {
      await _files.writeManagedBytes(path, bytes);
    } catch (_) {
      throw ProgressPhotoFailure.storage;
    }
  }

  static String _temporaryPath(String sessionId, String filename) =>
      p.posix.join(
        FileCategory.temp.path,
        DirectoryConstants.progressPhotoDrafts,
        sessionId,
        filename,
      );
  static String _durablePath(
    String sessionId,
    String folder,
    String filename,
  ) => p.posix.join(
    DirectoryConstants.media,
    DirectoryConstants.progress,
    DirectoryConstants.sessions,
    sessionId,
    folder,
    filename,
  );
}
