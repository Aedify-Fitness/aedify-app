import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';

class ExerciseDetailViewData {
  const ExerciseDetailViewData({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.primaryMuscles,
    required this.muscleGroups,
    required this.category,
    required this.modality,
    required this.equipment,
    required this.force,
    required this.mechanic,
    required this.grips,
    required this.steps,
    required this.videos,
    required this.isFavorite,
    required this.isSubstitutedOut,
  });

  final int id;
  final String name;
  final String? difficulty;
  final List<String> primaryMuscles;
  final List<String> muscleGroups;
  final String? category;
  final String modality;
  final String? equipment;
  final String? force;
  final String? mechanic;
  final List<String> grips;
  final List<String> steps;
  final List<ExerciseDetailVideoViewData> videos;
  final bool isFavorite;
  final bool isSubstitutedOut;
}
