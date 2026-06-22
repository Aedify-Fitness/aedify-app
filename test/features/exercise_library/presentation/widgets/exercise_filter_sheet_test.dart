import 'package:aedify/features/exercise_library/presentation/widgets/exercise_filter_sheet.dart';
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
      expect(ExerciseFilterSheet.muscleGroupOptions, equals(approvedBuckets));
    });
  });
}
