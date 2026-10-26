import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class CustomExerciseDraft {
  const CustomExerciseDraft({
    required this.name,
    required this.muscleGroups,
    required this.modality,
    this.loggingType,
    this.equipment,
    this.difficulty,
    this.steps = const <String>[],
  });

  final String name;
  final Set<BodymapBucket> muscleGroups;
  final ExerciseModality modality;
  final ExerciseLoggingType? loggingType;
  final EquipmentTag? equipment;
  final ExerciseDifficulty? difficulty;
  final List<String> steps;

  CustomExerciseDraft copyWith({
    String? name,
    Set<BodymapBucket>? muscleGroups,
    ExerciseModality? modality,
    ExerciseLoggingType? loggingType,
    EquipmentTag? equipment,
    ExerciseDifficulty? difficulty,
    List<String>? steps,
  }) {
    return CustomExerciseDraft(
      name: name ?? this.name,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      modality: modality ?? this.modality,
      loggingType: loggingType ?? this.loggingType,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      steps: steps ?? this.steps,
    );
  }

  CustomExerciseSeed toSeed() {
    return CustomExerciseSeed(
      name: name,
      muscleGroups: muscleGroups,
      modality: modality,
      loggingType: loggingType,
      equipment: equipment,
      difficulty: difficulty,
      steps: steps,
    );
  }
}
