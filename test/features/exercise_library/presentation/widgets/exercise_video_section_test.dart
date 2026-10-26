import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _VideoSectionHarness {
  _VideoSectionHarness._();

  static const firstVideo = ExerciseDetailVideoViewData(
    url: 'https://example.com/v1.mp4',
    angle: ExerciseVideoAngle.front,
    gender: ExerciseVideoGender.male,
    ogImageUrl: null,
  );
  static const secondVideo = ExerciseDetailVideoViewData(
    url: 'https://example.com/v2.mp4',
    angle: ExerciseVideoAngle.side,
    gender: ExerciseVideoGender.female,
    ogImageUrl: null,
  );

  static Widget build({
    List<ExerciseDetailVideoViewData> videos = const [],
    VoidCallback? onRetry,
    Map<String, ExerciseVideoPlaybackState> failureStates = const {},
    double textScale = 1,
    Brightness brightness = Brightness.light,
    bool disableAnimations = false,
    bool highContrast = false,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
          highContrast: highContrast,
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: AppExerciseDetailTokens.maxContentWidth,
              child: SingleChildScrollView(
                child: ExerciseVideoSection(
                  videos: videos,
                  onRetry: onRetry ?? () {},
                  failureStates: failureStates,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ExerciseVideoSection', () {
    testWidgets('shows no-video fallback when list is empty', (tester) async {
      await tester.pumpWidget(_VideoSectionHarness.build());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noExerciseVideos), findsOneWidget);
    });

    testWidgets('single preview uses the content width without page controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoSectionHarness.build(videos: [_VideoSectionHarness.firstVideo]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseVideoCard), findsOneWidget);
      expect(find.byKey(const Key('exercise_video_carousel')), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
      expect(
        tester.getSize(find.byType(ExerciseVideoCard)).width,
        AppExerciseDetailTokens.maxContentWidth,
      );
    });

    testWidgets('paging updates the active caption and page position', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoSectionHarness.build(
          videos: [
            _VideoSectionHarness.firstVideo,
            _VideoSectionHarness.secondVideo,
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Side'), findsNothing);
      expect(find.text(AppStrings.exerciseVideoPosition(1, 2)), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Side'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Front'), findsNothing);
      expect(find.text(AppStrings.exerciseVideoPosition(2, 2)), findsOneWidget);
    });

    testWidgets(
      'accessible page controls respect boundaries and reduced motion',
      (tester) async {
        await tester.pumpWidget(
          _VideoSectionHarness.build(
            videos: [
              _VideoSectionHarness.firstVideo,
              _VideoSectionHarness.secondVideo,
            ],
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();
        final previous = find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.tooltip == AppStrings.exercisePreviousVideo,
        );
        final next = find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.tooltip == AppStrings.exerciseNextVideo,
        );
        expect(tester.widget<IconButton>(previous).onPressed, isNull);
        expect(
          tester.getSize(next).shortestSide,
          greaterThanOrEqualTo(AppExerciseDetailTokens.controlSize),
        );

        await tester.tap(next);
        await tester.pump();
        expect(find.text('Side'), findsOneWidget);
        expect(tester.widget<IconButton>(next).onPressed, isNull);
        expect(tester.widget<IconButton>(previous).onPressed, isNotNull);

        await tester.tap(previous);
        await tester.pump();
        expect(find.text('Front'), findsOneWidget);
      },
    );

    testWidgets('shows retry only for the active failed video', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        _VideoSectionHarness.build(
          videos: [
            _VideoSectionHarness.firstVideo,
            _VideoSectionHarness.secondVideo,
          ],
          failureStates: {
            _VideoSectionHarness.secondVideo.url:
                ExerciseVideoPlaybackState.failed,
          },
          onRetry: () => retries++,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.retryVideo), findsNothing);

      await tester.tap(find.byTooltip(AppStrings.exerciseNextVideo));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.retryVideo));
      expect(retries, 1);
    });

    testWidgets('keeps the selected video when the list is reordered', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoSectionHarness.build(
          videos: [
            _VideoSectionHarness.firstVideo,
            _VideoSectionHarness.secondVideo,
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.exerciseNextVideo));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _VideoSectionHarness.build(
          videos: [
            _VideoSectionHarness.secondVideo,
            _VideoSectionHarness.firstVideo,
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Side'), findsOneWidget);
      expect(find.text(AppStrings.exerciseVideoPosition(1, 2)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('removing the selected video returns to an available preview', (
      tester,
    ) async {
      await tester.pumpWidget(
        _VideoSectionHarness.build(
          videos: [
            _VideoSectionHarness.firstVideo,
            _VideoSectionHarness.secondVideo,
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.exerciseNextVideo));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _VideoSectionHarness.build(videos: [_VideoSectionHarness.firstVideo]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Front'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
        'high contrast preview fits its page at 320px/2x in $brightness',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            _VideoSectionHarness.build(
              videos: [
                _VideoSectionHarness.firstVideo,
                _VideoSectionHarness.secondVideo,
              ],
              textScale: 2,
              brightness: brightness,
              highContrast: true,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          final pageSize = tester.getSize(find.byType(PageView));
          final previewSize = tester.getSize(
            find.byKey(
              const ValueKey<String>(
                'exercise_video_visual_https://example.com/v1.mp4',
              ),
            ),
          );
          expect(previewSize, pageSize);
          expect(
            pageSize.width / pageSize.height,
            AppExerciseDetailTokens.mediaAspectRatio,
          );
        },
      );

      testWidgets('failed carousel fits 320px with 2x text in $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _VideoSectionHarness.build(
            videos: [
              _VideoSectionHarness.firstVideo,
              _VideoSectionHarness.secondVideo,
            ],
            failureStates: {
              _VideoSectionHarness.firstVideo.url:
                  ExerciseVideoPlaybackState.failed,
            },
            textScale: 2,
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(AppStrings.retryVideo), findsOneWidget);
        expect(find.byTooltip(AppStrings.exerciseNextVideo), findsOneWidget);
      });
    }
  });
}
