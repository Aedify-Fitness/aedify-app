import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseVideoStateController
    extends Notifier<Map<String, ExerciseVideoPlaybackState>> {
  static final _logger = AppLogger(name: 'ExerciseVideoStateController');

  @override
  Map<String, ExerciseVideoPlaybackState> build() => {};

  void markLoading(String videoUrl) {
    _logger.debug('loadVideo — url: $videoUrl');
    state = {...state, videoUrl: ExerciseVideoPlaybackState.loading};
  }

  void markReady(String videoUrl) {
    _logger.debug('loadVideo — ready: $videoUrl');
    state = {...state, videoUrl: ExerciseVideoPlaybackState.ready};
  }

  void markFailed(String videoUrl) {
    _logger.debug('loadVideo — failed: $videoUrl');
    state = {...state, videoUrl: ExerciseVideoPlaybackState.failed};
  }

  void reset(String videoUrl) {
    state = {...state, videoUrl: ExerciseVideoPlaybackState.idle};
  }

  void resetAll() {
    state = {};
  }
}
