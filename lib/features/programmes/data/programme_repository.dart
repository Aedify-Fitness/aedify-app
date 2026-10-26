import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';

abstract class ProgrammeRepository {
  Future<ProgrammeAggregate?> getProgramme(String id);

  Future<List<ProgrammeAggregate>> listProgrammes({
    String? status,
    bool activeOnly = false,
  });

  Future<String> saveProgramme(ProgrammeDraft draft);

  Future<void> archiveProgramme(String id);

  Future<void> deleteProgramme(String id);

  Future<void> activateProgramme(String id);

  Future<void> deactivateProgramme(String id);

  Future<List<ProgrammeExerciseDraft>> getTemplateExercises(String templateId);
}
