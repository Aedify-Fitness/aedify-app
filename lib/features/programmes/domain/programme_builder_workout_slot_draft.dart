import 'programme_builder_template_draft.dart';

class ProgrammeBuilderWorkoutSlotDraft {
  const ProgrammeBuilderWorkoutSlotDraft({
    required this.slotIndex,
    required this.scheduledDayIndex,
    this.template,
    this.name,
    this.sortOrder,
  });

  final int slotIndex;
  final int scheduledDayIndex;
  final ProgrammeBuilderTemplateDraft? template;
  final String? name;
  final int? sortOrder;

  ProgrammeBuilderWorkoutSlotDraft copyWith({
    int? slotIndex,
    int? scheduledDayIndex,
    ProgrammeBuilderTemplateDraft? template,
    String? name,
    int? sortOrder,
  }) {
    return ProgrammeBuilderWorkoutSlotDraft(
      slotIndex: slotIndex ?? this.slotIndex,
      scheduledDayIndex: scheduledDayIndex ?? this.scheduledDayIndex,
      template: template ?? this.template,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
