import 'package:uuid/uuid.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/enum_codec.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/core/logging/app_logger.dart';

class LoadProgrammeBuilderDraftUseCase {
  const LoadProgrammeBuilderDraftUseCase({
    required ProgrammeRepository programmeRepository,
  }) : _programmeRepository = programmeRepository;

  static final _logger = AppLogger(name: 'LoadProgrammeBuilderDraftUseCase');

  final ProgrammeRepository _programmeRepository;

  Future<ProgrammeBuilderDraft> createEmptyDraft() async {
    _logger.debug('createEmptyDraft');
    return ProgrammeBuilderDraft(
      id: const Uuid().v4(),
      name: '',
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: ProgramStatus.inactive,
      weeks: [],
      templates: [],
    );
  }

  Future<ProgrammeBuilderDraft> loadForEdit(String programmeId) async {
    _logger.debug('loadForEdit — id: $programmeId');
    final aggregate = await _programmeRepository.getProgramme(programmeId);
    if (aggregate == null) {
      _logger.error('loadForEdit — programme not found: $programmeId');
      throw Exception(AppErrorStrings.programmeNotFoundWithId(programmeId));
    }

    final program = aggregate.program;

    final templateList = <ProgrammeBuilderTemplateDraft>[];
    for (final t in aggregate.templates) {
      final exercises = await _programmeRepository.getTemplateExercises(t.id);
      templateList.add(
        ProgrammeBuilderTemplateDraft(
          id: t.id,
          templateKey: t.templateKey,
          name: t.name,
          dayType: null,
          exercises: exercises,
        ),
      );
    }

    final templateMap = {for (final t in templateList) t.id: t};

    final weeks = aggregate.weeks.map((w) {
      final weekWorkouts = aggregate.workouts
          .where((wo) => wo.programWeekId == w.id)
          .toList();

      final slots = weekWorkouts.asMap().entries.map((entry) {
        final idx = entry.key;
        final wo = entry.value;
        return ProgrammeBuilderWorkoutSlotDraft(
          slotIndex: idx,
          scheduledDayIndex: wo.scheduledDayIndex ?? 0,
          name: wo.name,
          scheduledDay: wo.scheduledDayIndex != null
              ? TrainingDay.values[wo.scheduledDayIndex!]
              : null,
          template: wo.workoutTemplateId != null
              ? templateMap[wo.workoutTemplateId]
              : null,
        );
      }).toList();

      return ProgrammeBuilderWeekDraft(
        id: w.id,
        weekNumber: w.weekNumber,
        slots: slots,
        name: w.notes,
        weekType: WeekType.fromDb(w.weekType),
      );
    }).toList();

    return ProgrammeBuilderDraft(
      id: program.id,
      name: program.name,
      source: WorkoutSource.fromDb(program.source)!,
      creationMethod: CreationMethod.fromDb(program.creationMethod)!,
      status: ProgramStatus.fromDb(program.status),
      description: program.description,
      active: program.active,
      goalTags: EnumCodec.decodeSet(program.goalTagsJson, GoalTag.fromDb),
      equipment: EnumCodec.decodeSet(
        program.equipmentJson,
        EquipmentTag.fromDb,
      ),
      weeks: weeks,
      templates: templateList.map((t) => t.id).toList(),
      weeksTotal: program.weeksTotal,
      daysPerWeek: program.daysPerWeek,
      sessionLengthMinutes: program.sessionLengthMinutes,
    );
  }

  Future<ProgrammeBuilderDraft> loadDuplicate(String programmeId) async {
    final draft = await loadForEdit(programmeId);
    return draft.copyWith(
      id: const Uuid().v4(),
      name: '${draft.name} (Copy)',
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: ProgramStatus.draft,
      active: false,
    );
  }
}
