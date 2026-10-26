import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

class CandidateExerciseQuery {
  const CandidateExerciseQuery({
    required this.allowedEquipment,
    required this.allowedDifficulties,
    required this.allowedModalities,
    required this.excludedExerciseIds,
    required this.excludedMuscleGroups,
    required this.goalTags,
    this.preferredMuscleGroups = const [],
    this.includeCustomExercises = true,
    this.limit = 25,
  });

  final Set<EquipmentTag> allowedEquipment;
  final Set<ExerciseDifficulty> allowedDifficulties;
  final Set<ExerciseModality> allowedModalities;
  final Set<int> excludedExerciseIds;
  final Set<BodymapBucket> excludedMuscleGroups;
  final Set<GoalTag> goalTags;
  final List<BodymapBucket> preferredMuscleGroups;
  final bool includeCustomExercises;
  final int limit;
}
