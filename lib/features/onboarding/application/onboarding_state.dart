import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/training_day.dart';

enum OnboardingStep {
  welcome,
  coreIdentity,
  experienceGoals,
  schedule,
  equipment,
  limitations,
  unitsMetrics,
  byokOptional,
  review,
}

class OnboardingDraft {
  const OnboardingDraft({
    this.displayName,
    this.sex,
    this.dateOfBirth,
    this.experienceLevel,
    this.goals = const <GoalTag>{},
    this.trainingDaysPerWeek,
    this.trainingDays = const <TrainingDay>[],
    this.targetSessionLengthMinutes,
    this.equipmentAccess = const <EquipmentTag>{},
    this.preferredUnits,
    this.heightCm,
    this.bodyweightKg,
    this.bench1RmKg,
    this.squat1RmKg,
    this.deadlift1RmKg,
    this.limitations = const <String>[],
    this.notes,
    this.favoriteExerciseIds = const <int>[],
    this.substitutedExerciseIds = const <int>[],
    this.byokSkipped = true,
  });

  final String? displayName;
  final Sex? sex;
  final DateTime? dateOfBirth;
  final ExperienceLevel? experienceLevel;
  final Set<GoalTag> goals;
  final int? trainingDaysPerWeek;
  final List<TrainingDay> trainingDays;
  final int? targetSessionLengthMinutes;
  final Set<EquipmentTag> equipmentAccess;
  final PreferredUnit? preferredUnits;
  final double? heightCm;
  final double? bodyweightKg;
  final double? bench1RmKg;
  final double? squat1RmKg;
  final double? deadlift1RmKg;
  final List<String> limitations;
  final String? notes;
  final List<int> favoriteExerciseIds;
  final List<int> substitutedExerciseIds;
  final bool byokSkipped;

  OnboardingDraft copyWith({
    String? displayName,
    Sex? sex,
    DateTime? dateOfBirth,
    ExperienceLevel? experienceLevel,
    Set<GoalTag>? goals,
    int? trainingDaysPerWeek,
    List<TrainingDay>? trainingDays,
    int? targetSessionLengthMinutes,
    Set<EquipmentTag>? equipmentAccess,
    PreferredUnit? preferredUnits,
    double? heightCm,
    double? bodyweightKg,
    double? bench1RmKg,
    double? squat1RmKg,
    double? deadlift1RmKg,
    List<String>? limitations,
    String? notes,
    List<int>? favoriteExerciseIds,
    List<int>? substitutedExerciseIds,
    bool? byokSkipped,
    bool clearDisplayName = false,
    bool clearSex = false,
    bool clearDateOfBirth = false,
    bool clearExperienceLevel = false,
    bool clearTrainingDaysPerWeek = false,
    bool clearTargetSessionLengthMinutes = false,
    bool clearPreferredUnits = false,
    bool clearHeightCm = false,
    bool clearBodyweightKg = false,
    bool clearBench1RmKg = false,
    bool clearSquat1RmKg = false,
    bool clearDeadlift1RmKg = false,
    bool clearNotes = false,
  }) {
    return OnboardingDraft(
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      sex: clearSex ? null : (sex ?? this.sex),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      experienceLevel: clearExperienceLevel
          ? null
          : (experienceLevel ?? this.experienceLevel),
      trainingDaysPerWeek: clearTrainingDaysPerWeek
          ? null
          : (trainingDaysPerWeek ?? this.trainingDaysPerWeek),
      targetSessionLengthMinutes: clearTargetSessionLengthMinutes
          ? null
          : (targetSessionLengthMinutes ?? this.targetSessionLengthMinutes),
      preferredUnits: clearPreferredUnits
          ? null
          : (preferredUnits ?? this.preferredUnits),
      heightCm: clearHeightCm ? null : (heightCm ?? this.heightCm),
      bodyweightKg: clearBodyweightKg
          ? null
          : (bodyweightKg ?? this.bodyweightKg),
      bench1RmKg: clearBench1RmKg ? null : (bench1RmKg ?? this.bench1RmKg),
      squat1RmKg: clearSquat1RmKg ? null : (squat1RmKg ?? this.squat1RmKg),
      deadlift1RmKg: clearDeadlift1RmKg
          ? null
          : (deadlift1RmKg ?? this.deadlift1RmKg),
      notes: clearNotes ? null : (notes ?? this.notes),
      goals: goals ?? this.goals,
      trainingDays: trainingDays ?? this.trainingDays,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      limitations: limitations ?? this.limitations,
      favoriteExerciseIds: favoriteExerciseIds ?? this.favoriteExerciseIds,
      substitutedExerciseIds:
          substitutedExerciseIds ?? this.substitutedExerciseIds,
      byokSkipped: byokSkipped ?? this.byokSkipped,
    );
  }
}

class OnboardingState {
  const OnboardingState({
    required this.currentStep,
    required this.draft,
    required this.isSaving,
    this.validationMessage,
    this.errorCode,
    this.errorMessage,
  });

  final OnboardingStep currentStep;
  final OnboardingDraft draft;
  final bool isSaving;
  final String? validationMessage;
  final String? errorCode;
  final String? errorMessage;

  bool get hasError => errorCode != null;
  bool get hasValidationMessage => validationMessage != null;

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    OnboardingDraft? draft,
    bool? isSaving,
    String? validationMessage,
    String? errorCode,
    String? errorMessage,
    bool clearValidationMessage = false,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      draft: draft ?? this.draft,
      isSaving: isSaving ?? this.isSaving,
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  const OnboardingState.initial()
    : this(
        currentStep: OnboardingStep.welcome,
        draft: const OnboardingDraft(),
        isSaving: false,
      );
}
