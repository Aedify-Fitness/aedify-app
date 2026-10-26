import 'package:aedify/features/profile/data/profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_candidate_preferences.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

class DefaultProfileCandidatePreferencesService
    implements ProfileCandidatePreferencesService {
  DefaultProfileCandidatePreferencesService({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<ProfileCandidatePreferences> buildPreferences() async {
    final profile = await _profileRepository.getProfile();

    final allowedEquipment = _mapEquipment(
      profile?.equipmentAccess ?? <EquipmentTag>{},
    );
    final allowedDifficulties = _mapExperience(profile?.experienceLevel);
    final excludedExerciseIds = _mapExcludedExerciseIds(
      profile?.substitutedExerciseIds ?? [],
    );
    final excludedMuscleGroups = <BodymapBucket>{};
    final goalTags = _mapGoalTags(profile?.goals ?? <GoalTag>{});
    const includeCustomExercises = true;

    return ProfileCandidatePreferences(
      allowedEquipment: allowedEquipment,
      allowedDifficulties: allowedDifficulties,
      allowedModalities: <ExerciseModality>{},
      excludedExerciseIds: excludedExerciseIds,
      excludedMuscleGroups: excludedMuscleGroups,
      goalTags: goalTags,
      preferredMuscleGroups: [],
      includeCustomExercises: includeCustomExercises,
    );
  }

  Set<EquipmentTag> _mapEquipment(Set<EquipmentTag> equipmentAccess) {
    return equipmentAccess;
  }

  Set<ExerciseDifficulty> _mapExperience(ExperienceLevel? experienceLevel) {
    switch (experienceLevel) {
      case ExperienceLevel.novice:
      case ExperienceLevel.beginner:
        return {ExerciseDifficulty.novice, ExerciseDifficulty.beginner};
      case ExperienceLevel.intermediate:
        return {ExerciseDifficulty.beginner, ExerciseDifficulty.intermediate};
      case ExperienceLevel.advanced:
        return ExerciseDifficulty.values.toSet();
      default:
        return ExerciseDifficulty.values.toSet();
    }
  }

  Set<int> _mapExcludedExerciseIds(List<int> substitutedIds) {
    return substitutedIds.toSet();
  }

  Set<GoalTag> _mapGoalTags(Set<GoalTag> goals) {
    final tags = <GoalTag>{};
    for (final goal in goals) {
      tags.add(goal);
    }
    return tags;
  }
}
