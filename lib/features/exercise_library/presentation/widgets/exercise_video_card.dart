import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseVideoCard extends StatelessWidget {
  const ExerciseVideoCard({
    super.key,
    required this.video,
    required this.playbackState,
    required this.onRetry,
  });

  final ExerciseDetailVideoViewData video;
  final ExerciseVideoPlaybackState playbackState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final angleLabel = video.angle != null
        ? _ExerciseVideoCardLabelFormatter.formatLabel(video.angle!.dbValue)
        : AppStrings.videoUnavailable;
    final genderLabel = video.gender != null
        ? _ExerciseVideoCardLabelFormatter.formatLabel(video.gender!.dbValue)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: playbackState == ExerciseVideoPlaybackState.failed
                ? context.colorScheme.errorContainer
                : context.colorScheme.surfaceContainerHigh,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: AppSizing.videoCardHeight,
                ),
                child: AspectRatio(
                  aspectRatio:
                      AppSpacing.md / (AppSpacing.sm + AppSpacing.xxxs),
                  child: playbackState == ExerciseVideoPlaybackState.failed
                      ? const _FailedVideoVisual()
                      : _VideoVisual(
                          video: video,
                          playbackState: playbackState,
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _VideoMetadataBadge(label: angleLabel),
                    if (genderLabel != null)
                      _VideoMetadataBadge(label: genderLabel),
                  ],
                ),
                if (playbackState == ExerciseVideoPlaybackState.failed) ...[
                  AppWhiteSpace.hMd,
                  Text(
                    AppStrings.exerciseVideoLoadFailed,
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  AppWhiteSpace.hMd,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: onRetry,
                      icon: SvgPicture.asset(
                        OutlinedSvgAssets.arrowPath,
                        width: AppSizing.iconXxs,
                        height: AppSizing.iconXxs,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(AppStrings.retryVideo),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoVisual extends StatelessWidget {
  const _VideoVisual({required this.video, required this.playbackState});

  final ExerciseDetailVideoViewData video;
  final ExerciseVideoPlaybackState playbackState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: context.colorScheme.surfaceContainerHigh,
          child: video.hasThumbnail
              ? CachedNetworkImage(
                  imageUrl: video.ogImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const _VideoLoadingIndicator(),
                  errorWidget: (_, _, _) => const _VideoFallbackIcon(),
                )
              : const _VideoFallbackIcon(),
        ),
        Center(
          child: Container(
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              OutlinedSvgAssets.play,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (playbackState == ExerciseVideoPlaybackState.loading)
          const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class _VideoFallbackIcon extends StatelessWidget {
  const _VideoFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        OutlinedSvgAssets.videoCamera,
        width: AppSizing.iconXxl,
        height: AppSizing.iconXxl,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _VideoLoadingIndicator extends StatelessWidget {
  const _VideoLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        child: CircularProgressIndicator(strokeWidth: AppSizing.strokeWidth),
      ),
    );
  }
}

class _FailedVideoVisual extends StatelessWidget {
  const _FailedVideoVisual();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.errorContainer,
      child: Center(
        child: SvgPicture.asset(
          OutlinedSvgAssets.exclamationTriangle,
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          colorFilter: ColorFilter.mode(
            context.colorScheme.error,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _VideoMetadataBadge extends StatelessWidget {
  const _VideoMetadataBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      foregroundColor: context.colorScheme.onSurfaceVariant,
      borderRadius: AppRadius.full,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTextStyles.labelSm,
    );
  }
}

class _ExerciseVideoCardLabelFormatter {
  _ExerciseVideoCardLabelFormatter._();

  static String formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
