import 'package:cached_network_image/cached_network_image.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
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
    final colorScheme = context.colorScheme;

    return Card(
      child: switch (playbackState) {
        ExerciseVideoPlaybackState.failed => _FailedVideo(
          video: video,
          colorScheme: colorScheme,
          onRetry: onRetry,
        ),
        _ => ListTile(
          leading: video.hasThumbnail
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: video.ogImageUrl!,
                    width: AppSpacing.lg,
                    height: AppSpacing.lg,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => SizedBox(
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: AppSpacing.xxs,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => SvgPicture.asset(
                      OulinedSvgAssets.videoCamera,
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              : SvgPicture.asset(
                  OulinedSvgAssets.videoCamera,
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
          title: Text(video.angle ?? AppStrings.videoUnavailable),
          subtitle: Text(video.gender ?? ''),
          trailing: playbackState == ExerciseVideoPlaybackState.loading
              ? SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: AppSpacing.xxs),
                )
              : null,
        ),
      },
    );
  }
}

class _FailedVideo extends StatelessWidget {
  const _FailedVideo({
    required this.video,
    required this.colorScheme,
    required this.onRetry,
  });

  final ExerciseDetailVideoViewData video;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        OulinedSvgAssets.exclamationTriangle,
        width: AppSpacing.lg,
        height: AppSpacing.lg,
        colorFilter: ColorFilter.mode(colorScheme.error, BlendMode.srcIn),
      ),
      title: Text(video.angle ?? AppStrings.exerciseVideoLoadFailed),
      subtitle: Text(AppStrings.exerciseVideoLoadFailed),
      trailing: FilledButton.tonalIcon(
        onPressed: onRetry,
        icon: SvgPicture.asset(
          OulinedSvgAssets.arrowPath,
          width: AppSizing.iconXxs,
          height: AppSizing.iconXxs,
        ),
        label: Text(AppStrings.retryVideo),
      ),
    );
  }
}
