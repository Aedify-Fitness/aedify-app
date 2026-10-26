enum EquipmentTag {
  bodyweight,
  dumbbell,
  barbell,
  kettlebell,
  bands,
  cable,
  machine,
  smithMachine,
  pullUpBar,
  bench,
  squatRack,
  cardioMachine,
  ezBar,
  bosuBall,
  medicineBall,
  plate,
  trx,
  vitruvian,
  other;

  String get dbValue {
    return switch (this) {
      EquipmentTag.smithMachine => 'smith_machine',
      EquipmentTag.pullUpBar => 'pull_up_bar',
      EquipmentTag.squatRack => 'squat_rack',
      EquipmentTag.cardioMachine => 'cardio_machine',
      EquipmentTag.ezBar => 'ez_bar',
      EquipmentTag.bosuBall => 'bosu_ball',
      EquipmentTag.medicineBall => 'medicine_ball',
      _ => name,
    };
  }

  static EquipmentTag fromDb(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    return EquipmentTag.values.firstWhere(
      (e) =>
          e.dbValue == normalized ||
          e.dbValue == '${normalized}s' ||
          (normalized.endsWith('s') &&
              !normalized.endsWith('ss') &&
              e.dbValue == normalized.substring(0, normalized.length - 1)),
      orElse: () => EquipmentTag.other,
    );
  }
}
