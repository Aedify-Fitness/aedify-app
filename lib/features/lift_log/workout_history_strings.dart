/// Copy owned by local training history and corrections.
class WorkoutHistoryStrings {
  WorkoutHistoryStrings._();

  static const correctSet = 'Correct set';
  static const correctionHint =
      'Update the actual results. The original workout and planned targets stay intact.';
  static const saveCorrection = 'Save correction';
  static const seconds = 'Duration (seconds)';
  static const meters = 'Distance (meters)';
  static const metersUnit = 'm';
  static const refreshHistory = 'Refresh history';
  static const repeatWorkout = 'Repeat workout';

  static String exerciseReference(int id) => 'Exercise ID $id';
}
