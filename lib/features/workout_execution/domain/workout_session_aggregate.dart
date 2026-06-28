import 'package:aedify/core/db/app_database.dart';

class WorkoutSessionAggregate {
  const WorkoutSessionAggregate({
    required this.session,
    required this.exercises,
    required this.setLogs,
  });

  final WorkoutSession session;
  final List<WorkoutSessionExercise> exercises;
  final List<SetLog> setLogs;
}
