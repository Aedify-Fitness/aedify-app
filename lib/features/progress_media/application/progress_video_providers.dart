import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/data/progress_video_picker.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_file_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_playback.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class ProgressVideoProviders {
  static final limitsProvider = Provider<ProgressVideoLimits>(
    (ref) => const ProgressVideoLimits(),
  );
  static final pickerProvider = Provider<ProgressVideoPicker>(
    (ref) => ImagePickerProgressVideoPicker(
      files: ref.watch(AppProviders.localFileStoreProvider),
    ),
  );
  static final metadataProvider = Provider<ProgressVideoMetadataService>(
    (ref) => NativeProgressVideoMetadataService(
      ref.watch(AppProviders.localFileStoreProvider),
    ),
  );
  static final filesProvider = Provider<ProgressVideoFileService>(
    (ref) => ProgressVideoFileService(
      files: ref.watch(AppProviders.localFileStoreProvider),
      drafts: ref.watch(ProgressPhotoProviders.filesProvider),
      metadata: ref.watch(metadataProvider),
      newId: ref.watch(ProgressPhotoProviders.idProvider),
    ),
  );
  static final previewProvider = FutureProvider.autoDispose
      .family<ProgressVideoPlayback, String>((ref, path) async {
        final playback = await ProgressVideoPlayback.create(
          ref.watch(AppProviders.localFileStoreProvider),
          path,
        );
        if (!ref.mounted) {
          await playback.dispose();
          throw ProgressVideoFailure.preview;
        }
        ref.onDispose(
          () => unawaited(playback.dispose().catchError((Object _) {})),
        );
        return playback;
      }, retry: (_, _) => null);
}
