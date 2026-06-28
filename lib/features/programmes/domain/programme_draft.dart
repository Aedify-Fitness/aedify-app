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
  final String source;
  final String creationMethod;
  final String status;
  final bool active;
  final List<String> goalTags;
  final List<String> equipment;
  final List<ProgrammeWorkoutTemplateDraft> templates;
  final String? description;
  final String? importOrigin;
  final String? startDateLocal;
  final String? endDateLocal;
  final int? weeksTotal;
  final int? daysPerWeek;
  final int? sessionLengthMinutes;
  final String? experienceLevelAtCreation;
  final String? preferredUnitsAtCreation;
}
