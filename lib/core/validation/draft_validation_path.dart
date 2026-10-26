class DraftValidationPath {
  const DraftValidationPath({
    this.exerciseId,
    this.setId,
    this.weekIndex,
    this.slotIndex,
    this.templateKey,
  });

  final String? exerciseId;
  final String? setId;
  final int? weekIndex;
  final int? slotIndex;
  final String? templateKey;
}
