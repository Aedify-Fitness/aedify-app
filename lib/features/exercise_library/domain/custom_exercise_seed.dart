import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class CustomExerciseSeed {
  const CustomExerciseSeed({
    required this.name,
    required this.muscleGroups,
    required this.modality,
    this.loggingType,
    this.equipment,
    this.difficulty,
    this.steps = const <String>[],
  });

  final String name;
  final Set<BodymapBucket> muscleGroups;
  final ExerciseModality modality;
  final ExerciseLoggingType? loggingType;
  final EquipmentTag? equipment;
  final ExerciseDifficulty? difficulty;
  final List<String> steps;
}
