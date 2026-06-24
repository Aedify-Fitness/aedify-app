class ProfileViewData {
  const ProfileViewData({
    required this.displayName,
    required this.experienceLevel,
    required this.goals,
    required this.equipmentAccess,
    required this.trainingDaysPerWeek,
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
  final String experienceLevel;
  final List<String> goals;
  final List<String> equipmentAccess;
  final int? trainingDaysPerWeek;
  final int? targetSessionLengthMinutes;
  final String preferredUnits;
  final double? heightCm;
  final double? bodyweightKg;
  final List<int> favoriteExerciseIds;
  final List<int> substitutedExerciseIds;
  final List<String> injuriesLimitations;
  final String? otherNotes;
  final String? sex;
  final DateTime? dateOfBirth;
  final double? bench1RmKg;
  final double? squat1RmKg;
  final double? deadlift1RmKg;
}
