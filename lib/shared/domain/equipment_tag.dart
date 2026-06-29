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
  other;

  String get dbValue {
    return switch (this) {
      EquipmentTag.smithMachine => 'smith_machine',
      EquipmentTag.pullUpBar => 'pull_up_bar',
      EquipmentTag.squatRack => 'squat_rack',
      EquipmentTag.cardioMachine => 'cardio_machine',
      EquipmentTag.ezBar => 'ez_bar',
      _ => name,
    };
  }

  static EquipmentTag fromDb(String value) {
    return EquipmentTag.values.firstWhere((e) => e.dbValue == value);
  }
}
