import 'dart:async';

import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns a reviewable ephemeral draft; only explicit Save persists metadata.
class ProgressPhotoController extends AsyncNotifier<ProgressPhotoState> {
  late String _sessionId;
  late DateTime _capturedAt;
  late ProgressPhotoFileService _files;

  @override
  Future<ProgressPhotoState> build() async {
    _sessionId = ref.read(ProgressPhotoProviders.idProvider)();
    _capturedAt = ref.read(ProgressMediaProviders.clockProvider)();
    _files = ref.read(ProgressPhotoProviders.filesProvider);
    final sessionId = _sessionId;
    final files = _files;
    ref.onDispose(() {
      unawaited(files.discard(sessionId).catchError((Object _) {}));
    });
    final units = await ref.read(ProgressPhotoProviders.unitsProvider.future);
    final recovery = await ref.read(
      ProgressPhotoProviders.recoveryProvider.future,
    );
    if (!ref.mounted) return ProgressPhotoState(units: units);
    final photo = recovery.photo;
    PreparedProgressPhoto? recovered;
    ProgressMediaDraftFailure? failure = recovery.failure;
    if (photo != null) {
      // Recovery has no pose/source metadata. The user must assign both.
      try {
        recovered = await _files.prepare(
          sessionId: sessionId,
          pose: ProgressMediaPose.unknown,
          source: ProgressMediaSource.gallery,
          selection: photo,
        );
      } on ProgressPhotoFailure catch (error) {
        failure = error;
      }
      if (!ref.mounted) {
        if (recovered != null) await files.remove(recovered);
        return ProgressPhotoState(units: units);
      }
      ref.read(ProgressPhotoProviders.recoveryProvider.notifier).consume();
    }
    PreparedProgressVideo? recoveredVideo;
    final video = recovery.video;
    if (video != null) {
      try {
        recoveredVideo = await ref
            .read(ProgressVideoProviders.filesProvider)
            .prepare(
              sessionId: sessionId,
              selection: video,
              source: ProgressMediaSource.gallery,
              limits: ref.read(ProgressVideoProviders.limitsProvider),
            );
      } on ProgressMediaDraftFailure catch (error) {
        failure = error;
      }
      if (!ref.mounted) {
        if (recoveredVideo != null) await files.remove(recoveredVideo);
        return ProgressPhotoState(units: units);
      }
      ref.read(ProgressPhotoProviders.recoveryProvider.notifier).consume();
    }
    return ProgressPhotoState(
      units: units,
      recovered: recovered,
      recoveredVideo: recoveredVideo,
      videoLimitSeconds: ref
          .read(ProgressVideoProviders.limitsProvider)
          .maxDuration
          .inSeconds,
      failure: failure,
    );
  }

  ProgressVideoLimits _videoLimits(int seconds) => ProgressVideoLimits(
    maxDuration: Duration(seconds: seconds),
    maxBytes: ref.read(ProgressVideoProviders.limitsProvider).maxBytes,
  );

  Future<void> pickVideo(ProgressMediaSource source) async {
    final current = state.asData?.value;
    if (current == null || current.busy || current.saved) return;
    state = AsyncData(current.copyWith(busy: true));
    PreparedProgressVideo? prepared;
    try {
      final limits = _videoLimits(current.videoLimitSeconds);
      final files = ref.read(ProgressVideoProviders.filesProvider);
      final selection = await ref
          .read(ProgressVideoProviders.pickerProvider)
          .pick(source, limits);
      if (selection != null) {
        prepared = await files.prepare(
          sessionId: _sessionId,
          selection: selection,
          source: source,
          limits: limits,
        );
      }
      if (!ref.mounted) {
        if (prepared != null) await _files.remove(prepared);
        return;
      }
      if (prepared == null) {
        state = AsyncData(current.copyWith(cancelled: true));
        return;
      }
      ProgressMediaDraftFailure? failure;
      if (current.video != null) {
        try {
          await _files.remove(current.video!);
        } catch (_) {
          failure = ProgressPhotoFailure.cleanup;
        }
      }
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            video: prepared,
            videoPreviewReady: false,
            failure: failure,
          ),
        );
      }
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            failure: error is ProgressMediaDraftFailure
                ? error
                : ProgressVideoFailure.storage,
          ),
        );
      }
    }
  }

  Future<void> removeVideo() async {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.saved ||
        current.video == null) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true));
    try {
      await _files.remove(current.video!);
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(clearVideo: true, videoPreviewReady: false),
        );
      }
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(failure: ProgressPhotoFailure.cleanup),
        );
      }
    }
  }

  void setVideoLimit(int seconds) {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.saved ||
        !const [30, 60].contains(seconds) ||
        seconds >
            ref
                .read(ProgressVideoProviders.limitsProvider)
                .maxDuration
                .inSeconds) {
      return;
    }
    if (current.video != null &&
        current.video!.duration > Duration(seconds: seconds)) {
      state = AsyncData(
        current.copyWith(
          videoLimitSeconds: seconds,
          failure: ProgressVideoFailure.tooLong,
        ),
      );
      return;
    }
    state = AsyncData(current.copyWith(videoLimitSeconds: seconds));
  }

  void videoPreviewResult(String id, {required bool ready}) {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.saved ||
        current.video?.original.id != id) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        videoPreviewReady: ready,
        failure: ready ? current.failure : ProgressVideoFailure.preview,
      ),
    );
  }

  void assignRecoveredVideo(ProgressMediaSource source) {
    final current = state.asData?.value;
    final video = current?.recoveredVideo;
    if (current == null ||
        video == null ||
        current.busy ||
        (source != ProgressMediaSource.camera &&
            source != ProgressMediaSource.gallery)) {
      return;
    }
    final original = video.original;
    state = AsyncData(
      current.copyWith(
        clearRecoveredVideo: true,
        videoPreviewReady: false,
        video: PreparedProgressVideo(
          original: ProgressMediaFileDraft(
            id: original.id,
            type: original.type,
            pose: original.pose,
            source: source,
            relativePath: original.relativePath,
            durationSeconds: original.durationSeconds,
            width: original.width,
            height: original.height,
          ),
          originalStagingPath: video.originalStagingPath,
          duration: video.duration,
          thumbnail: video.thumbnail,
          thumbnailStagingPath: video.thumbnailStagingPath,
          preview: video.preview,
        ),
      ),
    );
  }

  Future<void> pick(ProgressMediaPose pose, ProgressMediaSource source) async {
    final current = state.asData?.value;
    if (current == null || current.busy || current.saved) return;
    state = AsyncData(current.copyWith(busy: true));
    PreparedProgressPhoto? prepared;
    try {
      final selection = await ref
          .read(ProgressPhotoProviders.pickerProvider)
          .pick(source);
      if (selection != null) {
        prepared = await _files.prepare(
          sessionId: _sessionId,
          pose: pose,
          source: source,
          selection: selection,
        );
      }
      if (!ref.mounted) {
        if (prepared != null) await _files.remove(prepared);
        return;
      }
      if (prepared == null) {
        state = AsyncData(current.copyWith(cancelled: true));
        return;
      }
      final old = current.photos[pose];
      if (old != null) {
        try {
          await _files.remove(old);
        } catch (_) {
          if (ref.mounted) {
            state = AsyncData(
              current.copyWith(
                photos: {...current.photos, pose: prepared},
                failure: ProgressPhotoFailure.cleanup,
              ),
            );
          }
          return;
        }
      }
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(photos: {...current.photos, pose: prepared}),
        );
      }
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            failure: error is ProgressPhotoFailure
                ? error
                : ProgressPhotoFailure.storage,
          ),
        );
      }
    }
  }

  Future<void> remove(ProgressMediaPose pose) async {
    final current = state.asData?.value;
    if (current == null || current.busy || current.saved) return;
    final photo = current.photos[pose];
    if (photo == null) return;
    state = AsyncData(current.copyWith(busy: true));
    try {
      await _files.remove(photo);
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(photos: {...current.photos}..remove(pose)),
        );
      }
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(failure: ProgressPhotoFailure.cleanup),
        );
      }
    }
  }

  void assignRecovered(ProgressMediaPose pose, ProgressMediaSource source) {
    final current = state.asData?.value;
    final photo = current?.recovered;
    if (current == null || photo == null || current.busy) return;
    final original = photo.original;
    final thumbnail = photo.thumbnail;
    final assigned = PreparedProgressPhoto(
      original: ProgressMediaFileDraft(
        id: original.id,
        type: original.type,
        pose: pose,
        source: source,
        relativePath: original.relativePath,
        width: original.width,
        height: original.height,
      ),
      originalStagingPath: photo.originalStagingPath,
      preview: photo.preview,
      thumbnailStagingPath: photo.thumbnailStagingPath,
      thumbnail: thumbnail == null
          ? null
          : ProgressMediaFileDraft(
              id: thumbnail.id,
              type: thumbnail.type,
              pose: pose,
              source: thumbnail.source,
              relativePath: thumbnail.relativePath,
              sourceMediaItemId: original.id,
            ),
    );
    state = AsyncData(
      current.copyWith(
        photos: {...current.photos, pose: assigned},
        clearRecovered: true,
      ),
    );
  }

  void updateFields({String? notes, String? bodyweight}) {
    final current = state.asData?.value;
    if (current == null || current.busy || current.saved) return;
    state = AsyncData(current.copyWith(notes: notes, bodyweight: bodyweight));
  }

  Future<bool> save() async {
    final current = state.asData?.value;
    if (current == null || !current.canSave) return false;
    final text = current.bodyweight.trim();
    final input = text.isEmpty
        ? null
        : double.tryParse(text.replaceAll(',', '.'));
    if (text.isNotEmpty && (input == null || !input.isFinite || input <= 0)) {
      state = AsyncData(
        current.copyWith(failure: ProgressPhotoFailure.bodyweight),
      );
      return false;
    }
    state = AsyncData(current.copyWith(busy: true));
    try {
      await _files.save(
        sessionId: _sessionId,
        capturedAt: _capturedAt,
        photos: current.photos.values,
        video: current.video,
        videoLimits: _videoLimits(current.videoLimitSeconds),
        notes: current.notes.trim().isEmpty ? null : current.notes.trim(),
        bodyweightKg: input == null
            ? null
            : current.units.toCanonicalWeight(input),
      );
      if (ref.mounted) state = AsyncData(current.copyWith(saved: true));
      return true;
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            failure: error is ProgressMediaDraftFailure
                ? error
                : ProgressPhotoFailure.storage,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> discard() async {
    final current = state.asData?.value;
    if (current == null) return true;
    if (current.busy) return false;
    state = AsyncData(current.copyWith(busy: true));
    try {
      await _files.discard(_sessionId);
      if (ref.mounted) {
        state = AsyncData(ProgressPhotoState(units: current.units));
      }
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(failure: ProgressPhotoFailure.cleanup),
        );
      }
      return false;
    }
  }
}
