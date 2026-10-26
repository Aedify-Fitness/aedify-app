import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A thumbnail preview with its descriptive details outside the image.
class ExerciseVideoCard extends StatelessWidget {
  const ExerciseVideoCard({
    super.key,
    required this.video,
    required this.playbackState,
    required this.onRetry,
    this.width,
    this.showDetails = true,
  });

  final ExerciseDetailVideoViewData video;
  final ExerciseVideoPlaybackState playbackState;
  final VoidCallback onRetry;
  final double? width;

  /// Allows a carousel to put the active caption below its fixed visual area.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final preview = Semantics(
      image: true,
      label: AppStrings.exerciseVideoPreview,
      child: AspectRatio(
        key: ValueKey<String>('exercise_video_visual_${video.url}'),
        aspectRatio: AppExerciseDetailTokens.mediaAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: MediaQuery.highContrastOf(context)
                ? Border.all(color: context.colorScheme.outline)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: playbackState == ExerciseVideoPlaybackState.failed
              ? const _FailedVideoVisual()
              : _VideoVisual(video: video, playbackState: playbackState),
        ),
      ),
    );
    final card = showDetails
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              preview,
              AppWhiteSpace.hControlGap,
              ExerciseVideoCaption(
                video: video,
                playbackState: playbackState,
                onRetry: onRetry,
              ),
            ],
          )
        : preview;

    if (width != null) return SizedBox(width: width, child: card);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppExerciseDetailTokens.maxContentWidth,
        ),
        child: card,
      ),
    );
  }
}

/// A scalable caption and recoverable failure state for the active preview.
class ExerciseVideoCaption extends StatelessWidget {
  const ExerciseVideoCaption({
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
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    final labelStyle = isDark
        ? AppTextStylesDark.labelMd
        : AppTextStyles.labelMd;
    final bodyStyle = isDark ? AppTextStylesDark.bodySm : AppTextStyles.bodySm;
    final metadata = [
      if (video.angle case final angle?)
        _ExerciseVideoCardLabelFormatter.formatLabel(angle.dbValue),
      if (video.gender case final gender?)
        _ExerciseVideoCardLabelFormatter.formatLabel(gender.dbValue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.exerciseVideoPreview,
          style: bodyStyle.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (metadata.isNotEmpty) ...[
          AppWhiteSpace.hXs,
          Wrap(
            key: ValueKey<String>('exercise_video_metadata_${video.url}'),
            spacing: AppSpacing.controlGap,
            runSpacing: AppSpacing.xs,
            children: [
              for (final label in metadata)
                Text(
                  label,
                  style: labelStyle.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ],
        if (playbackState == ExerciseVideoPlaybackState.failed) ...[
          AppWhiteSpace.hControlGap,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.exerciseVideoLoadFailed,
                  style: bodyStyle.copyWith(
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
                AppWhiteSpace.hSm,
                FilledButton.tonalIcon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      AppExerciseDetailTokens.controlSize,
                      AppExerciseDetailTokens.controlSize,
                    ),
                    foregroundColor: context.colorScheme.onErrorContainer,
                    backgroundColor: context.colorScheme.surfaceContainerLowest,
                    textStyle: labelStyle,
                  ),
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.arrowPath,
                    width: AppSizing.iconXxs,
                    height: AppSizing.iconXxs,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onErrorContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text(AppStrings.retryVideo),
                ),
              ],
            ),
          ),
        ],
      ],
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
        excludeFromSemantics: true,
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
          OutlinedSvgAssets.videoCameraSlash,
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          excludeFromSemantics: true,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onErrorContainer,
            BlendMode.srcIn,
          ),
        ),
      ),
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
