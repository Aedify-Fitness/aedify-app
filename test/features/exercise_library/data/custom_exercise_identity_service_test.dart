import 'package:aedify/features/exercise_library/data/custom_exercise_identity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomExerciseIdentityService', () {
    const service = CustomExerciseIdentityService();

    test(
      'generates next negative custom exercise id when no custom exercises exist',
      () {
        final id = service.nextCustomExerciseId(existingIds: {1, 2, 3});
        expect(id, -1);
      },
    );

    test(
      'generates next negative custom exercise id below existing negative ids',
      () {
        final id = service.nextCustomExerciseId(existingIds: {1, 2, -1});
        expect(id, -2);
      },
    );

    test('negative ids keep decreasing deterministically', () {
      final id1 = service.nextCustomExerciseId(existingIds: {1, 2, -5, -3});
      expect(id1, -6);

      final id2 = service.nextCustomExerciseId(existingIds: {1, 2, -5, -3, -6});
      expect(id2, -7);
    });

    test('handles empty existing ids', () {
      final id = service.nextCustomExerciseId(existingIds: {});
      expect(id, -1);
    });

    test('handles only positive ids', () {
      final id = service.nextCustomExerciseId(existingIds: {10, 20, 30});
      expect(id, -1);
    });

    test('generates UUID for custom exercise', () {
      final uuid = service.newCustomExerciseUuid();
      expect(uuid, isA<String>());
      expect(uuid.split('-').length, 5);
    });

    test('generates unique UUIDs', () {
      final uuid1 = service.newCustomExerciseUuid();
      final uuid2 = service.newCustomExerciseUuid();
      expect(uuid1, isNot(equals(uuid2)));
    });
  });
}
