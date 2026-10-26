import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class ExerciseFilterState {
  const ExerciseFilterState({
    this.searchQuery = '',
    this.muscleGroup,
    this.equipment,
    this.difficulty,
    this.modality,
    this.favoritesOnly = false,
    this.excludeSubstituted = false,
  });

  final String searchQuery;
  final BodymapBucket? muscleGroup;
  final EquipmentTag? equipment;
  final ExerciseDifficulty? difficulty;
  final ExerciseModality? modality;
  final bool favoritesOnly;
  final bool excludeSubstituted;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      muscleGroup != null ||
      equipment != null ||
      difficulty != null ||
      modality != null ||
      favoritesOnly ||
      excludeSubstituted;

  ExerciseFilterState copyWith({
    String? searchQuery,
    BodymapBucket? muscleGroup,
    EquipmentTag? equipment,
    ExerciseDifficulty? difficulty,
    ExerciseModality? modality,
    bool? favoritesOnly,
    bool? excludeSubstituted,
    bool clearMuscleGroup = false,
    bool clearEquipment = false,
    bool clearDifficulty = false,
    bool clearModality = false,
  }) {
    return ExerciseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      muscleGroup: clearMuscleGroup ? null : muscleGroup ?? this.muscleGroup,
      equipment: clearEquipment ? null : equipment ?? this.equipment,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      modality: clearModality ? null : modality ?? this.modality,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      excludeSubstituted: excludeSubstituted ?? this.excludeSubstituted,
    );
  }
}
