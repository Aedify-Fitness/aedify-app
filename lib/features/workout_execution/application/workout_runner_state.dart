import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_resume_decision.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_phase.dart';

class WorkoutRunnerState {
  const WorkoutRunnerState({
    required this.mode,
    required this.phase,
    this.session,
    this.hasRecoveredSession = false,
    this.errorCode,
    this.errorMessage,
    this.resumeDecision,
  });

  final WorkoutRunnerMode mode;
  final WorkoutRunnerPhase phase;
  final WorkoutRunnerSessionViewData? session;
  final bool hasRecoveredSession;
  final String? errorCode;
  final String? errorMessage;
  final WorkoutRunnerResumeDecision? resumeDecision;

  bool get isLoading => phase == WorkoutRunnerPhase.loading;
  bool get isSaving => phase == WorkoutRunnerPhase.saving;
  bool get isCompleting => phase == WorkoutRunnerPhase.completing;
  bool get hasSession => session != null;

  WorkoutRunnerState copyWith({
    WorkoutRunnerMode? mode,
    WorkoutRunnerPhase? phase,
    WorkoutRunnerSessionViewData? session,
    bool? hasRecoveredSession,
    String? errorCode,
    String? errorMessage,
    WorkoutRunnerResumeDecision? resumeDecision,
  }) {
    return WorkoutRunnerState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      session: session ?? this.session,
      hasRecoveredSession: hasRecoveredSession ?? this.hasRecoveredSession,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      resumeDecision: resumeDecision ?? this.resumeDecision,
    );
  }

  factory WorkoutRunnerState.initial({required WorkoutRunnerMode mode}) {
    return WorkoutRunnerState(mode: mode, phase: WorkoutRunnerPhase.loading);
  }
}
