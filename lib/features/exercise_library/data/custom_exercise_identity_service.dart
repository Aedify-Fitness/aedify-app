import 'package:uuid/uuid.dart';

class CustomExerciseIdentityService {
  const CustomExerciseIdentityService();

  static const _uuid = Uuid();

  int nextCustomExerciseId({required Iterable<int> existingIds}) {
    if (existingIds.isEmpty) return -1;
    final lowest = existingIds
        .where((id) => id < 0)
        .fold<int>(0, (prev, id) => id < prev ? id : prev);
    if (lowest == 0) return -1;
    return lowest - 1;
  }

  String newCustomExerciseUuid() => _uuid.v4();
}
