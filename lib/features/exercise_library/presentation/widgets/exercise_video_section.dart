import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_video_playback_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/components/app_section_header.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.exerciseVideos),
        AppWhiteSpace.hLg,
        if (videos.isEmpty)
          AppEmptyState(
            iconAsset: OutlinedSvgAssets.videoCameraSlash,
            title: AppStrings.noExerciseVideos,
          )
        else
          ...videos.map(
            (video) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
