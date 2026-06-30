import 'programme_builder_workout_slot_draft.dart';

class ProgrammeBuilderWeekDraft {
  const ProgrammeBuilderWeekDraft({
    required this.id,
    required this.weekNumber,
    this.slots,
    this.name,
    this.notes,
  });

  final String id;
  final int weekNumber;
  final List<ProgrammeBuilderWorkoutSlotDraft>? slots;
  final String? name;
  final String? notes;

  ProgrammeBuilderWeekDraft copyWith({
    String? id,
    int? weekNumber,
    List<ProgrammeBuilderWorkoutSlotDraft>? slots,
    String? name,
    String? notes,
  }) {
    return ProgrammeBuilderWeekDraft(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      slots: slots ?? this.slots,
      name: name ?? this.name,
      notes: notes ?? this.notes,
    );
  }
}
