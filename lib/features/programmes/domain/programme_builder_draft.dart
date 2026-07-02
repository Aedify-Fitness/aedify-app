import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/import_origin.dart';
import 'programme_builder_week_draft.dart';

class ProgrammeBuilderDraft {
  const ProgrammeBuilderDraft({
    required this.id,
    required this.name,
    required this.source,
    required this.creationMethod,
    required this.status,
    this.description,
    this.active = false,
    this.goalTags,
    this.equipment,
    this.weeks,
    this.templates,
    this.weeksTotal,
    this.daysPerWeek,
    this.sessionLengthMinutes,
    this.restBetweenExercisesSeconds,
    this.experienceLevelAtCreation,
    this.preferredUnitsAtCreation,
    this.importOrigin,
    this.startDateLocal,
    this.endDateLocal,
  });

  final String id;
  final String name;
  final WorkoutSource source;
  final CreationMethod creationMethod;
  final ProgramStatus status;
  final String? description;
  final bool active;
  final Set<GoalTag>? goalTags;
  final Set<EquipmentTag>? equipment;
  final List<ProgrammeBuilderWeekDraft>? weeks;
  final List<String>? templates;
  final int? weeksTotal;
  final int? daysPerWeek;
  final int? sessionLengthMinutes;
  final int? restBetweenExercisesSeconds;
  final ExperienceLevel? experienceLevelAtCreation;
  final PreferredUnit? preferredUnitsAtCreation;
  final ImportOrigin? importOrigin;
  final String? startDateLocal;
  final String? endDateLocal;

  ProgrammeBuilderDraft copyWith({
    String? id,
    String? name,
    WorkoutSource? source,
    CreationMethod? creationMethod,
    ProgramStatus? status,
    String? description,
    bool? active,
    Set<GoalTag>? goalTags,
    Set<EquipmentTag>? equipment,
    List<ProgrammeBuilderWeekDraft>? weeks,
    List<String>? templates,
    int? weeksTotal,
    int? daysPerWeek,
    int? sessionLengthMinutes,
    int? restBetweenExercisesSeconds,
    ExperienceLevel? experienceLevelAtCreation,
    PreferredUnit? preferredUnitsAtCreation,
    ImportOrigin? importOrigin,
    String? startDateLocal,
    String? endDateLocal,
  }) {
    return ProgrammeBuilderDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      creationMethod: creationMethod ?? this.creationMethod,
      status: status ?? this.status,
      description: description ?? this.description,
      active: active ?? this.active,
      goalTags: goalTags ?? this.goalTags,
      equipment: equipment ?? this.equipment,
      weeks: weeks ?? this.weeks,
      templates: templates ?? this.templates,
      weeksTotal: weeksTotal ?? this.weeksTotal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
      experienceLevelAtCreation:
          experienceLevelAtCreation ?? this.experienceLevelAtCreation,
      preferredUnitsAtCreation:
          preferredUnitsAtCreation ?? this.preferredUnitsAtCreation,
      importOrigin: importOrigin ?? this.importOrigin,
      startDateLocal: startDateLocal ?? this.startDateLocal,
      endDateLocal: endDateLocal ?? this.endDateLocal,
    );
  }
}
