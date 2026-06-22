import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createCard({
  ExerciseDetailVideoViewData? video,
  ExerciseVideoPlaybackState playbackState = ExerciseVideoPlaybackState.idle,
  VoidCallback? onRetry,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ExerciseVideoCard(
        video:
            video ??
            const ExerciseDetailVideoViewData(
              url: 'https://example.com/v.mp4',
              angle: 'front',
              gender: 'male',
              ogImageUrl: 'https://example.com/thumb.jpg',
            ),
        playbackState: playbackState,
        onRetry: onRetry ?? () {},
      ),
    ),
  );
}

void main() {
  group('ExerciseVideoCard', () {
    testWidgets('renders metadata labels for angle and gender', (tester) async {
      await tester.pumpWidget(createCard());
      await tester.pumpAndSettle();

      expect(find.text('front'), findsOneWidget);
      expect(find.text('male'), findsOneWidget);
    });

    testWidgets('renders fallback text when angle is null', (tester) async {
      await tester.pumpWidget(
        createCard(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: null,
            gender: 'male',
            ogImageUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.videoUnavailable), findsOneWidget);
    });

    testWidgets('shows failed state fallback', (tester) async {
      await tester.pumpWidget(
        createCard(playbackState: ExerciseVideoPlaybackState.failed),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideoLoadFailed), findsWidgets);
    });

    testWidgets('shows retry button in failed state', (tester) async {
      await tester.pumpWidget(
        createCard(playbackState: ExerciseVideoPlaybackState.failed),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.retryVideo), findsOneWidget);
    });

    testWidgets('retry button fires callback', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        createCard(
          playbackState: ExerciseVideoPlaybackState.failed,
          onRetry: () => retried = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.retryVideo));
      expect(retried, isTrue);
    });
  });
}
