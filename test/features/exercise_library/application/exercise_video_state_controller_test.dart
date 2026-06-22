import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_video_state_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseVideoStateController', () {
    late ProviderContainer container;
    late ExerciseVideoStateController controller;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          AppProviders.exerciseVideoStateControllerProvider.overrideWith(
            () => ExerciseVideoStateController(),
          ),
        ],
      );
      controller = container.read(
        AppProviders.exerciseVideoStateControllerProvider.notifier,
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      expect(
        container.read(AppProviders.exerciseVideoStateControllerProvider),
        equals(<String, ExerciseVideoPlaybackState>{}),
      );
    });

    test('markLoading sets loading state', () {
      controller.markLoading('https://example.com/v1.mp4');

      final state = container.read(
        AppProviders.exerciseVideoStateControllerProvider,
      );
      expect(
        state['https://example.com/v1.mp4'],
        ExerciseVideoPlaybackState.loading,
      );
    });

    test('markReady sets ready state', () {
      controller.markReady('https://example.com/v1.mp4');

      final state = container.read(
        AppProviders.exerciseVideoStateControllerProvider,
      );
      expect(
        state['https://example.com/v1.mp4'],
        ExerciseVideoPlaybackState.ready,
      );
    });

    test('markFailed sets failed state', () {
      controller.markFailed('https://example.com/v1.mp4');

      final state = container.read(
        AppProviders.exerciseVideoStateControllerProvider,
      );
      expect(
        state['https://example.com/v1.mp4'],
        ExerciseVideoPlaybackState.failed,
      );
    });

    test('reset returns video to idle', () {
      controller.markFailed('https://example.com/v1.mp4');
      controller.reset('https://example.com/v1.mp4');

      final state = container.read(
        AppProviders.exerciseVideoStateControllerProvider,
      );
      expect(
        state['https://example.com/v1.mp4'],
        ExerciseVideoPlaybackState.idle,
      );
    });

    test('resetAll clears all tracked states', () {
      controller.markLoading('https://example.com/v1.mp4');
      controller.markFailed('https://example.com/v2.mp4');
      controller.resetAll();

      expect(
        container.read(AppProviders.exerciseVideoStateControllerProvider),
        equals(<String, ExerciseVideoPlaybackState>{}),
      );
    });
  });
}
