import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.lg),
          Text(AppStrings.exerciseVideos, style: context.textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.videoCameraSlash,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.noExerciseVideos,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.lg),
        Text(AppStrings.exerciseVideos, style: context.textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        ...videos.map(
          (video) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExerciseVideoCard(
              video: video,
              playbackState:
                  failureStates[video.url] ?? ExerciseVideoPlaybackState.idle,
              onRetry: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}
