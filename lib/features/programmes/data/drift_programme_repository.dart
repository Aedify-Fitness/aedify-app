import 'package:drift/drift.dart' hide TransactionExecutor;
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/program_dao.dart';
import 'package:aedify/core/db/daos/program_workout_template_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_template_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/program_week_dao.dart';
import 'package:aedify/core/db/daos/program_workout_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_dao.dart';
import 'package:aedify/core/db/daos/program_exercise_set_dao.dart';
import 'package:aedify/core/db/daos/program_revision_dao.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_template_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/core/db/transactions/transaction_executor.dart';
import 'package:aedify/core/db/transactions/transaction_operation.dart';
import 'package:aedify/core/db/transactions/transaction_step.dart';
import 'package:aedify/shared/domain/change_type.dart';
import 'package:aedify/shared/domain/enum_codec.dart';
import 'package:aedify/shared/domain/exercise_role.dart';
import 'package:aedify/shared/domain/loading_model.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/weight_prescription_type.dart';
import 'package:aedify/core/logging/app_logger.dart';

class DriftProgrammeRepository implements ProgrammeRepository {
  DriftProgrammeRepository({
    required ProgramDao programDao,
    required ProgramWorkoutTemplateDao programWorkoutTemplateDao,
    required ProgramTemplateExerciseDao programTemplateExerciseDao,
    required ProgramTemplateExerciseSetDao programTemplateExerciseSetDao,
    required ProgramWeekDao programWeekDao,
    required ProgramWorkoutDao programWorkoutDao,
    required ProgramExerciseDao programExerciseDao,
    required ProgramExerciseSetDao programExerciseSetDao,
    required ProgramRevisionDao programRevisionDao,
    required TransactionExecutor transactionExecutor,
    Uuid? uuid,
  }) : _programDao = programDao,
       _programWorkoutTemplateDao = programWorkoutTemplateDao,
       _programTemplateExerciseDao = programTemplateExerciseDao,
       _programTemplateExerciseSetDao = programTemplateExerciseSetDao,
       _programWeekDao = programWeekDao,
       _programWorkoutDao = programWorkoutDao,
       _programExerciseDao = programExerciseDao,
       _programExerciseSetDao = programExerciseSetDao,
       _programRevisionDao = programRevisionDao,
       _transactionExecutor = transactionExecutor,
       _uuid = uuid ?? const Uuid();

  static final _logger = AppLogger(name: 'DriftProgrammeRepository');

  final ProgramDao _programDao;
  final ProgramWorkoutTemplateDao _programWorkoutTemplateDao;
  final ProgramTemplateExerciseDao _programTemplateExerciseDao;
  final ProgramTemplateExerciseSetDao _programTemplateExerciseSetDao;
  final ProgramWeekDao _programWeekDao;
  final ProgramWorkoutDao _programWorkoutDao;
  final ProgramExerciseDao _programExerciseDao;
  final ProgramExerciseSetDao _programExerciseSetDao;
  final ProgramRevisionDao _programRevisionDao;
  final TransactionExecutor _transactionExecutor;
  final Uuid _uuid;

  @override
  Future<ProgrammeAggregate?> getProgramme(String id) async {
    _logger.info('getProgramme — id: $id');
    final program = await _programDao.getById(id);
    if (program == null) return null;
    return _buildAggregate(program);
  }

  @override
  Future<List<ProgrammeAggregate>> listProgrammes({
    String? status,
    bool activeOnly = false,
  }) async {
    _logger.info('listProgrammes — status: $status, activeOnly: $activeOnly');
    final programs = status != null
        ? await _programDao.getByStatus(status)
        : await _programDao.getAll();

    final results = <ProgrammeAggregate>[];
    for (final p in programs) {
      if (activeOnly && !p.active) continue;
      results.add(await _buildAggregate(p));
    }
    return results;
  }

  @override
  Future<String> saveProgramme(ProgrammeDraft draft) async {
    _logger.info('saveProgramme — name: ${draft.name}');
    final programId = draft.id;
    final now = DateTime.now();
    final existing = await _programDao.getById(programId);

    _logger.info('saveProgramme — starting transaction');
    await _transactionExecutor.execute(
      operationName: 'programme.save',
      steps: _buildSaveProgrammeSteps(
        draft: draft,
        programId: programId,
        now: now,
        existing: existing,
      ),
    );

    _logger.info('saveProgramme — success: $programId');
    return programId;
  }

  @override
  Future<void> archiveProgramme(String id) async {
    final now = DateTime.now();
    await _programDao.archiveProgram(id: id, archivedAt: now, updatedAt: now);
  }

  @override
  Future<void> deleteProgramme(String id) async {
    final hasHistory = await _programDao.countSessionsReferencingProgram(id);
    if (hasHistory > 0) {
      final now = DateTime.now();
      await _programDao.softDeleteProgram(
        id: id,
        deletedAt: now,
        updatedAt: now,
      );
    } else {
      await _transactionExecutor.execute(
        operationName: 'programme.delete',
        steps: _buildDeleteProgrammeSteps(id: id),
      );
    }
  }

  Future<void> _deleteProgramRevisions(String programId) async {
    await _programRevisionDao.deleteByProgramId(programId);
  }

  List<TransactionStep> _buildSaveProgrammeSteps({
    required ProgrammeDraft draft,
    required String programId,
    required DateTime now,
    required Program? existing,
  }) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'programme.write_root'),
        run: () => _writeProgramRoot(
          draft: draft,
          programId: programId,
          now: now,
          existingProgram: existing,
        ),
      ),
      if (draft.active)
        TransactionStep(
          operation: const TransactionOperation(name: 'programme.clear_active'),
          run: () async {
            await _programDao.clearActiveProgram(updatedAt: now);
            await _programDao.setProgramActive(
              id: programId,
              active: true,
              updatedAt: now,
            );
          },
        ),
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.delete_expanded',
        ),
        run: () async {
          await _deleteExpandedProgramHierarchy(programId);
          await _deleteProgramTemplateHierarchy(programId);
        },
      ),
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.insert_templates',
        ),
        run: () async {
          for (final template in draft.templates) {
            await _insertProgramTemplate(
              programId: programId,
              template: template,
              now: now,
            );
          }
        },
      ),
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.insert_expanded',
        ),
        run: () => _insertExpandedProgramRows(
          programId: programId,
          draft: draft,
          now: now,
        ),
      ),
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.insert_revision',
        ),
        run: () async {
          final latestRevision = await _programRevisionDao
              .getLatestRevisionNumber(programId);
          await _programRevisionDao.upsertRevision(
            ProgramRevisionsCompanion.insert(
              id: _newId(),
              programId: programId,
              revisionNumber: latestRevision + 1,
              changeType: existing == null
                  ? ChangeType.created.dbValue
                  : ChangeType.manualEdit.dbValue,
              summary: existing == null ? 'Program created' : 'Program updated',
              createdAt: now,
            ),
          );
        },
      ),
    ];
  }

  List<TransactionStep> _buildDeleteProgrammeSteps({required String id}) {
    return [
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.delete_expanded',
        ),
        run: () async {
          await _deleteExpandedProgramHierarchy(id);
          await _deleteProgramTemplateHierarchy(id);
        },
      ),
      TransactionStep(
        operation: const TransactionOperation(
          name: 'programme.delete_revisions',
        ),
        run: () => _deleteProgramRevisions(id),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'programme.soft_delete'),
        run: () {
          final now = DateTime.now();
          return _programDao.softDeleteProgram(
            id: id,
            deletedAt: now,
            updatedAt: now,
          );
        },
      ),
    ];
  }

  List<TransactionStep> _buildActivateProgrammeSteps({
    required String programId,
    required DateTime now,
  }) {
    return [
      TransactionStep(
        operation: const TransactionOperation(name: 'programme.clear_active'),
        run: () => _programDao.clearActiveProgram(updatedAt: now),
      ),
      TransactionStep(
        operation: const TransactionOperation(name: 'programme.set_active'),
        run: () => _programDao.setProgramActive(
          id: programId,
          active: true,
          updatedAt: now,
        ),
      ),
    ];
  }

  @override
  Future<void> activateProgramme(String id) async {
    final now = DateTime.now();
    await _transactionExecutor.execute(
      operationName: 'programme.activate',
      steps: _buildActivateProgrammeSteps(programId: id, now: now),
    );
  }

  @override
  Future<void> deactivateProgramme(String id) async {
    final now = DateTime.now();
    await _programDao.setProgramActive(id: id, active: false, updatedAt: now);
  }

  Future<ProgrammeAggregate> _buildAggregate(Program program) async {
    final templates = await _programWorkoutTemplateDao.getByProgramIdOrdered(
      program.id,
    );
    final weeks = await _programWeekDao.getByProgramIdOrdered(program.id);
    final workouts = await _programWorkoutDao.getByProgramId(program.id);

    final allExercises = <ProgramExercise>[];
    final allSets = <ProgramExerciseSet>[];
    for (final w in workouts) {
      final exercises = await _programExerciseDao.getByProgramWorkoutIdOrdered(
        w.id,
      );
      for (final e in exercises) {
        final sets = await _programExerciseSetDao.getByProgramExerciseIdOrdered(
          e.id,
        );
        allExercises.add(e);
        allSets.addAll(sets);
      }
    }

    final revisions = await _programRevisionDao.getByProgramIdOrdered(
      program.id,
    );

    return ProgrammeAggregate(
      program: program,
      templates: templates,
      weeks: weeks,
      workouts: workouts,
      exercises: allExercises,
      sets: allSets,
      revisions: revisions,
    );
  }

  Future<void> _writeProgramRoot({
    required ProgrammeDraft draft,
    required String programId,
    required DateTime now,
    required Program? existingProgram,
  }) async {
    final createdAt = existingProgram?.createdAt ?? now;
    await _programDao.upsertProgram(
      _buildProgramCompanion(
        draft: draft,
        programId: programId,
        now: now,
        createdAt: createdAt,
      ),
    );
  }

  Future<void> _deleteProgramTemplateHierarchy(String programId) async {
    final templates = await _programWorkoutTemplateDao.getByProgramIdOrdered(
      programId,
    );
    for (final t in templates) {
      final exercises = await _programTemplateExerciseDao
          .getByTemplateIdOrdered(t.id);
      for (final e in exercises) {
        await _programTemplateExerciseSetDao.deleteByTemplateExerciseId(e.id);
      }
      await _programTemplateExerciseDao.deleteByTemplateId(t.id);
    }
    await _programWorkoutTemplateDao.deleteByProgramId(programId);
  }

  Future<void> _deleteExpandedProgramHierarchy(String programId) async {
    final workouts = await _programWorkoutDao.getByProgramId(programId);
    for (final w in workouts) {
      final exercises = await _programExerciseDao.getByProgramWorkoutIdOrdered(
        w.id,
      );
      for (final e in exercises) {
        await _programExerciseSetDao.deleteByProgramExerciseId(e.id);
      }
      await _programExerciseDao.deleteByProgramWorkoutId(w.id);
    }
    await _programWorkoutDao.deleteByProgramId(programId);
    await _programWeekDao.deleteByProgramId(programId);
  }

  Future<void> _insertProgramTemplate({
    required String programId,
    required ProgrammeWorkoutTemplateDraft template,
    required DateTime now,
  }) async {
    await _programWorkoutTemplateDao.upsertTemplate(
      _buildProgramWorkoutTemplateCompanion(
        programId: programId,
        template: template,
        now: now,
      ),
    );

    for (final exercise in template.exercises) {
      await _insertProgramTemplateExercise(
        workoutTemplateId: template.id,
        exercise: exercise,
        now: now,
      );
    }
  }

  Future<void> _insertProgramTemplateExercise({
    required String workoutTemplateId,
    required ProgrammeExerciseDraft exercise,
    required DateTime now,
  }) async {
    await _programTemplateExerciseDao.upsertExercise(
      _buildProgramTemplateExerciseCompanion(
        workoutTemplateId: workoutTemplateId,
        exercise: exercise,
        now: now,
      ),
    );

    for (final prescription in exercise.sets) {
      await _insertProgramTemplateExerciseSet(
        templateExerciseId: exercise.id,
        prescription: prescription,
        now: now,
      );
    }
  }

  Future<void> _insertProgramTemplateExerciseSet({
    required String templateExerciseId,
    required SetPrescriptionDraft prescription,
    required DateTime now,
  }) async {
    await _programTemplateExerciseSetDao.upsertSet(
      _buildProgramTemplateExerciseSetCompanion(
        templateExerciseId: templateExerciseId,
        prescription: prescription,
        now: now,
      ),
    );
  }

  Future<void> _insertExpandedProgramRows({
    required String programId,
    required ProgrammeDraft draft,
    required DateTime now,
  }) async {
    if (draft.weeksTotal == null || draft.weeksTotal! < 1) return;

    for (var weekNum = 1; weekNum <= draft.weeksTotal!; weekNum++) {
      final weekId = _newId();
      final weekType =
          draft.weekTypes != null && weekNum - 1 < draft.weekTypes!.length
          ? draft.weekTypes![weekNum - 1]?.dbValue
          : null;
      await _programWeekDao.upsertWeek(
        _buildProgramWeekCompanion(
          programId: programId,
          weekId: weekId,
          weekNumber: weekNum,
          now: now,
          weekType: weekType,
        ),
      );

      final weekIdx = weekNum - 1;
      final templateMap = {for (final t in draft.templates) t.id: t};
      if (draft.weekSlotDayIndices != null &&
          weekIdx < draft.weekSlotDayIndices!.length &&
          draft.weekSlotDayIndices![weekIdx].isNotEmpty) {
        final weekDayIndices = draft.weekSlotDayIndices![weekIdx];
        final weekTemplateIds =
            draft.weekSlotTemplateIds != null &&
                weekIdx < draft.weekSlotTemplateIds!.length
            ? draft.weekSlotTemplateIds![weekIdx]
            : <String>[];
        for (var slotIdx = 0; slotIdx < weekDayIndices.length; slotIdx++) {
          final dayIndex = weekDayIndices[slotIdx];
          final templateId = slotIdx < weekTemplateIds.length
              ? weekTemplateIds[slotIdx]
              : null;
          final template = templateId != null ? templateMap[templateId] : null;
          if (template == null) continue;
          await _insertExpandedWorkout(
            programId: programId,
            weekId: weekId,
            weekNum: weekNum,
            slotIdx: slotIdx,
            dayIndex: dayIndex,
            template: template,
            now: now,
          );
        }
      } else if (draft.slotDayIndices != null &&
          draft.slotDayIndices!.isNotEmpty) {
        final slotTemplateIds = draft.slotTemplateIds ?? [];
        for (
          var slotIdx = 0;
          slotIdx < draft.slotDayIndices!.length;
          slotIdx++
        ) {
          final dayIndex = draft.slotDayIndices![slotIdx];
          final templateId = slotIdx < slotTemplateIds.length
              ? slotTemplateIds[slotIdx]
              : null;
          final template = templateId != null ? templateMap[templateId] : null;
          if (template == null) continue;
          await _insertExpandedWorkout(
            programId: programId,
            weekId: weekId,
            weekNum: weekNum,
            slotIdx: slotIdx,
            dayIndex: dayIndex,
            template: template,
            now: now,
          );
        }
      } else {
        for (var dayIdx = 0; dayIdx < (draft.daysPerWeek ?? 0); dayIdx++) {
          if (dayIdx < draft.templates.length) {
            await _insertExpandedWorkout(
              programId: programId,
              weekId: weekId,
              weekNum: weekNum,
              slotIdx: dayIdx,
              dayIndex: dayIdx,
              template: draft.templates[dayIdx],
              now: now,
            );
          }
        }
      }
    }
  }

  Future<void> _insertExpandedWorkout({
    required String programId,
    required String weekId,
    required int weekNum,
    required int slotIdx,
    required int dayIndex,
    required ProgrammeWorkoutTemplateDraft template,
    required DateTime now,
  }) async {
    final workoutId = _newId();
    final occurrenceRef = 'w${weekNum}_s$slotIdx';

    await _programWorkoutDao.upsertWorkout(
      _buildProgramWorkoutCompanion(
        programId: programId,
        workoutId: workoutId,
        occurrenceRef: occurrenceRef,
        name: template.name,
        now: now,
        programWeekId: weekId,
        workoutTemplateId: template.id,
        scheduledDayIndex: dayIndex,
      ),
    );

    final templateExercises = await _programTemplateExerciseDao
        .getByTemplateIdOrdered(template.id);
    for (final te in templateExercises) {
      final exerciseId = _newId();
      await _programExerciseDao.upsertExercise(
        ProgramExercisesCompanion(
          id: Value(exerciseId),
          programWorkoutId: Value(workoutId),
          sourceTemplateExerciseId: Value(te.id),
          exerciseId: Value(te.exerciseId),
          exerciseRole: Value(te.exerciseRole),
          supersetGroupId: Value(te.supersetGroupId),
          supersetOrder: Value(te.supersetOrder),
          sortOrder: Value(te.sortOrder),
          notes: Value(te.notes),
        ),
      );

      final templateSets = await _programTemplateExerciseSetDao
          .getByTemplateExerciseIdOrdered(te.id);
      for (final ts in templateSets) {
        await _programExerciseSetDao.upsertSet(
          ProgramExerciseSetsCompanion(
            id: Value(_newId()),
            programExerciseId: Value(exerciseId),
            sourceTemplateSetId: Value(ts.id),
            setIndex: Value(ts.setIndex),
            setType: Value(ts.setType),
            setIntent: Value(ts.setIntent),
            prescribedRepsMin: Value(ts.prescribedRepsMin),
            prescribedRepsMax: Value(ts.prescribedRepsMax),
            prescribedRepsExact: Value(ts.prescribedRepsExact),
            durationSeconds: Value(ts.durationSeconds),
            distanceMeters: Value(ts.distanceMeters),
            weightPrescriptionType: Value(ts.weightPrescriptionType),
            prescribedWeightKg: Value(ts.prescribedWeightKg),
            prescribedWeightPct1rm: Value(ts.prescribedWeightPct1rm),
            prescribedWeightPctWorking: Value(ts.prescribedWeightPctWorking),
            bodyweightMultiplier: Value(ts.bodyweightMultiplier),
            prescribedRpeMin: Value(ts.prescribedRpeMin),
            prescribedRpeMax: Value(ts.prescribedRpeMax),
            prescribedRir: Value(ts.prescribedRir),
            restSeconds: Value(ts.restSeconds),
            loadingModel: Value(ts.loadingModel),
            percent1rmMin: Value(ts.percent1rmMin),
            percent1rmMax: Value(ts.percent1rmMax),
            rpeMin: Value(ts.rpeMin),
            rpeMax: Value(ts.rpeMax),
            loadSelectionNote: Value(ts.loadSelectionNote),
            isCalibrationEstimate: Value(ts.isCalibrationEstimate),
            derivedFromWorkingSetIndex: Value(ts.derivedFromWorkingSetIndex),
            warmupWeightRuleJson: Value(ts.warmupWeightRuleJson),
            createdAt: Value(now),
          ),
        );
      }
    }
  }

  // --- Companion builders ---

  ProgramsCompanion _buildProgramCompanion({
    required ProgrammeDraft draft,
    required String programId,
    required DateTime now,
    required DateTime createdAt,
  }) {
    return ProgramsCompanion(
      id: Value(programId),
      name: Value(draft.name),
      description: Value(draft.description),
      source: Value(draft.source.dbValue),
      creationMethod: Value(draft.creationMethod.dbValue),
      importOrigin: Value(draft.importOrigin?.dbValue),
      status: Value(draft.status.dbValue),
      active: Value(draft.active),
      startDateLocal: Value(draft.startDateLocal),
      endDateLocal: Value(draft.endDateLocal),
      weeksTotal: Value(draft.weeksTotal),
      daysPerWeek: Value(draft.daysPerWeek),
      sessionLengthMinutes: Value(draft.sessionLengthMinutes),
      goalTagsJson: Value(
        EnumCodec.encodeSet(draft.goalTags, (value) => value.dbValue),
      ),
      equipmentJson: Value(
        EnumCodec.encodeSet(draft.equipment, (value) => value.dbValue),
      ),
      experienceLevelAtCreation: Value(
        draft.experienceLevelAtCreation?.dbValue,
      ),
      preferredUnitsAtCreation: Value(draft.preferredUnitsAtCreation?.dbValue),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
    );
  }

  ProgramWorkoutTemplatesCompanion _buildProgramWorkoutTemplateCompanion({
    required String programId,
    required ProgrammeWorkoutTemplateDraft template,
    required DateTime now,
  }) {
    return ProgramWorkoutTemplatesCompanion(
      id: Value(template.id),
      programId: Value(programId),
      templateKey: Value(template.templateKey),
      name: Value(template.name),
      description: Value(template.description),
      dayType: Value(template.dayType?.dbValue),
      estimatedDurationMinutes: Value(template.estimatedDurationMinutes),
      sortOrder: Value(template.sortOrder),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  ProgramTemplateExercisesCompanion _buildProgramTemplateExerciseCompanion({
    required String workoutTemplateId,
    required ProgrammeExerciseDraft exercise,
    required DateTime now,
  }) {
    return ProgramTemplateExercisesCompanion(
      id: Value(exercise.id),
      workoutTemplateId: Value(workoutTemplateId),
      exerciseId: Value(exercise.exerciseId),
      exerciseRef: Value(exercise.exerciseRef),
      exerciseRole: Value(exercise.exerciseRole?.dbValue),
      programmeRole: Value(exercise.programmeRole),
      supersetGroupId: Value(exercise.supersetGroupId),
      supersetOrder: Value(exercise.supersetOrder),
      sortOrder: Value(exercise.sortOrder),
      notes: Value(exercise.notes),
      cuesJson: Value(exercise.cuesJson),
      createdAt: Value(now),
    );
  }

  ProgramTemplateExerciseSetsCompanion
  _buildProgramTemplateExerciseSetCompanion({
    required String templateExerciseId,
    required SetPrescriptionDraft prescription,
    required DateTime now,
  }) {
    return ProgramTemplateExerciseSetsCompanion(
      id: Value(prescription.id),
      templateExerciseId: Value(templateExerciseId),
      setIndex: Value(prescription.setIndex),
      setType: Value(prescription.setType.dbValue),
      setIntent: Value(prescription.setIntent?.dbValue),
      prescribedRepsMin: Value(prescription.prescribedRepsMin),
      prescribedRepsMax: Value(prescription.prescribedRepsMax),
      prescribedRepsExact: Value(prescription.prescribedRepsExact),
      durationSeconds: Value(prescription.durationSeconds),
      distanceMeters: Value(prescription.distanceMeters),
      weightPrescriptionType: Value(
        prescription.weightPrescriptionType?.dbValue,
      ),
      prescribedWeightKg: Value(prescription.prescribedWeightKg),
      prescribedWeightPct1rm: Value(prescription.prescribedWeightPct1rm),
      prescribedWeightPctWorking: Value(
        prescription.prescribedWeightPctWorking,
      ),
      bodyweightMultiplier: Value(prescription.bodyweightMultiplier),
      prescribedRpeMin: Value(prescription.prescribedRpeMin),
      prescribedRpeMax: Value(prescription.prescribedRpeMax),
      prescribedRir: Value(prescription.prescribedRir),
      restSeconds: Value(prescription.restSeconds),
      loadingModel: Value(prescription.loadingModel?.dbValue),
      percent1rmMin: Value(prescription.percent1rmMin),
      percent1rmMax: Value(prescription.percent1rmMax),
      rpeMin: Value(prescription.rpeMin),
      rpeMax: Value(prescription.rpeMax),
      loadSelectionNote: Value(prescription.loadSelectionNote),
      isCalibrationEstimate: Value(prescription.isCalibrationEstimate),
      derivedFromWorkingSetIndex: Value(
        prescription.derivedFromWorkingSetIndex,
      ),
      warmupWeightRuleJson: Value(prescription.warmupWeightRuleJson),
      createdAt: Value(now),
    );
  }

  ProgramWeeksCompanion _buildProgramWeekCompanion({
    required String programId,
    required String weekId,
    required int weekNumber,
    required DateTime now,
    String? weekType,
    String? startsOnLocal,
    String? notes,
  }) {
    return ProgramWeeksCompanion(
      id: Value(weekId),
      programId: Value(programId),
      weekNumber: Value(weekNumber),
      weekType: Value(weekType),
      startsOnLocal: Value(startsOnLocal),
      notes: Value(notes),
    );
  }

  ProgramWorkoutsCompanion _buildProgramWorkoutCompanion({
    required String programId,
    required String workoutId,
    required String occurrenceRef,
    required String name,
    required DateTime now,
    String? programWeekId,
    String? workoutTemplateId,
    String? scheduledDateLocal,
    int? scheduledDayIndex,
    String status = 'planned',
  }) {
    return ProgramWorkoutsCompanion(
      id: Value(workoutId),
      programId: Value(programId),
      programWeekId: Value(programWeekId),
      workoutTemplateId: Value(workoutTemplateId),
      occurrenceRef: Value(occurrenceRef),
      name: Value(name),
      scheduledDateLocal: Value(scheduledDateLocal),
      scheduledDayIndex: Value(scheduledDayIndex),
      status: Value(status),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  String _newId() => _uuid.v4();

  @override
  Future<List<ProgrammeExerciseDraft>> getTemplateExercises(
    String templateId,
  ) async {
    final rows = await _programTemplateExerciseDao.getByTemplateIdOrdered(
      templateId,
    );
    final results = <ProgrammeExerciseDraft>[];
    for (final row in rows) {
      final sets = await _programTemplateExerciseSetDao
          .getByTemplateExerciseIdOrdered(row.id);
      results.add(
        ProgrammeExerciseDraft(
          id: row.id,
          exerciseId: row.exerciseId,
          sortOrder: row.sortOrder,
          sets: sets.map(_mapTemplateSetToDraft).toList(),
          exerciseRef: row.exerciseRef,
          exerciseRole: ExerciseRole.fromDb(row.exerciseRole),
          programmeRole: row.programmeRole,
          supersetGroupId: row.supersetGroupId,
          supersetOrder: row.supersetOrder,
          notes: row.notes,
          cuesJson: row.cuesJson,
        ),
      );
    }
    return results;
  }

  SetPrescriptionDraft _mapTemplateSetToDraft(ProgramTemplateExerciseSet s) {
    return SetPrescriptionDraft(
      id: s.id,
      setIndex: s.setIndex,
      setType: SetType.fromDb(s.setType),
      setIntent: SetIntent.fromDb(s.setIntent),
      prescribedRepsMin: s.prescribedRepsMin,
      prescribedRepsMax: s.prescribedRepsMax,
      prescribedRepsExact: s.prescribedRepsExact,
      durationSeconds: s.durationSeconds,
      distanceMeters: s.distanceMeters,
      weightPrescriptionType: WeightPrescriptionType.fromDb(
        s.weightPrescriptionType,
      ),
      prescribedWeightKg: s.prescribedWeightKg,
      prescribedWeightPct1rm: s.prescribedWeightPct1rm,
      prescribedWeightPctWorking: s.prescribedWeightPctWorking,
      bodyweightMultiplier: s.bodyweightMultiplier,
      prescribedRpeMin: s.prescribedRpeMin,
      prescribedRpeMax: s.prescribedRpeMax,
      prescribedRir: s.prescribedRir,
      restSeconds: s.restSeconds,
      loadingModel: LoadingModel.fromDb(s.loadingModel),
      percent1rmMin: s.percent1rmMin,
      percent1rmMax: s.percent1rmMax,
      rpeMin: s.rpeMin,
      rpeMax: s.rpeMax,
      loadSelectionNote: s.loadSelectionNote,
      isCalibrationEstimate: s.isCalibrationEstimate,
      derivedFromWorkingSetIndex: s.derivedFromWorkingSetIndex,
      warmupWeightRuleJson: s.warmupWeightRuleJson,
    );
  }
}
