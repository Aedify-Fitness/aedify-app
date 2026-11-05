import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/data/progress_video_playback.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressVideoPanel extends StatelessWidget {
  const ProgressVideoPanel({
    super.key,
    required this.state,
    required this.onChoose,
    required this.onRemove,
    required this.onLimit,
    required this.onRecovered,
    required this.onPreview,
  });
  final ProgressPhotoState state;
  final VoidCallback onChoose;
  final VoidCallback onRemove;
  final ValueChanged<int> onLimit;
  final VoidCallback onRecovered;
  final void Function(String id, bool ready) onPreview;
  @override
  Widget build(BuildContext context) {
    final video = state.video;
    return ProgressPhotoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppStrings.progressVideoTitle,
            style: AppTextStyles.headlineMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(AppStrings.progressVideoHint),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final seconds in const [30, 60])
                ChoiceChip(
                  key: ValueKey('video_limit_$seconds'),
                  label: Text(AppStrings.progressVideoLimitLabel(seconds)),
                  selected: state.videoLimitSeconds == seconds,
                  onSelected: state.busy ? null : (_) => onLimit(seconds),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(AppStrings.progressVideoLimits),
          if (state.recoveredVideo != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              AppStrings.progressVideoRecovered,
              style: AppTextStyles.labelMd,
            ),
            const Text(AppStrings.progressVideoRecoveredHint),
            TextButton(
              onPressed: state.busy ? null : onRecovered,
              child: const Text(AppStrings.progressVideoReview),
            ),
          ],
          if (video != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.progressVideoDuration(video.original.durationSeconds!),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!state.busy)
              ProgressVideoPreview(
                key: ValueKey(video.original.id),
                video: video,
                onReady: (ready) => onPreview(video.original.id, ready),
              ),
            const SizedBox(height: AppSpacing.sm),
            const Text(AppStrings.progressVideoMuted),
            if (video.thumbnail == null)
              const Text(AppStrings.progressVideoThumbnailMissing),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('video_choose'),
                onPressed: state.busy ? null : onChoose,
                icon: const ProgressPhotoIcon(OutlinedSvgAssets.videoCamera),
                label: Text(
                  video == null
                      ? AppStrings.progressVideoAdd
                      : AppStrings.progressVideoReplace,
                ),
              ),
              if (video != null)
                TextButton(
                  key: const ValueKey('video_remove'),
                  onPressed: state.busy ? null : onRemove,
                  child: const Text(AppStrings.progressVideoRemove),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Only renders the application-owned player; no storage/platform APIs in widgets.
class ProgressVideoPreview extends ConsumerStatefulWidget {
  const ProgressVideoPreview({
    super.key,
    required this.video,
    required this.onReady,
  });
  final PreparedProgressVideo video;
  final ValueChanged<bool> onReady;
  @override
  ConsumerState<ProgressVideoPreview> createState() =>
      _ProgressVideoPreviewState();
}

class _ProgressVideoPreviewState extends ConsumerState<ProgressVideoPreview> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(
      ProgressVideoProviders.previewProvider(widget.video.originalStagingPath),
      (_, next) {
        if (!next.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onReady(next.hasValue && !next.hasError);
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProgressVideoProviders.previewProvider(
      widget.video.originalStagingPath,
    );
    final preview = ref.watch(provider);
    return preview.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () => SizedBox(
        height: AppProgressVideoTokens.previewHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.video.preview != null)
              Image.memory(widget.video.preview!, fit: BoxFit.contain),
            const CircularProgressIndicator(
              semanticsLabel: AppStrings.progressVideoPreparing,
            ),
          ],
        ),
      ),
      error: (_, _) => Column(
        children: [
          Text(ProgressVideoFailure.preview.message),
          TextButton(
            onPressed: () => ref.invalidate(provider),
            child: const Text(AppStrings.retryVideo),
          ),
        ],
      ),
      data: (handle) => _ProgressVideoPlayer(
        handle: handle,
        onFailure: () => widget.onReady(false),
        onRetry: () => ref.invalidate(provider),
      ),
    );
  }
}

class _ProgressVideoPlayer extends StatefulWidget {
  const _ProgressVideoPlayer({
    super.key,
    required this.handle,
    required this.onFailure,
    required this.onRetry,
    this.failureMessage = AppErrorStrings.progressVideoPreview,
  });
  final ProgressVideoPlayback handle;
  final VoidCallback onFailure;
  final VoidCallback onRetry;
  final String failureMessage;
  @override
  State<_ProgressVideoPlayer> createState() => _ProgressVideoPlayerState();
}

class _ProgressVideoPlayerState extends State<_ProgressVideoPlayer> {
  late final ChewieController _controls;
  bool _reportedFailure = false;
  @override
  void initState() {
    super.initState();
    widget.handle.player.addListener(_reportFailure);
    _controls = ChewieController(
      videoPlayerController: widget.handle.player,
      autoPlay: false,
      autoInitialize: false,
      allowFullScreen: false,
      showOptions: false,
      allowPlaybackSpeedChanging: false,
      errorBuilder: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.failureMessage),
            TextButton(
              onPressed: widget.onRetry,
              child: const Text(AppStrings.retryVideo),
            ),
          ],
        ),
      ),
    );
  }

  void _reportFailure() {
    if (!_reportedFailure && widget.handle.player.value.hasError) {
      _reportedFailure = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFailure();
      });
    }
  }

  @override
  void dispose() {
    widget.handle.player.removeListener(_reportFailure);
    _controls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppProgressVideoTokens.previewHeight,
    child: Chewie(controller: _controls),
  );
}

/// Saved originals use the same muted, lifecycle-owned player as draft previews.
class ProgressSavedVideoPlayer extends ConsumerWidget {
  const ProgressSavedVideoPlayer({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ProgressVideoProviders.previewProvider(path);
    return ref
        .watch(provider)
        .when(
          loading: () => const SizedBox(
            height: AppProgressVideoTokens.previewHeight,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Column(
            children: [
              const Text(AppErrorStrings.progressSavedVideo),
              TextButton(
                onPressed: () => ref.invalidate(provider),
                child: const Text(AppStrings.retryVideo),
              ),
            ],
          ),
          data: (handle) => _ProgressVideoPlayer(
            key: ObjectKey(handle),
            handle: handle,
            onFailure: () {},
            onRetry: () => ref.invalidate(provider),
            failureMessage: AppErrorStrings.progressSavedVideo,
          ),
        );
  }
}
