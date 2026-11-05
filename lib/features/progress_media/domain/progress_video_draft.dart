import 'dart:typed_data';

import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';

enum ProgressVideoFailure implements ProgressMediaDraftFailure {
  permission,
  microphone,
  unsupported,
  invalid,
  tooLong,
  tooLarge,
  storage,
  preview;

  @override
  String get message => switch (this) {
    permission => AppErrorStrings.progressPhotoPermission,
    microphone => AppErrorStrings.progressVideoMicrophone,
    unsupported => AppErrorStrings.progressVideoUnsupported,
    invalid => AppErrorStrings.progressVideoInvalid,
    tooLong => AppErrorStrings.progressVideoTooLong,
    tooLarge => AppErrorStrings.progressVideoTooLarge,
    storage => AppErrorStrings.progressMediaUnavailable,
    preview => AppErrorStrings.progressVideoPreview,
  };
}

class ProgressVideoLimits {
  const ProgressVideoLimits({
    this.maxDuration = const Duration(seconds: 60),
    this.maxBytes = 100 * 1024 * 1024,
  });
  final Duration maxDuration;
  final int maxBytes;
  static const thumbnailEdge = 512;
  static const probeTimeout = Duration(seconds: 30);
}

abstract interface class SelectedProgressVideo {
  Future<int> length();
  Future<Uint8List> header();
  Stream<List<int>> openRead();
  Future<void> release();
}

class ProgressVideoMetadata {
  const ProgressVideoMetadata({
    required this.duration,
    required this.width,
    required this.height,
    this.thumbnail,
  });
  final Duration duration;
  final int width;
  final int height;
  final Uint8List? thumbnail;
}

class PreparedProgressVideo implements PreparedProgressMedia {
  const PreparedProgressVideo({
    required this.original,
    required this.originalStagingPath,
    required this.duration,
    this.thumbnail,
    this.thumbnailStagingPath,
    this.preview,
  });
  @override
  final ProgressMediaFileDraft original;
  @override
  final String originalStagingPath;
  @override
  final ProgressMediaFileDraft? thumbnail;
  @override
  final String? thumbnailStagingPath;
  final Duration duration;
  final Uint8List? preview;
}
