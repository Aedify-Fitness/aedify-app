import 'package:aedify/shared/domain/saved_workout_status.dart';

class SavedWorkoutListItem {
  const SavedWorkoutListItem({
    required this.id,
    required this.name,
    required this.status,
    required this.exerciseCount,
    required this.updatedAt,
    required this.modalities,
    required this.focus,
    this.description,
    this.estimatedDurationMinutes,
  });

  final String id;
  final String name;
  final SavedWorkoutStatus status;
  final int exerciseCount;
  final DateTime updatedAt;
  final List<String> modalities;
  final String focus;
  final String? description;
  final int? estimatedDurationMinutes;
}
