import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';

class ExerciseDatasetVideo {
  const ExerciseDatasetVideo({
    required this.url,
    required this.angle,
    required this.gender,
    this.ogImage,
  });

  final Uri url;
  final ExerciseVideoAngle angle;
  final ExerciseVideoGender gender;
  final String? ogImage;
}
