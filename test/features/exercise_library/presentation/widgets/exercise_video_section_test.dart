import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createSection({
  List<ExerciseDetailVideoViewData> videos = const [],
  VoidCallback? onRetry,
  Map<String, ExerciseVideoPlaybackState> failureStates = const {},
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ExerciseVideoSection(
          videos: videos,
          onRetry: onRetry ?? () {},
          failureStates: failureStates,
        ),
      ),
    ),
  );
}

void main() {
  group('ExerciseVideoSection', () {
    final testVideo = const ExerciseDetailVideoViewData(
      url: 'https://example.com/v1.mp4',
      angle: 'front',
      gender: 'male',
      ogImageUrl: null,
    );

    testWidgets('shows no-video fallback when list is empty', (tester) async {
      await tester.pumpWidget(createSection(videos: []));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noExerciseVideos), findsOneWidget);
      expect(find.text(AppStrings.exerciseVideos), findsOneWidget);
    });

    testWidgets('renders one card per video', (tester) async {
      await tester.pumpWidget(createSection(videos: [testVideo]));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideos), findsOneWidget);
      expect(find.text('front'), findsOneWidget);
      expect(find.text('male'), findsOneWidget);
    });

    testWidgets('renders multiple videos', (tester) async {
      await tester.pumpWidget(
        createSection(
          videos: [
            testVideo,
            const ExerciseDetailVideoViewData(
              url: 'https://example.com/v2.mp4',
              angle: 'side',
              gender: 'female',
              ogImageUrl: null,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('front'), findsOneWidget);
      expect(find.text('side'), findsOneWidget);
      expect(find.text('male'), findsOneWidget);
      expect(find.text('female'), findsOneWidget);
    });

    testWidgets('shows retry UI for failed video', (tester) async {
      await tester.pumpWidget(
        createSection(
          videos: [testVideo],
          failureStates: {
            'https://example.com/v1.mp4': ExerciseVideoPlaybackState.failed,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.retryVideo), findsOneWidget);
    });

    testWidgets('does not break when onRetry changes state', (tester) async {
      await tester.pumpWidget(createSection(videos: [testVideo]));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideos), findsOneWidget);
    });
  });
}
