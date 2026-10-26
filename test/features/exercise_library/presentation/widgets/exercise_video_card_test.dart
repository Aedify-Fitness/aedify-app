import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _VideoCardHarness {
  _VideoCardHarness._();

  static const video = ExerciseDetailVideoViewData(
    url: 'https://example.com/v.mp4',
    angle: ExerciseVideoAngle.front,
    gender: ExerciseVideoGender.male,
    ogImageUrl: null,
  );

  static Widget build({
    ExerciseDetailVideoViewData video = _VideoCardHarness.video,
    ExerciseVideoPlaybackState playbackState = ExerciseVideoPlaybackState.idle,
    VoidCallback? onRetry,
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseVideoCard(
              video: video,
              playbackState: playbackState,
              onRetry: onRetry ?? () {},
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ExerciseVideoCard', () {
    testWidgets('places descriptive metadata below the preview visual', (
      tester,
    ) async {
      await tester.pumpWidget(_VideoCardHarness.build());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideoPreview), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      final visual = find.byKey(
        const ValueKey<String>(
          'exercise_video_visual_https://example.com/v.mp4',
        ),
      );
      final metadata = find.byKey(
        const ValueKey<String>(
          'exercise_video_metadata_https://example.com/v.mp4',
        ),
      );
      expect(
        tester.getTopLeft(metadata).dy,
        greaterThan(tester.getBottomLeft(visual).dy),
      );
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('unknown angle keeps the video available as a preview', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoCardHarness.build(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: null,
            gender: ExerciseVideoGender.male,
            ogImageUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideoPreview), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text(AppStrings.videoUnavailable), findsNothing);
    });

    testWidgets('shows recovery action below a failed preview', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _VideoCardHarness.build(
          playbackState: ExerciseVideoPlaybackState.failed,
          onRetry: () => retried = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseVideoLoadFailed), findsOneWidget);
      await tester.tap(find.text(AppStrings.retryVideo));
      expect(retried, isTrue);
    });

    testWidgets('shows thumbnail while keeping metadata outside it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoCardHarness.build(
          video: const ExerciseDetailVideoViewData(
            url: 'https://example.com/v.mp4',
            angle: ExerciseVideoAngle.front,
            gender: ExerciseVideoGender.male,
            ogImageUrl: 'https://example.com/thumb.jpg',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
    });

    testWidgets('shows playback loading status', (tester) async {
      await tester.pumpWidget(
        _VideoCardHarness.build(
          playbackState: ExerciseVideoPlaybackState.loading,
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.exerciseVideoPreview), findsOneWidget);
    });

    for (final brightness in Brightness.values) {
      testWidgets('failed preview fits 320px with 2x text in $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _VideoCardHarness.build(
            playbackState: ExerciseVideoPlaybackState.failed,
            textScale: 2,
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final retryButton = find.widgetWithText(
          FilledButton,
          AppStrings.retryVideo,
        );
        expect(
          tester.getSize(retryButton).height,
          greaterThanOrEqualTo(AppExerciseDetailTokens.controlSize),
        );
      });
    }
  });
}
