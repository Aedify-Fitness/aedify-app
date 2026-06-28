import 'package:aedify/features/profile/data/profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_candidate_preferences.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/exercise_constants.dart';

class DefaultProfileCandidatePreferencesService
    implements ProfileCandidatePreferencesService {
  DefaultProfileCandidatePreferencesService({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<ProfileCandidatePreferences> buildPreferences() async {
    final profile = await _profileRepository.getProfile();

    final allowedEquipment = _mapEquipment(profile?.equipmentAccess ?? []);
    final allowedDifficulties = _mapExperience(profile?.experienceLevel);
    final excludedExerciseIds = _mapExcludedExerciseIds(
      profile?.substitutedExerciseIds ?? [],
    );
    final excludedMuscleGroups = <String>{};
    final goalTags = _mapGoalTags(profile?.goals ?? []);
    const includeCustomExercises = true;

    return ProfileCandidatePreferences(
      allowedEquipment: allowedEquipment,
      allowedDifficulties: allowedDifficulties,
      allowedModalities: {},
      excludedExerciseIds: excludedExerciseIds,
      excludedMuscleGroups: excludedMuscleGroups,
      goalTags: goalTags,
      preferredMuscleGroups: [],
      includeCustomExercises: includeCustomExercises,
    );
  }

  Set<String> _mapEquipment(List<String> equipmentAccess) {
    return equipmentAccess.toSet();
  }

  Set<String> _mapExperience(String? experienceLevel) {
    switch (experienceLevel) {
      case AppStrings.onboardingExperienceBeginner:
        return ExerciseConstants.beginnerDifficulties;
      case AppStrings.onboardingExperienceIntermediate:
        return ExerciseConstants.intermediateDifficulties;
      case AppStrings.onboardingExperienceAdvanced:
        return ExerciseConstants.allDifficulties;
      default:
        return ExerciseConstants.allDifficulties;
    }
  }

  Set<int> _mapExcludedExerciseIds(List<int> substitutedIds) {
    return substitutedIds.toSet();
  }

  Set<String> _mapGoalTags(List<String> goals) {
    final tags = <String>{};
    for (final goal in goals) {
      if (goal == AppStrings.onboardingGoalBuildMuscle) {
        tags.add(ExerciseConstants.goalTagHypertrophy);
      } else if (goal == AppStrings.onboardingGoalLoseWeight) {
        tags.add(ExerciseConstants.goalTagCardio);
      } else if (goal == AppStrings.onboardingGoalIncreaseStrength) {
        tags.add(ExerciseConstants.goalTagStrength);
      } else if (goal == AppStrings.onboardingGoalImproveEndurance) {
        tags.add(ExerciseConstants.goalTagCardio);
      }
    }
    return tags;
  }
}
