import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

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
    this.loggingType = ExerciseLoggingType.repsWeight,
  });

  final int id;
  final String name;
  final ExerciseDifficulty? difficulty;
  final List<String> primaryMuscles;
  final Set<BodymapBucket> muscleGroups;
  final String? category;
  final ExerciseModality modality;
  final EquipmentTag? equipment;
  final ExerciseForce? force;
  final ExerciseMechanic? mechanic;
  final List<String> grips;
  final List<String> steps;
  final List<ExerciseDetailVideoViewData> videos;
  final bool isFavorite;
  final bool isSubstitutedOut;
  final ExerciseLoggingType loggingType;
}
