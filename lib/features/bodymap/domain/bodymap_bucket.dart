enum BodymapBucket {
  chest('Chest'),
  shoulders('Shoulders'),
  back('Back'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Forearms'),
  core('Core'),
  glutes('Glutes'),
  quads('Quads'),
  hamstrings('Hamstrings'),
  calves('Calves'),
  adductors('Adductors'),
  neck('Neck'),
  feet('Feet');

  final String label;
  const BodymapBucket(this.label);
}
