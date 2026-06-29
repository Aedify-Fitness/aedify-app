import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';

class ExerciseDetailVideoViewData {
  const ExerciseDetailVideoViewData({
    required this.url,
    required this.angle,
    required this.gender,
    required this.ogImageUrl,
  });

  final String url;
  final ExerciseVideoAngle? angle;
  final ExerciseVideoGender? gender;
  final String? ogImageUrl;

  bool get hasThumbnail => ogImageUrl != null && ogImageUrl!.isNotEmpty;
}
