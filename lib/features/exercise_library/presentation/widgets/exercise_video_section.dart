import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ExerciseVideoSection extends StatelessWidget {
  const ExerciseVideoSection({
    super.key,
    required this.videos,
    required this.onRetry,
    required this.failureStates,
  });

  final List<ExerciseDetailVideoViewData> videos;
  final VoidCallback onRetry;
  final Map<String, ExerciseVideoPlaybackState> failureStates;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return AppEmptyState(
        key: const Key('exercise_detail_video_empty_state'),
        iconAsset: OutlinedSvgAssets.videoCameraSlash,
        title: AppStrings.noExerciseVideos,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (!availableWidth.isFinite || availableWidth <= 0) {
          return const SizedBox.shrink();
        }
        final cardWidth =
            availableWidth < AppExerciseDetailTokens.videoCardWidth
            ? availableWidth
            : AppExerciseDetailTokens.videoCardWidth;
        final desiredPageExtent =
            cardWidth + AppExerciseDetailTokens.videoCardGap;
        final itemGap = desiredPageExtent > availableWidth
            ? availableWidth - cardWidth
            : AppExerciseDetailTokens.videoCardGap;
        final pageExtent = cardWidth + itemGap;
        final viewportFraction = pageExtent / availableWidth;

        return Semantics(
          container: true,
          label: AppStrings.exerciseVideos,
          child: SizedBox(
            key: const Key('exercise_video_carousel'),
            height: cardWidth / AppExerciseDetailTokens.mediaAspectRatio,
            child: _VideoCarousel(
              videos: videos,
              failureStates: failureStates,
              onRetry: onRetry,
              cardWidth: cardWidth,
              itemGap: itemGap,
              viewportFraction: viewportFraction,
            ),
          ),
        );
      },
    );
  }
}

class _VideoCarousel extends StatefulWidget {
  const _VideoCarousel({
    required this.videos,
    required this.failureStates,
    required this.onRetry,
    required this.cardWidth,
    required this.itemGap,
    required this.viewportFraction,
  });

  final List<ExerciseDetailVideoViewData> videos;
  final Map<String, ExerciseVideoPlaybackState> failureStates;
  final VoidCallback onRetry;
  final double cardWidth;
  final double itemGap;
  final double viewportFraction;

  @override
  State<_VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<_VideoCarousel> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
  }

  @override
  void didUpdateWidget(_VideoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportFraction != widget.viewportFraction) {
      _controller.dispose();
      _controller = PageController(viewportFraction: widget.viewportFraction);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      padEnds: false,
      pageSnapping: true,
      allowImplicitScrolling: true,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final card = ExerciseVideoCard(
          key: ValueKey<String>('exercise_video_${video.url}'),
          video: video,
          playbackState:
              widget.failureStates[video.url] ??
              ExerciseVideoPlaybackState.idle,
          onRetry: widget.onRetry,
          width: widget.cardWidth,
        );

        return Align(
          alignment: Alignment.centerLeft,
          child: index == widget.videos.length - 1
              ? card
              : Padding(
                  padding: EdgeInsets.only(right: widget.itemGap),
                  child: card,
                ),
        );
      },
    );
  }
}
