import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_video.dart';

class ExerciseDatasetExercise {
  const ExerciseDatasetExercise({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.primaryMuscles,
    required this.muscleGroups,
    this.category,
    required this.modality,
    this.equipment,
    this.force,
    this.mechanic,
    required this.grips,
    required this.steps,
    required this.videos,
  });

  final int id;
  final String name;
  final String difficulty;
  final List<String> primaryMuscles;
  final List<String> muscleGroups;
  final String? category;
  final String modality;
  final String? equipment;
  final String? force;
  final String? mechanic;
  final List<String> grips;
  final List<String> steps;
  final List<ExerciseDatasetVideo> videos;
}
