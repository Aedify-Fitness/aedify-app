import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class ExerciseListItem {
  const ExerciseListItem({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.muscleGroups,
    required this.modality,
    required this.equipment,
    required this.isFavorite,
    required this.isSubstitutedOut,
    this.isCustom = false,
    this.loggingType = ExerciseLoggingType.repsWeight,
  });

  final int id;
  final String name;
  final ExerciseDifficulty? difficulty;
  final Set<BodymapBucket> muscleGroups;
  final ExerciseModality modality;
  final EquipmentTag? equipment;
  final bool isFavorite;
  final bool isSubstitutedOut;
  final bool isCustom;
  final ExerciseLoggingType loggingType;
}
