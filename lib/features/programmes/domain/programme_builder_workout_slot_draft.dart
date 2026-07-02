import 'package:aedify/shared/domain/training_day.dart';
import 'programme_builder_template_draft.dart';

class ProgrammeBuilderWorkoutSlotDraft {
  const ProgrammeBuilderWorkoutSlotDraft({
    required this.slotIndex,
    required this.scheduledDayIndex,
    this.template,
    this.name,
    this.sortOrder,
    this.scheduledDay,
  });

  final int slotIndex;
  final int scheduledDayIndex;
  final ProgrammeBuilderTemplateDraft? template;
  final String? name;
  final int? sortOrder;
  final TrainingDay? scheduledDay;

  ProgrammeBuilderWorkoutSlotDraft copyWith({
    int? slotIndex,
    int? scheduledDayIndex,
    ProgrammeBuilderTemplateDraft? template,
    String? name,
    int? sortOrder,
    TrainingDay? scheduledDay,
  }) {
    return ProgrammeBuilderWorkoutSlotDraft(
      slotIndex: slotIndex ?? this.slotIndex,
      scheduledDayIndex: scheduledDayIndex ?? this.scheduledDayIndex,
      template: template ?? this.template,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      scheduledDay: scheduledDay ?? this.scheduledDay,
    );
  }
}
