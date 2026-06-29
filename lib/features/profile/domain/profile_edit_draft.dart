import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/training_day.dart';

class ProfileEditDraft {
  const ProfileEditDraft({
    this.displayName,
    this.experienceLevel,
    this.goals = const <GoalTag>{},
    this.equipmentAccess = const <EquipmentTag>{},
    this.trainingDaysPerWeek,
    this.trainingDays = const <TrainingDay>[],
    this.targetSessionLengthMinutes,
    this.preferredUnits = PreferredUnit.metric,
    this.heightCm,
    this.bodyweightKg,
    this.favoriteExerciseIds = const <int>[],
    this.substitutedExerciseIds = const <int>[],
    this.injuriesLimitations = const <String>[],
    this.otherNotes,
    this.sex,
    this.dateOfBirth,
    this.bench1RmKg,
    this.squat1RmKg,
    this.deadlift1RmKg,
  });

  final String? displayName;
  final ExperienceLevel? experienceLevel;
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

  ProfileEditDraft copyWith({
    String? displayName,
    ExperienceLevel? experienceLevel,
    Set<GoalTag>? goals,
    Set<EquipmentTag>? equipmentAccess,
    int? trainingDaysPerWeek,
    List<TrainingDay>? trainingDays,
    int? targetSessionLengthMinutes,
    PreferredUnit? preferredUnits,
    double? heightCm,
    double? bodyweightKg,
    List<int>? favoriteExerciseIds,
    List<int>? substitutedExerciseIds,
    List<String>? injuriesLimitations,
    String? otherNotes,
    Sex? sex,
    DateTime? dateOfBirth,
    double? bench1RmKg,
    double? squat1RmKg,
    double? deadlift1RmKg,
    bool clearDisplayName = false,
    bool clearExperienceLevel = false,
    bool clearTrainingDaysPerWeek = false,
    bool clearTargetSessionLengthMinutes = false,
    bool clearHeightCm = false,
    bool clearBodyweightKg = false,
    bool clearOtherNotes = false,
    bool clearSex = false,
    bool clearDateOfBirth = false,
    bool clearBench1RmKg = false,
    bool clearSquat1RmKg = false,
    bool clearDeadlift1RmKg = false,
  }) {
    return ProfileEditDraft(
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      experienceLevel: clearExperienceLevel
          ? null
          : (experienceLevel ?? this.experienceLevel),
      trainingDaysPerWeek: clearTrainingDaysPerWeek
          ? null
          : (trainingDaysPerWeek ?? this.trainingDaysPerWeek),
      targetSessionLengthMinutes: clearTargetSessionLengthMinutes
          ? null
          : (targetSessionLengthMinutes ?? this.targetSessionLengthMinutes),
      heightCm: clearHeightCm ? null : (heightCm ?? this.heightCm),
      bodyweightKg: clearBodyweightKg
          ? null
          : (bodyweightKg ?? this.bodyweightKg),
      otherNotes: clearOtherNotes ? null : (otherNotes ?? this.otherNotes),
      sex: clearSex ? null : (sex ?? this.sex),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      bench1RmKg: clearBench1RmKg ? null : (bench1RmKg ?? this.bench1RmKg),
      squat1RmKg: clearSquat1RmKg ? null : (squat1RmKg ?? this.squat1RmKg),
      deadlift1RmKg: clearDeadlift1RmKg
          ? null
          : (deadlift1RmKg ?? this.deadlift1RmKg),
      goals: goals ?? this.goals,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      trainingDays: trainingDays ?? this.trainingDays,
      favoriteExerciseIds: favoriteExerciseIds ?? this.favoriteExerciseIds,
      substitutedExerciseIds:
          substitutedExerciseIds ?? this.substitutedExerciseIds,
      injuriesLimitations: injuriesLimitations ?? this.injuriesLimitations,
      preferredUnits: preferredUnits ?? this.preferredUnits,
    );
  }
}
