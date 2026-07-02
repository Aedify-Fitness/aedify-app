import 'package:aedify/shared/domain/week_type.dart';
import 'programme_builder_workout_slot_draft.dart';

class ProgrammeBuilderWeekDraft {
  const ProgrammeBuilderWeekDraft({
    required this.id,
    required this.weekNumber,
    this.slots,
    this.name,
    this.notes,
    this.weekType,
  });

  final String id;
  final int weekNumber;
  final List<ProgrammeBuilderWorkoutSlotDraft>? slots;
  final String? name;
  final String? notes;
  final WeekType? weekType;

  ProgrammeBuilderWeekDraft copyWith({
    String? id,
    int? weekNumber,
    List<ProgrammeBuilderWorkoutSlotDraft>? slots,
    String? name,
    String? notes,
    WeekType? weekType,
  }) {
    return ProgrammeBuilderWeekDraft(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      slots: slots ?? this.slots,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      weekType: weekType ?? this.weekType,
    );
  }
}
