import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/shared/constants/directory_constants.dart';
import 'package:path/path.dart' as p;

/// Structural storage validation; capture codecs/size caps belong to M6-002/003.
abstract final class ProgressMediaStoragePolicy {
  static const fileOwnerType = 'progress_media_item';
  static const reminderId = 'default';
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  static const photoPoses = [
    ProgressMediaPose.front,
    ProgressMediaPose.back,
    ProgressMediaPose.leftSide,
    ProgressMediaPose.rightSide,
  ];

  static void validate(ProgressMediaSessionDraft draft) {
    if (!_uuid.hasMatch(draft.id) || draft.items.isEmpty) {
      throw ProgressMediaFailure.invalid;
    }
    final items = {for (final item in draft.items) item.id: item};
    if (items.length != draft.items.length ||
        draft.items.map((item) => item.relativePath).toSet().length !=
            items.length ||
        !draft.items.any((item) => item.type.isOriginal)) {
      throw ProgressMediaFailure.invalid;
    }
    for (final value in [draft.bodyweightKg, ...?draft.measurements?.values]) {
      if (value != null && (!value.isFinite || value <= 0)) {
        throw ProgressMediaFailure.invalid;
      }
    }
    final thumbnailParents = <String>{};
    for (final item in draft.items) {
      validatePath(draft.id, item);
      if ((item.width != null && item.width! <= 0) ||
          (item.height != null && item.height! <= 0)) {
        throw ProgressMediaFailure.invalid;
      }
      if (item.type == ProgressMediaItemType.video) {
        if (item.durationSeconds == null ||
            item.durationSeconds! <= 0 ||
            (item.pose != ProgressMediaPose.allSidesVideo &&
                item.pose != ProgressMediaPose.unknown)) {
          throw ProgressMediaFailure.invalid;
        }
      } else if (item.durationSeconds != null) {
        throw ProgressMediaFailure.invalid;
      }
      // A video thumbnail retains its parent's pose.
      if (item.pose == ProgressMediaPose.allSidesVideo &&
          item.type != ProgressMediaItemType.video &&
          item.type != ProgressMediaItemType.thumbnail) {
        throw ProgressMediaFailure.invalid;
      }
      if (item.type.isOriginal) {
        if (item.sourceMediaItemId != null ||
            (item.source != ProgressMediaSource.camera &&
                item.source != ProgressMediaSource.gallery)) {
          throw ProgressMediaFailure.invalid;
        }
      } else {
        final parent = items[item.sourceMediaItemId];
        if (parent == null || parent.id == item.id) {
          throw ProgressMediaFailure.invalid;
        }
        if (item.type == ProgressMediaItemType.videoFrame) {
          if (parent.type != ProgressMediaItemType.video ||
              item.source != ProgressMediaSource.extractedFrame) {
            throw ProgressMediaFailure.invalid;
          }
        } else if (parent.type == ProgressMediaItemType.thumbnail ||
            item.pose != parent.pose ||
            item.source != ProgressMediaSource.generatedThumbnail ||
            !thumbnailParents.add(parent.id)) {
          throw ProgressMediaFailure.invalid;
        }
      }
    }
  }

  /// Exact UUID-owned paths prevent traversal and cross-session file reuse.
  static void validatePath(String sessionId, ProgressMediaFileDraft item) {
    final folder = switch (item.type) {
      ProgressMediaItemType.photo ||
      ProgressMediaItemType.video => DirectoryConstants.originals,
      ProgressMediaItemType.thumbnail => DirectoryConstants.thumbnails,
      ProgressMediaItemType.videoFrame => DirectoryConstants.frames,
    };
    final extension = p.posix.extension(item.relativePath);
    final extensions = item.type == ProgressMediaItemType.video
        ? const ['.mp4', '.mov']
        : const ['.jpg', '.jpeg', '.png', '.heic', '.webp'];
    final expected = p.posix.join(
      DirectoryConstants.media,
      DirectoryConstants.progress,
      DirectoryConstants.sessions,
      sessionId,
      folder,
      '${item.id}$extension',
    );
    if (!_uuid.hasMatch(sessionId) ||
        !_uuid.hasMatch(item.id) ||
        !extensions.contains(extension) ||
        item.relativePath != expected) {
      throw ProgressMediaFailure.invalid;
    }
  }
}
