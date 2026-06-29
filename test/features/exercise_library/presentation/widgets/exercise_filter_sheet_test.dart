import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseFilterSheet muscleGroupOptions', () {
    final approvedBuckets = [
      'Chest',
      'Shoulders',
      'Back',
      'Biceps',
      'Triceps',
      'Forearms',
      'Core',
      'Glutes',
      'Quads',
      'Hamstrings',
      'Calves',
      'Adductors',
      'Neck',
      'Feet',
    ];

    test('muscle group options match 14 approved bodymap buckets', () {
      expect(
        BodymapBucket.values.map((e) => e.label).toList(),
        equals(approvedBuckets),
      );
    });
  });
}
