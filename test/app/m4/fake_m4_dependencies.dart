import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:drift/drift.dart' show Value;
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/lift_log/data/workout_history_repository.dart';
import 'package:aedify/features/lift_log/domain/workout_history_detail_view_data.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_execution/data/workout_session_repository.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_aggregate.dart';
import 'package:aedify/features/workout_execution/domain/workout_session_draft.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

class FakeNetworkStatus extends NetworkStatus {
  FakeNetworkStatus({this.isOnline = true}) : super();

  @override
  final bool isOnline;

  @override
  Future<bool> check() async => isOnline;
}

class FakeSavedWorkoutRepository implements SavedWorkoutRepository {
  final Map<String, SavedWorkoutAggregate> _items = {};

  void seed(SavedWorkoutAggregate aggregate) {
    _items[aggregate.savedWorkout.id] = aggregate;
  }

  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async => _items[id];

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    if (status != null) {
      return _items.values
          .where((a) => a.savedWorkout.status == status)
          .toList();
    }
    return _items.values.toList();
  }

  @override
  Future<String> saveSavedWorkout(SavedWorkoutDraft draft) async {
    final aggregate = SavedWorkoutAggregate(
      savedWorkout: SavedWorkout(
        id: draft.id,
        name: draft.name,
        source: 'manual',
        creationMethod: 'manual',
        status: 'active',
        goalTagsJson: '[]',
        equipmentJson: '[]',
        archivedAt: null,
        imported: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      exercises: [],
      sets: [],
    );
    _items[draft.id] = aggregate;
    return draft.id;
  }

  @override
  Future<void> archiveSavedWorkout(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> deleteSavedWorkout(String id) async {
    _items.remove(id);
  }
}

class FakeProgrammeRepository implements ProgrammeRepository {
  final Map<String, ProgrammeAggregate> _items = {};

  void seed(ProgrammeAggregate aggregate) {
    _items[aggregate.program.id] = aggregate;
  }

  @override
  Future<ProgrammeAggregate?> getProgramme(String id) async => _items[id];

  @override
  Future<List<ProgrammeAggregate>> listProgrammes({
    String? status,
    bool activeOnly = false,
  }) async {
    return _items.values.where((a) {
      if (activeOnly) return a.program.active;
      return true;
    }).toList();
  }

  @override
  Future<String> saveProgramme(ProgrammeDraft draft) async {
    final aggregate = ProgrammeAggregate(
      program: Program(
        id: draft.id,
        name: draft.name,
        source: 'manual',
        creationMethod: 'manual',
        status: 'draft',
        active: draft.active,
        goalTagsJson: '[]',
        equipmentJson: '[]',
        weeksTotal: draft.weeksTotal,
        daysPerWeek: draft.daysPerWeek,
        imported: false,
        sourceFileRetained: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      templates: [],
      weeks: [],
      workouts: [],
      exercises: [],
      sets: [],
      revisions: [],
    );
    _items[draft.id] = aggregate;
    return draft.id;
  }

  @override
  Future<void> archiveProgramme(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> deleteProgramme(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> activateProgramme(String id) async {
    final existing = _items[id];
    if (existing != null) {
      _items[id] = ProgrammeAggregate(
        program: existing.program.copyWith(active: true),
        templates: existing.templates,
        weeks: existing.weeks,
        workouts: existing.workouts,
        exercises: existing.exercises,
        sets: existing.sets,
        revisions: existing.revisions,
      );
    }
  }

  @override
  Future<void> deactivateProgramme(String id) async {
    final existing = _items[id];
    if (existing != null) {
      _items[id] = ProgrammeAggregate(
        program: existing.program.copyWith(active: false),
        templates: existing.templates,
        weeks: existing.weeks,
        workouts: existing.workouts,
        exercises: existing.exercises,
        sets: existing.sets,
        revisions: existing.revisions,
      );
    }
  }

  @override
  Future<List<ProgrammeExerciseDraft>> getTemplateExercises(
    String templateId,
  ) async {
    return [];
  }
}

class FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  WorkoutSessionAggregate? activeSession;
  final Map<String, WorkoutSessionAggregate> sessions = {};

  bool failOnComplete = false;

  @override
  Future<WorkoutSessionAggregate?> getActiveSession() async => activeSession;

  @override
  Future<WorkoutSessionAggregate?> getSession(String id) async =>
      sessions[id] ?? activeSession;

  @override
  Future<String> startSession(WorkoutSessionDraft draft) async {
    final aggregate = WorkoutSessionAggregate(
      session: WorkoutSession(
        id: draft.id,
        name: draft.name,
        source: 'standalone',
        programId: null,
        programWorkoutId: null,
        savedWorkoutId: null,
        startedAt: draft.startedAt,
        completedAt: null,
        durationSeconds: null,
        status: WorkoutSessionStatus.inProgress.dbValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      exercises: [],
      setLogs: [],
    );
    sessions[draft.id] = aggregate;
    activeSession = aggregate;
    return draft.id;
  }

  @override
  Future<void> saveSessionProgress(WorkoutSessionDraft draft) async {
    if (activeSession?.session.id == draft.id) {
      final existing = activeSession!;
      activeSession = WorkoutSessionAggregate(
        session: existing.session.copyWith(
          name: draft.name,
          updatedAt: DateTime.now(),
        ),
        exercises: existing.exercises,
        setLogs: existing.setLogs,
      );
      sessions[draft.id] = activeSession!;
    }
  }

  @override
  Future<void> completeSession({
    required String id,
    required DateTime completedAt,
    required int durationSeconds,
  }) async {
    if (failOnComplete) {
      throw Exception('Injected completion failure');
    }
    final existing = sessions[id] ?? activeSession;
    if (existing != null) {
      final completed = WorkoutSessionAggregate(
        session: existing.session.copyWith(
          completedAt: Value(completedAt),
          durationSeconds: Value(durationSeconds),
          status: 'completed',
          updatedAt: DateTime.now(),
        ),
        exercises: existing.exercises,
        setLogs: existing.setLogs,
      );
      sessions[id] = completed;
      activeSession = null;
    }
  }

  @override
  Future<void> abandonSession(String id) async {
    if (activeSession?.session.id == id) {
      activeSession = null;
    }
  }

  @override
  Future<void> deleteInProgressSession(String id) async {
    sessions.remove(id);
    if (activeSession?.session.id == id) {
      activeSession = null;
    }
  }
}

class FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  final List<WorkoutHistoryListItem> items = [];
  final Map<String, WorkoutHistoryDetailViewData> details = {};

  @override
  Future<List<WorkoutHistoryListItem>> listCompletedSessions() async => items;

  @override
  Future<WorkoutHistoryDetailViewData?> getSessionDetail(
    String sessionId,
  ) async => details[sessionId];

  void seedCompletedSession({
    required String sessionId,
    required String name,
    required SessionSource source,
    required DateTime startedAt,
    required DateTime completedAt,
    int durationSeconds = 3600,
    List<WorkoutHistoryExerciseItem> exercises = const [],
  }) {
    items.add(
      WorkoutHistoryListItem(
        sessionId: sessionId,
        name: name,
        source: source,
        completedAt: completedAt,
        durationSeconds: durationSeconds,
        exerciseCount: exercises.length,
      ),
    );
    details[sessionId] = WorkoutHistoryDetailViewData(
      sessionId: sessionId,
      name: name,
      source: source,
      startedAt: startedAt,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      exercises: exercises,
    );
  }
}

class FakeExerciseRepository implements ExerciseRepository {
  final List<ExerciseListItem> searchResults = [];
  final List<ExerciseListItem> customExercises = [];
  bool failOnCreateCustom = false;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async => searchResults;

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    return null;
  }

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {}

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {}

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => customExercises;

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async {
    return null;
  }

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async {
    if (failOnCreateCustom) throw Exception('Injected failure');
    final id = DateTime.now().millisecondsSinceEpoch;
    customExercises.add(
      ExerciseListItem(
        id: id,
        name: seed.name,
        difficulty: ExerciseDifficulty.beginner,
        muscleGroups: {BodymapBucket.chest},
        modality: ExerciseModality.strength,
        equipment: EquipmentTag.other,
        isFavorite: false,
        isSubstitutedOut: false,
        isCustom: true,
      ),
    );
    return id;
  }

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {
    customExercises.removeWhere((e) => e.id == exerciseId);
  }
}
