import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class CandidateExerciseDto {
  const CandidateExerciseDto({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.muscleGroups,
    required this.modality,
    required this.equipment,
    required this.mechanic,
    required this.force,
    required this.isCustom,
  });

  final int id;
  final String name;
  final ExerciseDifficulty? difficulty;
  final Set<BodymapBucket> muscleGroups;
  final ExerciseModality modality;
  final EquipmentTag? equipment;
  final ExerciseMechanic? mechanic;
  final ExerciseForce? force;
  final bool isCustom;
}
