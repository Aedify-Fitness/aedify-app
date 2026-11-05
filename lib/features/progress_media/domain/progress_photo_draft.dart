import 'dart:typed_data';

import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';

enum ProgressPhotoFailure implements Exception {
  permission,
  unsupported,
  invalid,
  tooLarge,
  storage,
  cleanup,
  bodyweight;

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
  const RecoveredProgressPhoto({this.photo, this.failure});
  final SelectedProgressPhoto? photo;
  final ProgressPhotoFailure? failure;
}

/// Private temporary file references with a bounded display preview.
class PreparedProgressPhoto {
  const PreparedProgressPhoto({
    required this.original,
    required this.originalStagingPath,
    required this.preview,
    this.thumbnail,
    this.thumbnailStagingPath,
  });
  final ProgressMediaFileDraft original;
  final String originalStagingPath;
  final ProgressMediaFileDraft? thumbnail;
  final String? thumbnailStagingPath;
  final Uint8List preview;
}

class ProgressPhotoState {
  ProgressPhotoState({
    required this.units,
    Map<ProgressMediaPose, PreparedProgressPhoto> photos = const {},
    this.recovered,
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
  final String notes;
  final String bodyweight;
  final bool busy;
  final ProgressPhotoFailure? failure;
  final bool cancelled;
  final bool saved;
  bool get dirty =>
      photos.isNotEmpty ||
      recovered != null ||
      notes.isNotEmpty ||
      bodyweight.isNotEmpty;
  bool get canSave => photos.isNotEmpty && recovered == null && !busy && !saved;

  ProgressPhotoState copyWith({
    Map<ProgressMediaPose, PreparedProgressPhoto>? photos,
    PreparedProgressPhoto? recovered,
    bool clearRecovered = false,
    String? notes,
    String? bodyweight,
    bool? busy,
    ProgressPhotoFailure? failure,
    bool cancelled = false,
    bool? saved,
  }) => ProgressPhotoState(
    units: units,
    photos: photos ?? this.photos,
    recovered: clearRecovered ? null : recovered ?? this.recovered,
    notes: notes ?? this.notes,
    bodyweight: bodyweight ?? this.bodyweight,
    busy: busy ?? this.busy,
    failure: failure,
    cancelled: cancelled,
    saved: saved ?? this.saved,
  );
}
