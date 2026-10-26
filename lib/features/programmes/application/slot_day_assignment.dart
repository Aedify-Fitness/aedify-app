import 'package:aedify/shared/domain/training_day.dart';

class SlotDayAssignment {
  SlotDayAssignment._();

  static List<TrainingDay> assignDaySlots(
    List<TrainingDay> trainingDays,
    int slotCount,
  ) {
    if (slotCount <= 0 || trainingDays.isEmpty) return [];
    if (slotCount > 7) return [];

    final allDays = TrainingDay.values;
    final anchorSet = trainingDays.toSet();

    final result = <TrainingDay>[];
    for (var i = 0; i < slotCount && i < allDays.length; i++) {
      result.add(allDays[i]);
    }

    final extras = trainingDays
        .where((d) => allDays.indexOf(d) >= slotCount)
        .toList();

    for (final extra in extras) {
      for (var i = slotCount - 1; i >= 0; i--) {
        if (!anchorSet.contains(result[i])) {
          result[i] = extra;
          break;
        }
      }
    }

    result.sort((a, b) => allDays.indexOf(a).compareTo(allDays.indexOf(b)));

    return result;
  }
}
