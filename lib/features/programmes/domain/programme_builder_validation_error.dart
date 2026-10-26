enum ProgrammeBuilderValidationScope { programme, week, workoutSlot, template }

class ProgrammeBuilderValidationError {
  const ProgrammeBuilderValidationError({
    required this.scope,
    required this.code,
    required this.message,
    this.weekIndex,
    this.slotIndex,
    this.templateKey,
  });

  final ProgrammeBuilderValidationScope scope;
  final String code;
  final String message;
  final int? weekIndex;
  final int? slotIndex;
  final String? templateKey;
}
