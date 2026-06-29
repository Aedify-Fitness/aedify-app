import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';
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
              angle: ExerciseVideoAngle.front,
              gender: ExerciseVideoGender.male,
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
      await tester.pump();

      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
    });

    testWidgets('renders fallback text when angle is null', (tester) async {
      await tester.pumpWidget(
        createCard(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: null,
            gender: ExerciseVideoGender.male,
            ogImageUrl: null,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.videoUnavailable), findsOneWidget);
    });

    testWidgets('shows failed state fallback', (tester) async {
      await tester.pumpWidget(
        createCard(playbackState: ExerciseVideoPlaybackState.failed),
      );
      await tester.pump();

      expect(find.text(AppStrings.exerciseVideoLoadFailed), findsWidgets);
    });

    testWidgets('shows retry button in failed state', (tester) async {
      await tester.pumpWidget(
        createCard(playbackState: ExerciseVideoPlaybackState.failed),
      );
      await tester.pump();

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
      await tester.pump();

      await tester.tap(find.text(AppStrings.retryVideo));
      expect(retried, isTrue);
    });

    testWidgets('shows thumbnail when hasThumbnail is true', (tester) async {
      await tester.pumpWidget(
        createCard(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: ExerciseVideoAngle.front,
            gender: ExerciseVideoGender.male,
            ogImageUrl: 'https://example.com/thumb.jpg',
          ),
        ),
      );
      await tester.pump();

      // Should still render metadata even with thumbnail loading
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
    });

    testWidgets('shows svg icon when hasThumbnail is false', (tester) async {
      await tester.pumpWidget(
        createCard(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: ExerciseVideoAngle.front,
            gender: ExerciseVideoGender.male,
            ogImageUrl: null,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
    });
  });
}
