import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/export_privacy_mode.dart';
import 'package:aedify/shared/domain/import_origin.dart';
import 'package:aedify/shared/domain/import_review_status.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'saved_workout_exercise_draft.dart';

class SavedWorkoutDraft {
  const SavedWorkoutDraft({
    required this.id,
    required this.name,
    required this.source,
    required this.creationMethod,
    required this.status,
    required this.goalTags,
    required this.equipment,
    required this.exercises,
    this.description,
    this.estimatedDurationMinutes,
    this.restBetweenExercisesSeconds,
    this.importOrigin,
    this.importReviewStatus,
    this.exportPrivacyMode,
  });

  final String id;
  final String name;
  final WorkoutSource source;
  final CreationMethod creationMethod;
  final SavedWorkoutStatus status;
  final Set<String> goalTags;
  final Set<EquipmentTag> equipment;
  final List<SavedWorkoutExerciseDraft> exercises;
  final String? description;
  final int? estimatedDurationMinutes;
  final int? restBetweenExercisesSeconds;
  final ImportOrigin? importOrigin;
  final ImportReviewStatus? importReviewStatus;
  final ExportPrivacyMode? exportPrivacyMode;
}
