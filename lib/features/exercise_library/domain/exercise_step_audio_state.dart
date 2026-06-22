enum ExerciseStepAudioPhase {
  idle,
  checkingCache,
  generating,
  speaking,
  unavailable,
  failed,
}

class ExerciseStepAudioState {
  const ExerciseStepAudioState({
    required this.phase,
    this.activeStepIndex,
    this.errorCode,
    this.errorMessage,
  });

  final ExerciseStepAudioPhase phase;
  final int? activeStepIndex;
  final String? errorCode;
  final String? errorMessage;

  bool get isBusy =>
      phase == ExerciseStepAudioPhase.checkingCache ||
      phase == ExerciseStepAudioPhase.generating ||
      phase == ExerciseStepAudioPhase.speaking;

  ExerciseStepAudioState copyWith({
    ExerciseStepAudioPhase? phase,
    int? activeStepIndex,
    String? errorCode,
    String? errorMessage,
    bool clearActiveStepIndex = false,
    bool clearError = false,
  }) {
    return ExerciseStepAudioState(
      phase: phase ?? this.phase,
      activeStepIndex: clearActiveStepIndex
          ? null
          : (activeStepIndex ?? this.activeStepIndex),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  const ExerciseStepAudioState.idle()
    : phase = ExerciseStepAudioPhase.idle,
      activeStepIndex = null,
      errorCode = null,
      errorMessage = null;
}
