import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_exercise.dart';

class ExerciseDataset {
  const ExerciseDataset({
    required this.schemaVersion,
    required this.generatedAt,
    required this.source,
    required this.exerciseCount,
    required this.exercises,
  });

  final int schemaVersion;
  final DateTime generatedAt;
  final String source;
  final int exerciseCount;
  final List<ExerciseDatasetExercise> exercises;
}
