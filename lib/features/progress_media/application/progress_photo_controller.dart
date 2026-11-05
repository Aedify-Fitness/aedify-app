import 'dart:async';

import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
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
    ProgressPhotoFailure? failure = recovery.failure;
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
    return ProgressPhotoState(
      units: units,
      recovered: recovered,
      failure: failure,
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
            failure: error is ProgressPhotoFailure
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
