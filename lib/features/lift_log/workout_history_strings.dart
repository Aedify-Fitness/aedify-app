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
  static const historyHint = 'Tap an exercise to review its logged sets.';
  static const loggedSets = 'Logged sets';
  static const results = 'Results';
  static const effort = 'Effort';
  static const rpeRange = '1–10';
  static const notLogged = 'Not logged';

  static String setCount(int logged, int total) => '$logged/$total sets logged';
  static String exerciseCount(int count) => '$count exercises';

  static String exerciseReference(int id) => 'Exercise ID $id';
}
