import 'package:aedify/core/db/app_database.dart';

class ProgrammeAggregate {
  const ProgrammeAggregate({
    required this.program,
    this.trainingBlocks = const [],
    required this.templates,
    required this.weeks,
    required this.workouts,
    required this.exercises,
    required this.sets,
    required this.revisions,
  });

  final List<ProgramTrainingBlock> trainingBlocks;
  final Program program;
  final List<ProgramWorkoutTemplate> templates;
  final List<ProgramWeek> weeks;
  final List<ProgramWorkout> workouts;
  final List<ProgramExercise> exercises;
  final List<ProgramExerciseSet> sets;
  final List<ProgramRevision> revisions;
}
