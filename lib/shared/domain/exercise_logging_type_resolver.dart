import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';

class ExerciseLoggingTypeResolver {
  const ExerciseLoggingTypeResolver._();

  static const _repsOnlyEquipment = {
    EquipmentTag.bodyweight,
    EquipmentTag.bands,
    EquipmentTag.pullUpBar,
    EquipmentTag.bosuBall,
    EquipmentTag.medicineBall,
    EquipmentTag.trx,
    EquipmentTag.vitruvian,
  };

  static ExerciseLoggingType resolve({
    required ExerciseModality modality,
    EquipmentTag? equipment,
    ExerciseForce? force,
  }) {
    return switch (modality) {
      ExerciseModality.strength => _resolveStrength(equipment),
      ExerciseModality.flexibility => _resolveFlexibility(force),
      ExerciseModality.cardio => ExerciseLoggingType.duration,
      ExerciseModality.recovery => ExerciseLoggingType.duration,
    };
  }

  static ExerciseLoggingType _resolveStrength(EquipmentTag? equipment) {
    if (equipment != null && _repsOnlyEquipment.contains(equipment)) {
      return ExerciseLoggingType.repsOnly;
    }
    return ExerciseLoggingType.repsWeight;
  }

  static ExerciseLoggingType _resolveFlexibility(ExerciseForce? force) {
    if (force == ExerciseForce.hold) {
      return ExerciseLoggingType.duration;
    }
    return ExerciseLoggingType.repsOnly;
  }
}
