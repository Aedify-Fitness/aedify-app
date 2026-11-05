import 'package:aedify/shared/constants/app_error_strings.dart';

abstract interface class ProgressMediaDraftFailure implements Exception {
  String get message;
}

/// Temporary file ownership shared by photos and videos before an explicit save.
abstract interface class PreparedProgressMedia {
  ProgressMediaFileDraft get original;
  String get originalStagingPath;
  ProgressMediaFileDraft? get thumbnail;
  String? get thumbnailStagingPath;
}

/// Persisted values are explicit and independent of Dart enum names/order.
enum ProgressMediaType {
  photoSet('photo_set'),
  video('video'),
  both('both');

  const ProgressMediaType(this.dbValue);
  final String dbValue;

  static ProgressMediaType fromDb(String value) =>
      values.firstWhere((entry) => entry.dbValue == value);
}

enum ProgressMediaItemType {
  photo('photo'),
  video('video'),
  videoFrame('video_frame'),
  thumbnail('thumbnail');

  const ProgressMediaItemType(this.dbValue);
  final String dbValue;

  static ProgressMediaItemType fromDb(String value) =>
      values.firstWhere((entry) => entry.dbValue == value);

  bool get isOriginal => this == photo || this == video;
}

enum ProgressMediaPose {
  front('front'),
  back('back'),
  leftSide('left_side'),
  rightSide('right_side'),
  allSidesVideo('all_sides_video'),
  unknown('unknown');

  const ProgressMediaPose(this.dbValue);
  final String dbValue;

  static ProgressMediaPose fromDb(String value) =>
      values.firstWhere((entry) => entry.dbValue == value);
}

enum ProgressMediaSource {
  camera('camera'),
  gallery('gallery'),
  extractedFrame('extracted_frame'),
  generatedThumbnail('generated_thumbnail');

  const ProgressMediaSource(this.dbValue);
  final String dbValue;

  static ProgressMediaSource fromDb(String value) =>
      values.firstWhere((entry) => entry.dbValue == value);
}

enum ProgressReminderCadence {
  twoWeeks('two_weeks'),
  monthly('monthly'),
  threeMonths('three_months'),
  off('off');

  const ProgressReminderCadence(this.dbValue);
  final String dbValue;

  static ProgressReminderCadence fromDb(String value) =>
      values.firstWhere((entry) => entry.dbValue == value);
}

/// Safe failures never retain SQL, filesystem paths, notes or platform errors.
enum ProgressMediaFailure implements Exception {
  invalid,
  missing,
  conflict,
  unavailable;

  String get message => switch (this) {
    invalid => AppErrorStrings.progressMediaInvalid,
    missing => AppErrorStrings.progressMediaMissing,
    conflict => AppErrorStrings.progressMediaConflict,
    unavailable => AppErrorStrings.progressMediaUnavailable,
  };
}

/// Immutable values, copied at save time rather than linked to mutable history.
class ProgressMeasurementSnapshot {
  const ProgressMeasurementSnapshot({
    required this.measuredAt,
    this.bodyweightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
  });

  final DateTime measuredAt;
  final double? bodyweightKg;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;

  Iterable<double?> get values => [
    bodyweightKg,
    waistCm,
    chestCm,
    hipsCm,
    leftArmCm,
    rightArmCm,
    leftThighCm,
    rightThighCm,
  ];
}

/// A file already staged by the local capture/import service, awaiting save.
/// Sizes come from the sandbox file store rather than caller-supplied values.
class ProgressMediaFileDraft {
  const ProgressMediaFileDraft({
    required this.id,
    required this.type,
    required this.pose,
    required this.source,
    required this.relativePath,
    this.sourceMediaItemId,
    this.durationSeconds,
    this.width,
    this.height,
    this.capturedAt,
  });

  final String id;
  final ProgressMediaItemType type;
  final ProgressMediaPose pose;
  final ProgressMediaSource source;
  final String relativePath;
  final String? sourceMediaItemId;
  final int? durationSeconds;
  final int? width;
  final int? height;
  final DateTime? capturedAt;
}

/// Private local save input. Never serialize this into exports or AI payloads.
class ProgressMediaSessionDraft {
  ProgressMediaSessionDraft({
    required this.id,
    required this.capturedAt,
    required Iterable<ProgressMediaFileDraft> items,
    this.bodyweightKg,
    this.measurements,
    this.notes,
  }) : items = List.unmodifiable(items);

  final String id;
  final DateTime capturedAt;
  final List<ProgressMediaFileDraft> items;
  final double? bodyweightKg;
  final ProgressMeasurementSnapshot? measurements;
  final String? notes;
}

/// Local timeline metadata. Deliberately has no serialization API.
class ProgressMediaSession {
  const ProgressMediaSession({
    required this.id,
    required this.capturedAt,
    required this.mediaType,
    required this.isBaseline,
    required this.isCompletePoseSet,
    required this.storageSizeBytes,
    required this.createdAt,
    required this.updatedAt,
    this.bodyweightKg,
    this.notes,
    this.reminderCadenceAtCapture,
  });

  final String id;
  final DateTime capturedAt;
  final ProgressMediaType mediaType;
  final bool isBaseline;
  final bool isCompletePoseSet;
  final int storageSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? bodyweightKg;
  final String? notes;
  final ProgressReminderCadence? reminderCadenceAtCapture;
}

/// A recoverable missing-file state keeps session metadata available locally.
class ProgressMediaItem {
  const ProgressMediaItem({
    required this.file,
    required this.fileSizeBytes,
    required this.isFileAvailable,
    this.thumbnailRelativePath,
  });

  final ProgressMediaFileDraft file;
  final int fileSizeBytes;
  final bool isFileAvailable;
  final String? thumbnailRelativePath;
}

class ProgressMediaSessionDetails {
  ProgressMediaSessionDetails({
    required this.session,
    required Iterable<ProgressMediaItem> items,
    this.measurements,
  }) : items = List.unmodifiable(items);

  final ProgressMediaSession session;
  final List<ProgressMediaItem> items;
  final ProgressMeasurementSnapshot? measurements;
}

class ProgressMediaPosePair {
  const ProgressMediaPosePair({
    required this.pose,
    required this.first,
    required this.second,
  });

  final ProgressMediaPose pose;
  final ProgressMediaItem first;
  final ProgressMediaItem second;
}

/// No platform scheduling is performed by the storage foundation.
class ProgressMediaReminderState {
  const ProgressMediaReminderState({
    this.enabled = false,
    this.cadence,
    this.lastSessionAt,
    this.nextReminderAt,
    this.lastPromptedAt,
  });

  final bool enabled;
  final ProgressReminderCadence? cadence;
  final DateTime? lastSessionAt;
  final DateTime? nextReminderAt;
  final DateTime? lastPromptedAt;

  bool get canPrompt => lastSessionAt != null && lastPromptedAt == null;
}

class ProgressMediaStorageUsage {
  const ProgressMediaStorageUsage({
    required this.sessionCount,
    required this.fileCount,
    required this.totalBytes,
  });

  final int sessionCount;
  final int fileCount;
  final int totalBytes;
}
