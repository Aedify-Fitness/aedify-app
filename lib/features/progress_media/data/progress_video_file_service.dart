import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/progress_media_storage_policy.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/shared/constants/directory_constants.dart';
import 'package:path/path.dart' as p;

class ProgressVideoFileService {
  ProgressVideoFileService({
    required LocalFileStore files,
    required ProgressPhotoFileService drafts,
    required ProgressVideoMetadataService metadata,
    required String Function() newId,
  }) : _files = files,
       _drafts = drafts,
       _metadata = metadata,
       _newId = newId;
  final LocalFileStore _files;
  final ProgressPhotoFileService _drafts;
  final ProgressVideoMetadataService _metadata;
  final String Function() _newId;

  Future<PreparedProgressVideo> prepare({
    required String sessionId,
    required SelectedProgressVideo selection,
    required ProgressMediaSource source,
    required ProgressVideoLimits limits,
  }) async {
    final created = <String>[];
    try {
      final size = await selection.length();
      if (size <= 0) throw ProgressVideoFailure.invalid;
      if (size > limits.maxBytes) throw ProgressVideoFailure.tooLarge;
      final header = await selection.header();
      if (header.length < 12 ||
          String.fromCharCodes(header.sublist(4, 8)) != 'ftyp') {
        throw ProgressVideoFailure.unsupported;
      }
      final brand = String.fromCharCodes(header.sublist(8, 12));
      if (!const [
        'isom',
        'iso2',
        'iso4',
        'iso5',
        'iso6',
        'mp41',
        'mp42',
        'avc1',
        'M4V ',
        'qt  ',
      ].contains(brand)) {
        throw ProgressVideoFailure.unsupported;
      }
      final id = _newId();
      final extension = brand == 'qt  ' ? '.mov' : '.mp4';
      final staging = p.posix.join(
        FileCategory.temp.path,
        DirectoryConstants.progressPhotoDrafts,
        sessionId,
        '$id$extension',
      );
      final relative = _path(
        sessionId,
        DirectoryConstants.originals,
        '$id$extension',
      );
      // Validate UUID ownership before any file is written.
      ProgressMediaStoragePolicy.validatePath(
        sessionId,
        ProgressMediaFileDraft(
          id: id,
          type: ProgressMediaItemType.video,
          pose: ProgressMediaPose.allSidesVideo,
          source: source,
          relativePath: relative,
        ),
      );
      created.add(staging);
      _drafts.trackDraftFile(sessionId, staging);
      await _files.writeManagedStream(
        staging,
        selection.openRead(),
        maxBytes: limits.maxBytes,
      );
      final stat = await _files.statManagedFile(staging);
      if (stat == null || stat.size != size) throw ProgressVideoFailure.invalid;
      final metadata = await _metadata.inspect(staging, limits);
      if (metadata.duration <= Duration.zero ||
          metadata.width <= 0 ||
          metadata.height <= 0) {
        throw ProgressVideoFailure.invalid;
      }
      if (metadata.duration > limits.maxDuration) {
        throw ProgressVideoFailure.tooLong;
      }
      final original = ProgressMediaFileDraft(
        id: id,
        type: ProgressMediaItemType.video,
        pose: ProgressMediaPose.allSidesVideo,
        source: source,
        relativePath: relative,
        durationSeconds: (metadata.duration.inMilliseconds / 1000).ceil(),
        width: metadata.width,
        height: metadata.height,
      );
      final bytes = metadata.thumbnail;
      ProgressMediaFileDraft? thumbnail;
      String? thumbnailStaging;
      if (bytes != null && bytes.isNotEmpty) {
        final thumbnailId = _newId();
        final path = p.posix.join(
          FileCategory.temp.path,
          DirectoryConstants.progressPhotoDrafts,
          sessionId,
          '$thumbnailId.png',
        );
        created.add(path);
        _drafts.trackDraftFile(sessionId, path);
        try {
          await _files.writeManagedBytes(path, bytes);
          thumbnailStaging = path;
          thumbnail = ProgressMediaFileDraft(
            id: thumbnailId,
            type: ProgressMediaItemType.thumbnail,
            pose: ProgressMediaPose.allSidesVideo,
            source: ProgressMediaSource.generatedThumbnail,
            sourceMediaItemId: id,
            relativePath: _path(
              sessionId,
              DirectoryConstants.thumbnails,
              '$thumbnailId.png',
            ),
          );
        } catch (_) {
          /* The valid video can still be reviewed and saved. */
        }
      }
      return PreparedProgressVideo(
        original: original,
        originalStagingPath: staging,
        duration: metadata.duration,
        thumbnail: thumbnail,
        thumbnailStagingPath: thumbnailStaging,
        preview: thumbnail == null ? null : bytes,
      );
    } on ProgressVideoFailure {
      await _cleanup(created);
      rethrow;
    } on ManagedFileFailure {
      await _cleanup(created);
      throw ProgressVideoFailure.tooLarge;
    } catch (_) {
      await _cleanup(created);
      throw ProgressVideoFailure.storage;
    } finally {
      try {
        await selection.release();
      } catch (_) {
        /* App cache is temporary. */
      }
    }
  }

  Future<void> _cleanup(List<String> paths) async {
    for (final path in paths) {
      try {
        await _files.deleteManagedRelativeFile(path);
      } catch (_) {
        /* Draft store retains ownership for retry. */
      }
    }
  }

  static String _path(String session, String folder, String filename) =>
      p.posix.join(
        DirectoryConstants.media,
        DirectoryConstants.progress,
        DirectoryConstants.sessions,
        session,
        folder,
        filename,
      );
}
