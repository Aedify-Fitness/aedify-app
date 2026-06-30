import 'package:aedify/core/validation/validated_programme_slot_draft.dart';

class ValidatedProgrammeWeekDraft {
  const ValidatedProgrammeWeekDraft({
    required this.weekNumber,
    required this.slots,
  });

  final int weekNumber;
  final List<ValidatedProgrammeSlotDraft> slots;
}
