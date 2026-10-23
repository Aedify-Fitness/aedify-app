import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseVideoSection extends StatefulWidget {
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
  State<ExerciseVideoSection> createState() => _ExerciseVideoSectionState();
}

class _ExerciseVideoSectionState extends State<ExerciseVideoSection> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void didUpdateWidget(ExerciseVideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousUrl = _page < oldWidget.videos.length
        ? oldWidget.videos[_page].url
        : null;
    final matchingPage = widget.videos.indexWhere(
      (video) => video.url == previousUrl,
    );
    final nextPage = matchingPage >= 0 ? matchingPage : 0;
    if (nextPage == _page) return;

    _page = nextPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) _controller.jumpToPage(_page);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPage(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: AppDurations.navigationSelection,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const _NoVideoPreview(
        key: Key('exercise_detail_video_empty_state'),
      );
    }

    final video = widget.videos[_page];
    final state =
        widget.failureStates[video.url] ?? ExerciseVideoPlaybackState.idle;

    return Semantics(
      container: true,
      label: AppStrings.exerciseVideos,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            key: const Key('exercise_video_carousel'),
            aspectRatio: AppExerciseDetailTokens.mediaAspectRatio,
            child: PageView.builder(
              controller: _controller,
              allowImplicitScrolling: true,
              itemCount: widget.videos.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final item = widget.videos[index];
                return ExerciseVideoCard(
                  key: ValueKey<String>('exercise_video_${item.url}'),
                  video: item,
                  playbackState:
                      widget.failureStates[item.url] ??
                      ExerciseVideoPlaybackState.idle,
                  onRetry: widget.onRetry,
                  showDetails: false,
                );
              },
            ),
          ),
          AppWhiteSpace.hControlGap,
          ExerciseVideoCaption(
            video: video,
            playbackState: state,
            onRetry: widget.onRetry,
          ),
          if (widget.videos.length > 1) ...[
            AppWhiteSpace.hSm,
            _VideoPageControls(
              page: _page,
              count: widget.videos.length,
              onPrevious: _page > 0 ? () => _showPage(_page - 1) : null,
              onNext: _page < widget.videos.length - 1
                  ? () => _showPage(_page + 1)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoPageControls extends StatelessWidget {
  const _VideoPageControls({
    required this.page,
    required this.count,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int count;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.brightnessOf(context) == Brightness.dark
        ? AppTextStylesDark.labelSm
        : AppTextStyles.labelSm;
    return Row(
      children: [
        _VideoPageButton(
          tooltip: AppStrings.exercisePreviousVideo,
          iconAsset: OutlinedSvgAssets.chevronLeft,
          onPressed: onPrevious,
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              AppStrings.exerciseVideoPosition(page + 1, count),
              textAlign: TextAlign.center,
              style: labelStyle.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        _VideoPageButton(
          tooltip: AppStrings.exerciseNextVideo,
          iconAsset: OutlinedSvgAssets.chevronRight,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _VideoPageButton extends StatelessWidget {
  const _VideoPageButton({
    required this.tooltip,
    required this.iconAsset,
    required this.onPressed,
  });

  final String tooltip;
  final String iconAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppExerciseDetailTokens.controlSize),
        backgroundColor: context.colorScheme.surfaceContainerLow,
        disabledBackgroundColor: context.colorScheme.surfaceContainerLow,
        foregroundColor: context.colorScheme.onSurface,
        disabledForegroundColor: context.colorScheme.outline,
      ),
      icon: SvgPicture.asset(
        iconAsset,
        width: AppSizing.iconXs,
        height: AppSizing.iconXs,
        excludeFromSemantics: true,
        matchTextDirection: true,
        colorFilter: ColorFilter.mode(
          onPressed == null
              ? context.colorScheme.outline
              : context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _NoVideoPreview extends StatelessWidget {
  const _NoVideoPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.brightnessOf(context) == Brightness.dark
        ? AppTextStylesDark.bodySm
        : AppTextStyles.bodySm;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.videoCameraSlash,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            excludeFromSemantics: true,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noExerciseVideos,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
