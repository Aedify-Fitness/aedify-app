import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_video.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class ExerciseDatasetExercise {
  const ExerciseDatasetExercise({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.primaryMuscles,
    required this.muscleGroups,
    this.category,
    required this.modality,
    this.loggingType,
    this.equipment,
    this.force,
    this.mechanic,
    required this.grips,
    required this.steps,
    required this.videos,
  });

  final int id;
  final String name;
  final ExerciseDifficulty difficulty;
  final List<String> primaryMuscles;
  final Set<BodymapBucket> muscleGroups;
  final String? category;
  final ExerciseModality modality;
  final ExerciseLoggingType? loggingType;
  final EquipmentTag? equipment;
  final ExerciseForce? force;
  final ExerciseMechanic? mechanic;
  final List<String> grips;
  final List<String> steps;
  final List<ExerciseDatasetVideo> videos;
}
