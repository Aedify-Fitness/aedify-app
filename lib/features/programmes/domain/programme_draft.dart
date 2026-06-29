import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/import_origin.dart';
import 'programme_workout_template_draft.dart';

class ProgrammeDraft {
  const ProgrammeDraft({
    required this.id,
    required this.name,
    required this.source,
    required this.creationMethod,
    required this.status,
    required this.active,
    required this.goalTags,
    required this.equipment,
    required this.templates,
    this.description,
    this.importOrigin,
    this.startDateLocal,
    this.endDateLocal,
    this.weeksTotal,
    this.daysPerWeek,
    this.sessionLengthMinutes,
    this.experienceLevelAtCreation,
    this.preferredUnitsAtCreation,
  });

  final String id;
  final String name;
  final WorkoutSource source;
  final CreationMethod creationMethod;
  final ProgramStatus status;
  final bool active;
  final Set<GoalTag> goalTags;
  final Set<EquipmentTag> equipment;
  final List<ProgrammeWorkoutTemplateDraft> templates;
  final String? description;
  final ImportOrigin? importOrigin;
  final String? startDateLocal;
  final String? endDateLocal;
  final int? weeksTotal;
  final int? daysPerWeek;
  final int? sessionLengthMinutes;
  final ExperienceLevel? experienceLevelAtCreation;
  final PreferredUnit? preferredUnitsAtCreation;
}
