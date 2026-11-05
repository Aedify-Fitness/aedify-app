import 'dart:async';

import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

/// Owns player initialization/lifecycle outside presentation; playback starts muted.
class ProgressVideoPlayback with WidgetsBindingObserver {
  ProgressVideoPlayback._(this.player);
  final VideoPlayerController player;

  static Future<ProgressVideoPlayback> create(
    LocalFileStore files,
    String path,
  ) async {
    VideoPlayerController? player;
    try {
      final file = await files.managedFile(path);
      player = VideoPlayerController.file(file);
      await player.initialize().timeout(ProgressVideoLimits.probeTimeout);
      await player.setVolume(0);
      final playback = ProgressVideoPlayback._(player);
      WidgetsBinding.instance.addObserver(playback);
      return playback;
    } catch (_) {
      await player?.dispose();
      throw ProgressVideoFailure.preview;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(player.pause().catchError((Object _) {}));
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await player.dispose();
  }
}
