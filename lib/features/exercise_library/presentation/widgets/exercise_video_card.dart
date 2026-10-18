import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
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
    this.width,
  });

  final ExerciseDetailVideoViewData video;
  final ExerciseVideoPlaybackState playbackState;
  final VoidCallback onRetry;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final angleLabel = video.angle != null
        ? _ExerciseVideoCardLabelFormatter.formatLabel(video.angle!.dbValue)
        : AppStrings.videoUnavailable;
    final genderLabel = video.gender != null
        ? _ExerciseVideoCardLabelFormatter.formatLabel(video.gender!.dbValue)
        : null;
    final semanticsLabel = [
      angleLabel,
      ?genderLabel,
      AppStrings.exerciseVideos,
    ].join(', ');

    final card = Semantics(
      image: true,
      label: semanticsLabel,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: MediaQuery.highContrastOf(context)
              ? Border.all(color: context.colorScheme.outlineVariant)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: AppExerciseDetailTokens.mediaAspectRatio,
          child: playbackState == ExerciseVideoPlaybackState.failed
              ? _FailedVideoVisual(onRetry: onRetry)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    _VideoVisual(video: video, playbackState: playbackState),
                    ColoredBox(
                      color: context.colorScheme.scrim.withValues(
                        alpha: AppExerciseDetailTokens.videoScrimOpacity,
                      ),
                    ),
                    const Center(child: _PlayControl()),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Wrap(
                        key: ValueKey<String>(
                          'exercise_video_metadata_${video.url}',
                        ),
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _VideoMetadataBadge(label: angleLabel),
                          if (genderLabel != null)
                            _VideoMetadataBadge(label: genderLabel),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

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

class _PlayControl extends StatelessWidget {
  const _PlayControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.iconXxl,
      height: AppSizing.iconXxl,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest.withValues(
          alpha: AppExerciseDetailTokens.videoOverlaySurfaceOpacity,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        SolidSvgAssets.play,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          _ExerciseVideoCardColors.accent(context),
          BlendMode.srcIn,
        ),
      ),
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
  const _FailedVideoVisual({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.errorContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.exclamationTriangle,
                width: AppSizing.iconLg,
                height: AppSizing.iconLg,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
              AppWhiteSpace.hXs,
              Text(
                AppStrings.exerciseVideoLoadFailed,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
              AppWhiteSpace.hSm,
              FilledButton.tonalIcon(
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
            ],
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
      backgroundColor: context.colorScheme.surfaceContainerLowest.withValues(
        alpha: AppExerciseDetailTokens.videoOverlaySurfaceOpacity,
      ),
      foregroundColor: context.colorScheme.onSurface,
      borderRadius: AppRadius.full,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppExerciseDetailTokens.videoBadgeVerticalPadding,
      ),
      textStyle: AppTextStyles.labelSm,
      fontWeight: FontWeight.w600,
    );
  }
}

class _ExerciseVideoCardColors {
  _ExerciseVideoCardColors._();

  static Color accent(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Theme.brightnessOf(context) == Brightness.dark
        ? colorScheme.primary
        : colorScheme.secondary;
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
