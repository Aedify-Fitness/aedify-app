import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_exercise_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_save_request.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/core/logging/app_logger.dart';

class WorkoutBuilderController extends AsyncNotifier<WorkoutBuilderState> {
  WorkoutBuilderController(this.mode, this.savedWorkoutId);

  static final _logger = AppLogger(name: 'WorkoutBuilderController');

  final WorkoutBuilderMode mode;
  final String? savedWorkoutId;

  @override
  Future<WorkoutBuilderState> build() async {
    _logger.info('build — mode: $mode');
    final loadUseCase = ref.read(AppProviders.loadWorkoutDraftUseCaseProvider);

    if (mode == WorkoutBuilderMode.create) {
      final draft = await loadUseCase.createEmptyDraft();
      return WorkoutBuilderState(
        mode: WorkoutBuilderMode.create,
        phase: WorkoutBuilderPhase.editing,
        draft: draft,
        validationErrors: [],
        isDirty: false,
      );
    }

    if (savedWorkoutId == null) {
      return WorkoutBuilderState.initial();
    }

    try {
      final draft = await loadUseCase.loadForEdit(savedWorkoutId!);
      return WorkoutBuilderState(
        mode: WorkoutBuilderMode.edit,
        phase: WorkoutBuilderPhase.editing,
        draft: draft,
        validationErrors: [],
        isDirty: false,
        savedWorkoutId: savedWorkoutId,
      );
    } catch (e) {
      return WorkoutBuilderState(
        mode: WorkoutBuilderMode.edit,
        phase: WorkoutBuilderPhase.failure,
        draft: WorkoutBuilderDraft(
          id: '',
          name: '',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: SavedWorkoutStatus.active,
          goalTags: [],
          equipment: [],
          exercises: [],
        ),
        validationErrors: [
          WorkoutBuilderValidationError(
            scope: WorkoutBuilderValidationScope.workout,
            code: AppErrorCodes.loadFailed,
            message: AppStrings.workoutLoadFailed,
          ),
        ],
        isDirty: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.workoutLoadFailed,
      );
    }
  }

  Future<void> updateExerciseRest(
    String exerciseDraftId,
    int? restSeconds,
  ) async {
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises.map((e) {
      if (e.id != exerciseDraftId) return e;
      return e.copyWith(restBetweenExercisesSeconds: restSeconds);
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> renameWorkout(String value) async {
    _logger.debug('renameWorkout — $value');
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(name: value),
        isDirty: true,
      ),
    );
  }

  Future<void> updateRestBetweenExercises(int? restSeconds) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(restBetweenExercisesSeconds: restSeconds),
        isDirty: true,
      ),
    );
  }

  Future<void> updateDescription(String? value) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(description: value),
        isDirty: true,
      ),
    );
  }

  Future<void> addExercise(ExerciseReference exercise) async {
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises;
    _logger.debug(
      'addExercise — ${exercise.name}, count: ${exercises.length + 1}',
    );
    final newExercise = WorkoutBuilderExerciseDraft(
      id: _newId(),
      exercise: exercise,
      sortOrder: exercises.length,
      sets: [
        SetPrescriptionDraft(
          id: _newId(),
          setIndex: 0,
          setType: SetType.working,
        ),
      ],
    );
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: [...exercises, newExercise]),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> removeExercise(String exerciseDraftId) async {
    _logger.debug('removeExercise — $exerciseDraftId');
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises
        .where((e) => e.id != exerciseDraftId)
        .toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: _reindexExercises(exercises)),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> duplicateExercise(String exerciseDraftId) async {
    final current = state.asData?.value;
    if (current == null) return;
    final index = current.draft.exercises.indexWhere(
      (e) => e.id == exerciseDraftId,
    );
    if (index == -1) return;

    final source = current.draft.exercises[index];
    final duplicate = WorkoutBuilderExerciseDraft(
      id: _newId(),
      exercise: source.exercise,
      sortOrder: source.sortOrder + 1,
      exerciseRole: source.exerciseRole,
      supersetGroupId: source.supersetGroupId,
      supersetOrder: source.supersetOrder,
      notes: source.notes,
      sets: source.sets.map((s) => s.copyWith(id: _newId())).toList(),
    );

    final exercises = [...current.draft.exercises];
    exercises.insert(index + 1, duplicate);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: _reindexExercises(exercises)),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = [...current.draft.exercises];
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: _reindexExercises(exercises)),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> addSet(
    String exerciseDraftId, {
    SetType setType = SetType.working,
  }) async {
    _logger.debug('addSet — exercise: $exerciseDraftId, setType: $setType');
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises.map((e) {
      if (e.id != exerciseDraftId) return e;
      final sets = [
        ...e.sets,
        SetPrescriptionDraft(
          id: _newId(),
          setIndex: e.sets.length,
          setType: setType,
        ),
      ];

      return e.copyWith(sets: _reindexSets(sets));
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> addWarmupSet(String exerciseDraftId) async {
    await addSet(exerciseDraftId, setType: SetType.warmup);
  }

  Future<void> updateSetType({
    required String exerciseDraftId,
    required String setId,
    required SetType setType,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises.map((e) {
      if (e.id != exerciseDraftId) return e;
      return e.copyWith(
        sets: e.sets.map((s) {
          if (s.id != setId) return s;
          return s.copyWith(setType: setType);
        }).toList(),
      );
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> updateSet({
    required String exerciseDraftId,
    required String setId,
    required SetPrescriptionDraft prescription,
  }) async {
    _logger.debug('updateSet — exercise: $exerciseDraftId, set: $setId');
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises.map((e) {
      if (e.id != exerciseDraftId) return e;
      return e.copyWith(
        sets: e.sets.map((s) => s.id == setId ? prescription : s).toList(),
      );
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> removeSet({
    required String exerciseDraftId,
    required String setId,
  }) async {
    _logger.debug('removeSet — exercise: $exerciseDraftId, set: $setId');
    final current = state.asData?.value;
    if (current == null) return;
    final exercises = current.draft.exercises.map((e) {
      if (e.id != exerciseDraftId) return e;
      return e.copyWith(
        sets: _reindexSets(e.sets.where((s) => s.id != setId).toList()),
      );
    }).toList();
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> saveWorkout() async {
    _logger.info('saveWorkout — start');
    final current = state.asData?.value;
    if (current == null) return;

    final normalizedDraft = _normalizeDraftForSave(current.draft);

    final validator = ref.read(AppProviders.workoutBuilderValidatorProvider);
    final errors = validator.validate(normalizedDraft);

    _logger.info(
      'saveWorkout — validation: ${errors.isEmpty ? "pass" : "fail"}, errors: ${errors.length}',
    );

    if (errors.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          phase: WorkoutBuilderPhase.editing,
          draft: normalizedDraft,
          validationErrors: errors,
        ),
      );
      return;
    }

    state = AsyncData(current.copyWith(phase: WorkoutBuilderPhase.saving));

    try {
      final saveUseCase = ref.read(
        AppProviders.saveWorkoutDraftUseCaseProvider,
      );
      final savedId = await saveUseCase.save(
        WorkoutBuilderSaveRequest(draft: normalizedDraft),
      );
      _logger.info('saveWorkout — success: $savedId');
      if (mode == WorkoutBuilderMode.create) {
        final loadUseCase = ref.read(
          AppProviders.loadWorkoutDraftUseCaseProvider,
        );
        final freshDraft = await loadUseCase.createEmptyDraft();
        state = AsyncData(
          current.copyWith(
            phase: WorkoutBuilderPhase.editing,
            draft: freshDraft,
            savedWorkoutId: null,
            isDirty: false,
          ),
        );
      } else {
        state = AsyncData(
          current.copyWith(
            phase: WorkoutBuilderPhase.editing,
            draft: normalizedDraft,
            savedWorkoutId: savedId,
            isDirty: false,
          ),
        );
      }
    } catch (e) {
      _logger.error('saveWorkout — failure', error: e);
      state = AsyncData(
        current.copyWith(
          phase: WorkoutBuilderPhase.failure,
          errorCode: AppErrorCodes.saveFailed,
          errorMessage: AppStrings.workoutSaveFailed,
        ),
      );
    }
  }

  // V1-M4-008 — superset / execution groups

  Future<void> createSuperset(List<String> selectedExerciseIds) async {
    _logger.debug('createSuperset — members: ${selectedExerciseIds.length}');
    final current = state.asData?.value;
    if (current == null || selectedExerciseIds.length < 2) return;

    final service = ref.read(
      AppProviders.workoutBuilderSupersetServiceProvider,
    );
    final groupId = _newId();
    final exercises = service.createSuperset(
      exercises: current.draft.exercises,
      selectedExerciseIds: selectedExerciseIds,
      groupId: groupId,
    );

    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> removeExerciseFromSuperset(String exerciseDraftId) async {
    final current = state.asData?.value;
    if (current == null) return;

    final service = ref.read(
      AppProviders.workoutBuilderSupersetServiceProvider,
    );
    final exercises = service.removeExerciseFromSuperset(
      exercises: current.draft.exercises,
      exerciseId: exerciseDraftId,
    );

    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> deleteSupersetGroup(String groupId) async {
    final current = state.asData?.value;
    if (current == null) return;

    final service = ref.read(
      AppProviders.workoutBuilderSupersetServiceProvider,
    );
    final exercises = service.deleteSupersetGroup(
      exercises: current.draft.exercises,
      groupId: groupId,
    );

    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> reorderWithinSuperset({
    required String exerciseDraftId,
    required int newOrder,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final exercise = current.draft.exercises.firstWhere(
      (e) => e.id == exerciseDraftId,
      orElse: () => current.draft.exercises.first,
    );
    final groupId = exercise.supersetGroupId;
    if (groupId == null) return;

    final service = ref.read(
      AppProviders.workoutBuilderSupersetServiceProvider,
    );
    final exercises = service.reorderWithinSuperset(
      exercises: current.draft.exercises,
      groupId: groupId,
      exerciseId: exerciseDraftId,
      newOrder: newOrder,
    );

    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(exercises: exercises),
        validationErrors: [],
        isDirty: true,
      ),
    );
  }

  Future<void> discardChanges() async {
    final current = state.asData?.value;
    if (current == null) return;
    final loadUseCase = ref.read(AppProviders.loadWorkoutDraftUseCaseProvider);
    if (mode == WorkoutBuilderMode.create) {
      final draft = await loadUseCase.createEmptyDraft();
      state = AsyncData(
        current.copyWith(draft: draft, isDirty: false, validationErrors: []),
      );
    } else if (savedWorkoutId != null) {
      final draft = await loadUseCase.loadForEdit(savedWorkoutId!);
      state = AsyncData(
        current.copyWith(draft: draft, isDirty: false, validationErrors: []),
      );
    }
  }

  void clearValidationErrors() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(validationErrors: []));
  }

  List<WorkoutBuilderExerciseDraft> _reindexExercises(
    List<WorkoutBuilderExerciseDraft> exercises,
  ) {
    return exercises.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();
  }

  List<SetPrescriptionDraft> _reindexSets(List<SetPrescriptionDraft> sets) {
    return sets.asMap().entries.map((entry) {
      return entry.value.copyWith(setIndex: entry.key);
    }).toList();
  }

  WorkoutBuilderDraft _normalizeDraftForSave(WorkoutBuilderDraft draft) {
    return draft.copyWith(
      exercises: draft.exercises.map(_normalizeExerciseForSave).toList(),
    );
  }

  WorkoutBuilderExerciseDraft _normalizeExerciseForSave(
    WorkoutBuilderExerciseDraft exercise,
  ) {
    final warmups = <SetPrescriptionDraft>[];
    final nonWarmups = <SetPrescriptionDraft>[];

    for (final set in exercise.sets) {
      if (set.setType == SetType.warmup) {
        warmups.add(set);
      } else {
        nonWarmups.add(set);
      }
    }

    return exercise.copyWith(sets: _reindexSets([...warmups, ...nonWarmups]));
  }

  String _newId() => const Uuid().v4();
}
