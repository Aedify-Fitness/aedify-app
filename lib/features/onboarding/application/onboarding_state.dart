enum OnboardingStep {
  welcome,
  experienceGoals,
  schedule,
  equipment,
  unitsMetrics,
  limitations,
  byokOptional,
  review,
}

class OnboardingDraft {
  const OnboardingDraft({
    this.displayName,
    this.experienceLevel,
    this.goals = const <String>[],
    this.trainingDaysPerWeek,
    this.targetSessionLengthMinutes,
    this.equipmentAccess = const <String>[],
    this.preferredUnits,
    this.heightCm,
    this.bodyweightKg,
    this.limitations = const <String>[],
    this.notes,
    this.byokSkipped = true,
  });

  final String? displayName;
  final String? experienceLevel;
  final List<String> goals;
  final int? trainingDaysPerWeek;
  final int? targetSessionLengthMinutes;
  final List<String> equipmentAccess;
  final String? preferredUnits;
  final double? heightCm;
  final double? bodyweightKg;
  final List<String> limitations;
  final String? notes;
  final bool byokSkipped;

  OnboardingDraft copyWith({
    String? displayName,
    String? experienceLevel,
    List<String>? goals,
    int? trainingDaysPerWeek,
    int? targetSessionLengthMinutes,
    List<String>? equipmentAccess,
    String? preferredUnits,
    double? heightCm,
    double? bodyweightKg,
    List<String>? limitations,
    String? notes,
    bool? byokSkipped,
    bool clearDisplayName = false,
    bool clearExperienceLevel = false,
    bool clearTrainingDaysPerWeek = false,
    bool clearTargetSessionLengthMinutes = false,
    bool clearPreferredUnits = false,
    bool clearHeightCm = false,
    bool clearBodyweightKg = false,
    bool clearNotes = false,
  }) {
    return OnboardingDraft(
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
      preferredUnits: clearPreferredUnits
          ? null
          : (preferredUnits ?? this.preferredUnits),
      heightCm: clearHeightCm ? null : (heightCm ?? this.heightCm),
      bodyweightKg: clearBodyweightKg
          ? null
          : (bodyweightKg ?? this.bodyweightKg),
      notes: clearNotes ? null : (notes ?? this.notes),
      goals: goals ?? this.goals,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      limitations: limitations ?? this.limitations,
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
