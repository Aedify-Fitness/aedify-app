import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';

class OnboardingTaxonomy {
  OnboardingTaxonomy._();

  static GoalTag goalFromLabel(String value) {
    return switch (value) {
      AppStrings.onboardingGoalBuildMuscle => GoalTag.buildMuscle,
      AppStrings.onboardingGoalLoseWeight => GoalTag.loseWeight,
      AppStrings.onboardingGoalIncreaseStrength => GoalTag.increaseStrength,
      AppStrings.onboardingGoalImproveEndurance => GoalTag.improveEndurance,
      AppStrings.onboardingGoalGeneralFitness => GoalTag.generalFitness,
      _ => GoalTag.flexibility,
    };
  }

  static String goalLabel(GoalTag value) {
    return switch (value) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  static String? experienceLabel(ExperienceLevel? value) {
    return switch (value) {
      ExperienceLevel.novice => AppStrings.onboardingExperienceBeginner,
      ExperienceLevel.beginner => AppStrings.onboardingExperienceBeginner,
      ExperienceLevel.intermediate =>
        AppStrings.onboardingExperienceIntermediate,
      ExperienceLevel.advanced => AppStrings.onboardingExperienceAdvanced,
      null => null,
    };
  }

  static String equipmentLabel(EquipmentTag value) {
    return switch (value) {
      EquipmentTag.bodyweight => AppStrings.onboardingEquipmentNone,
      EquipmentTag.dumbbell => AppStrings.onboardingEquipmentDumbbells,
      EquipmentTag.barbell => AppStrings.onboardingEquipmentBarbell,
      EquipmentTag.bench => AppStrings.onboardingEquipmentBench,
      EquipmentTag.squatRack => AppStrings.onboardingEquipmentSquatRack,
      EquipmentTag.kettlebell => AppStrings.onboardingEquipmentKettlebell,
      EquipmentTag.bands => AppStrings.onboardingEquipmentResistanceBands,
      EquipmentTag.pullUpBar => AppStrings.onboardingEquipmentPullUpBar,
      EquipmentTag.cable => AppStrings.onboardingEquipmentCableMachine,
      EquipmentTag.smithMachine => AppStrings.onboardingEquipmentSmithMachine,
      EquipmentTag.cardioMachine => AppStrings.onboardingEquipmentCardioMachine,
      EquipmentTag.machine => AppStrings.onboardingEquipmentMachine,
      EquipmentTag.ezBar => AppStrings.onboardingEquipmentEzBar,
      EquipmentTag.bosuBall => AppStrings.onboardingEquipmentBosuBall,
      EquipmentTag.medicineBall => AppStrings.onboardingEquipmentMedicineBall,
      EquipmentTag.plate => AppStrings.onboardingEquipmentPlate,
      EquipmentTag.trx => AppStrings.onboardingEquipmentTrx,
      EquipmentTag.vitruvian => AppStrings.onboardingEquipmentVitruvian,
      EquipmentTag.other => AppStrings.onboardingEquipmentOther,
    };
  }
}
