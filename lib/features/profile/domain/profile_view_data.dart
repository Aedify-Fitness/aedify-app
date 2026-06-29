import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/training_day.dart';

class ProfileViewData {
  const ProfileViewData({
    required this.displayName,
    required this.experienceLevel,
    required this.goals,
    required this.equipmentAccess,
    required this.trainingDaysPerWeek,
    this.trainingDays = const <TrainingDay>[],
    required this.targetSessionLengthMinutes,
    required this.preferredUnits,
    required this.heightCm,
    required this.bodyweightKg,
    required this.favoriteExerciseIds,
    required this.substitutedExerciseIds,
    required this.injuriesLimitations,
    required this.otherNotes,
    required this.sex,
    required this.dateOfBirth,
    required this.bench1RmKg,
    required this.squat1RmKg,
    required this.deadlift1RmKg,
  });

  final String? displayName;
  final ExperienceLevel experienceLevel;
  final Set<GoalTag> goals;
  final Set<EquipmentTag> equipmentAccess;
  final int? trainingDaysPerWeek;
  final List<TrainingDay> trainingDays;
  final int? targetSessionLengthMinutes;
  final PreferredUnit preferredUnits;
  final double? heightCm;
  final double? bodyweightKg;
  final List<int> favoriteExerciseIds;
  final List<int> substitutedExerciseIds;
  final List<String> injuriesLimitations;
  final String? otherNotes;
  final Sex? sex;
  final DateTime? dateOfBirth;
  final double? bench1RmKg;
  final double? squat1RmKg;
  final double? deadlift1RmKg;
}
