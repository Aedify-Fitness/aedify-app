import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_template_draft.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/core/logging/app_logger.dart';

class SaveProgrammeBuilderDraftUseCase {
  const SaveProgrammeBuilderDraftUseCase({
    required ProgrammeRepository programmeRepository,
  }) : _programmeRepository = programmeRepository;

  static final _logger = AppLogger(name: 'SaveProgrammeBuilderDraftUseCase');

  final ProgrammeRepository _programmeRepository;

  Future<String> save(ProgrammeBuilderDraft builderDraft) async {
    _logger.info(
      'save — name: ${builderDraft.name}, weeks: ${builderDraft.weeks?.length ?? 0}',
    );
    final programmeDraft = _mapToProgrammeDraft(builderDraft);
    return _programmeRepository.saveProgramme(programmeDraft);
  }

  ProgrammeDraft _mapToProgrammeDraft(ProgrammeBuilderDraft builderDraft) {
    return ProgrammeDraft(
      id: builderDraft.id,
      name: builderDraft.name,
      source: builderDraft.source,
      creationMethod: builderDraft.creationMethod,
      status: builderDraft.status,
      active: builderDraft.status == ProgramStatus.active,
      goalTags: builderDraft.goalTags ?? {},
      equipment: builderDraft.equipment ?? {},
      templates: builderDraft.templates != null
          ? _buildTemplates(builderDraft)
          : [],
      description: builderDraft.description,
      weeksTotal: builderDraft.weeks?.length ?? builderDraft.weeksTotal ?? 0,
      daysPerWeek: builderDraft.daysPerWeek ?? _maxSlots(builderDraft.weeks),
      sessionLengthMinutes: builderDraft.sessionLengthMinutes,
      experienceLevelAtCreation: builderDraft.experienceLevelAtCreation,
      preferredUnitsAtCreation: builderDraft.preferredUnitsAtCreation,
      importOrigin: builderDraft.importOrigin,
      startDateLocal: builderDraft.startDateLocal,
      endDateLocal: builderDraft.endDateLocal,
    );
  }

  List<ProgrammeWorkoutTemplateDraft> _buildTemplates(
    ProgrammeBuilderDraft builderDraft,
  ) {
    final seen = <String>{};
    final result = <ProgrammeWorkoutTemplateDraft>[];

    for (final week in builderDraft.weeks ?? []) {
      for (final slot in week.slots ?? []) {
        final t = slot.template;
        if (t != null && seen.add(t.id)) {
          result.add(
            ProgrammeWorkoutTemplateDraft(
              id: t.id,
              templateKey: t.templateKey,
              name: t.name,
              sortOrder: result.length,
              exercises: t.exercises,
              description: t.description,
              dayType: t.dayType,
              estimatedDurationMinutes: t.estimatedDurationMinutes,
            ),
          );
        }
      }
    }

    return result;
  }

  int _maxSlots(List<ProgrammeBuilderWeekDraft>? weeks) {
    if (weeks == null || weeks.isEmpty) return 0;
    int max = 0;
    for (final w in weeks) {
      final count = w.slots?.length ?? 0;
      if (count > max) max = count;
    }
    return max;
  }
}
