import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';

class ProgrammeWorkoutDetailViewData {
  const ProgrammeWorkoutDetailViewData({
    required this.workoutName,
    required this.dayLabel,
    required this.programmeName,
    required this.durationMinutes,
    required this.exercises,
    required this.focusAreas,
    required this.buttonState,
  });

  final String workoutName;
  final String dayLabel;
  final String? programmeName;
  final int durationMinutes;
  final List<ExerciseDetailItem> exercises;
  final String focusAreas;
  final WorkoutDetailButtonState buttonState;
}

class ExerciseDetailItem {
  const ExerciseDetailItem({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.equipment,
    this.supersetGroupId,
    this.supersetOrder,
    this.loggingType = ExerciseLoggingType.repsWeight,
  });

  final int exerciseId;
  final String name;
  final List<SetPrescriptionItem> sets;
  final String equipment;
  final String? supersetGroupId;
  final int? supersetOrder;
  final ExerciseLoggingType loggingType;
}

class SetPrescriptionItem {
  const SetPrescriptionItem({
    required this.setIndex,
    required this.setType,
    this.repsDisplay,
    this.weightDisplay,
    this.rpeDisplay,
    this.restSeconds,
    this.durationSeconds,
    this.notes,
  });

  final int setIndex;
  final String setType;
  final String? repsDisplay;
  final String? weightDisplay;
  final String? rpeDisplay;
  final int? restSeconds;
  final int? durationSeconds;
  final String? notes;
}
