import 'dart:typed_data';

import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';

enum ProgressPhotoFailure implements ProgressMediaDraftFailure {
  permission,
  unsupported,
  invalid,
  tooLarge,
  storage,
  cleanup,
  bodyweight;

  @override
  String get message => switch (this) {
    permission => AppErrorStrings.progressPhotoPermission,
    unsupported => AppErrorStrings.progressPhotoUnsupported,
    invalid => AppErrorStrings.progressPhotoInvalid,
    tooLarge => AppErrorStrings.progressPhotoTooLarge,
    storage => AppErrorStrings.progressMediaUnavailable,
    cleanup => AppErrorStrings.progressPhotoCleanup,
    bodyweight => AppErrorStrings.progressPhotoBodyweight,
  };
}

/// Short-lived platform selection; no selected paths enter widget state/logs.
abstract interface class SelectedProgressPhoto {
  Future<int> length();
  Future<Uint8List> readBytes();
  Future<void> release();
}

class RecoveredProgressPhoto {
  const RecoveredProgressPhoto({this.photo, this.video, this.failure});
  final SelectedProgressPhoto? photo;
  final SelectedProgressVideo? video;
  final ProgressMediaDraftFailure? failure;
}

/// Private temporary file references with a bounded display preview.
class PreparedProgressPhoto implements PreparedProgressMedia {
  const PreparedProgressPhoto({
    required this.original,
    required this.originalStagingPath,
    required this.preview,
    this.thumbnail,
    this.thumbnailStagingPath,
  });
  @override
  final ProgressMediaFileDraft original;
  @override
  final String originalStagingPath;
  @override
  final ProgressMediaFileDraft? thumbnail;
  @override
  final String? thumbnailStagingPath;
  final Uint8List preview;
}

class ProgressPhotoState {
  ProgressPhotoState({
    required this.units,
    Map<ProgressMediaPose, PreparedProgressPhoto> photos = const {},
    this.recovered,
    this.video,
    this.recoveredVideo,
    this.videoLimitSeconds = 60,
    this.videoPreviewReady = false,
    this.notes = '',
    this.bodyweight = '',
    this.busy = false,
    this.failure,
    this.cancelled = false,
    this.saved = false,
  }) : photos = Map.unmodifiable(photos);
  final PreferredUnit units;
  final Map<ProgressMediaPose, PreparedProgressPhoto> photos;
  final PreparedProgressPhoto? recovered;
  final PreparedProgressVideo? video;
  final PreparedProgressVideo? recoveredVideo;
  final int videoLimitSeconds;
  final bool videoPreviewReady;
  final String notes;
  final String bodyweight;
  final bool busy;
  final ProgressMediaDraftFailure? failure;
  final bool cancelled;
  final bool saved;
  bool get dirty =>
      photos.isNotEmpty ||
      recovered != null ||
      video != null ||
      recoveredVideo != null ||
      notes.isNotEmpty ||
      bodyweight.isNotEmpty;
  bool get canSave =>
      (photos.isNotEmpty || video != null) &&
      recovered == null &&
      recoveredVideo == null &&
      (video == null ||
          (videoPreviewReady &&
              video!.duration <= Duration(seconds: videoLimitSeconds))) &&
      !busy &&
      !saved;

  ProgressPhotoState copyWith({
    Map<ProgressMediaPose, PreparedProgressPhoto>? photos,
    PreparedProgressPhoto? recovered,
    bool clearRecovered = false,
    PreparedProgressVideo? video,
    bool clearVideo = false,
    PreparedProgressVideo? recoveredVideo,
    bool clearRecoveredVideo = false,
    int? videoLimitSeconds,
    bool? videoPreviewReady,
    String? notes,
    String? bodyweight,
    bool? busy,
    ProgressMediaDraftFailure? failure,
    bool cancelled = false,
    bool? saved,
  }) => ProgressPhotoState(
    units: units,
    photos: photos ?? this.photos,
    recovered: clearRecovered ? null : recovered ?? this.recovered,
    video: clearVideo ? null : video ?? this.video,
    recoveredVideo: clearRecoveredVideo
        ? null
        : recoveredVideo ?? this.recoveredVideo,
    videoLimitSeconds: videoLimitSeconds ?? this.videoLimitSeconds,
    videoPreviewReady: videoPreviewReady ?? this.videoPreviewReady,
    notes: notes ?? this.notes,
    bodyweight: bodyweight ?? this.bodyweight,
    busy: busy ?? this.busy,
    failure: failure,
    cancelled: cancelled,
    saved: saved ?? this.saved,
  );
}
