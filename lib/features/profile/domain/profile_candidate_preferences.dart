import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

class ProfileCandidatePreferences {
  const ProfileCandidatePreferences({
    required this.allowedEquipment,
    required this.allowedDifficulties,
    required this.allowedModalities,
    required this.excludedExerciseIds,
    required this.excludedMuscleGroups,
    required this.goalTags,
    required this.preferredMuscleGroups,
    required this.includeCustomExercises,
  });

  final Set<EquipmentTag> allowedEquipment;
  final Set<ExerciseDifficulty> allowedDifficulties;
  final Set<ExerciseModality> allowedModalities;
  final Set<int> excludedExerciseIds;
  final Set<BodymapBucket> excludedMuscleGroups;
  final Set<GoalTag> goalTags;
  final List<BodymapBucket> preferredMuscleGroups;
  final bool includeCustomExercises;
}
