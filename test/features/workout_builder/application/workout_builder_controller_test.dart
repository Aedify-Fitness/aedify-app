import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSavedWorkoutRepository implements SavedWorkoutRepository {
  _FakeSavedWorkoutRepository({this.shouldThrowOnGet = false, this.aggregate});

  final bool shouldThrowOnGet;
  final SavedWorkoutAggregate? aggregate;

  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async {
    if (shouldThrowOnGet) {
      throw Exception('Database error');
    }
    return aggregate;
  }

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    return aggregate != null ? [aggregate!] : [];
  }

  @override
  Future<String> saveSavedWorkout(dynamic draft) async {
    return aggregate?.savedWorkout.id ?? 'saved-id';
  }

  @override
  Future<void> archiveSavedWorkout(String id) async {}

  @override
  Future<void> deleteSavedWorkout(String id) async {}
}

void main() {
  group('WorkoutBuilderController (create mode)', () {
    ProviderContainer createContainer({bool shouldThrowOnGet = false}) {
      return ProviderContainer(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) =>
                _FakeSavedWorkoutRepository(shouldThrowOnGet: shouldThrowOnGet),
          ),
        ],
      );
    }

    test('initial state is editing with empty draft in create mode', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      final state = await controller.future;

      expect(state.phase, equals(WorkoutBuilderPhase.editing));
      expect(state.mode, equals(WorkoutBuilderMode.create));
      expect(state.draft.name, isEmpty);
      expect(state.draft.exercises, isEmpty);
      expect(state.isDirty, isFalse);
      expect(state.validationErrors, isEmpty);
    });

    test('renameWorkout updates draft name and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.renameWorkout('Push Day');

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );

      expect(state.asData?.value.draft.name, equals('Push Day'));
      expect(state.asData?.value.isDirty, isTrue);
    });

    test('addExercise adds exercise with one default set', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Bench Press',
          modality: 'strength',
        ),
      );

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );

      expect(state.asData?.value.draft.exercises.length, equals(1));
      expect(
        state.asData?.value.draft.exercises.first.exercise.name,
        equals('Bench Press'),
      );
      expect(state.asData?.value.draft.exercises.first.sets.length, equals(1));
      expect(
        state.asData?.value.draft.exercises.first.sets.first.setType,
        equals(SetType.working),
      );
      expect(state.asData?.value.isDirty, isTrue);
    });

    test('removeExercise removes exercise from draft', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Squat',
          modality: 'strength',
        ),
      );
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 2,
          name: 'Press',
          modality: 'strength',
        ),
      );

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;

      await controller.removeExercise(exerciseId);

      final updatedState = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );

      expect(updatedState.asData?.value.draft.exercises.length, equals(1));
      expect(
        updatedState.asData?.value.draft.exercises.first.exercise.name,
        equals('Press'),
      );
    });

    test('addSet adds a set to the specified exercise', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'DL',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;

      expect(state.asData!.value.draft.exercises.first.sets.length, equals(1));

      await controller.addSet(exerciseId);

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      expect(state.asData!.value.draft.exercises.first.sets.length, equals(2));
    });

    test('duplicateExercise creates a copy after the original', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Curl',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;

      await controller.duplicateExercise(exerciseId);

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      expect(state.asData!.value.draft.exercises.length, equals(2));
      expect(
        state.asData!.value.draft.exercises[0].exercise.name,
        equals('Curl'),
      );
      expect(
        state.asData!.value.draft.exercises[1].exercise.name,
        equals('Curl'),
      );
      expect(
        state.asData!.value.draft.exercises[0].id,
        isNot(state.asData!.value.draft.exercises[1].id),
      );
    });

    test(
      'saveWorkout with errors sets validation errors without saving',
      () async {
        final container = createContainer();
        final controller = container.read(
          AppProviders.workoutBuilderControllerProvider((
            mode: WorkoutBuilderMode.create,
            savedWorkoutId: null,
          )).notifier,
        );

        await controller.future;

        // Save with empty name and no exercises — should fail validation
        await controller.saveWorkout();

        final state = container.read(
          AppProviders.workoutBuilderControllerProvider((
            mode: WorkoutBuilderMode.create,
            savedWorkoutId: null,
          )),
        );

        expect(state.asData?.value.hasValidationErrors, isTrue);
        expect(state.asData?.value.phase, equals(WorkoutBuilderPhase.editing));
      },
    );

    test('discardChanges resets draft to empty in create mode', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.renameWorkout('Should not persist');
      await controller.discardChanges();

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );

      expect(state.asData!.value.draft.name, isEmpty);
      expect(state.asData!.value.isDirty, isFalse);
    });

    test('reorderExercises changes exercise order', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(exerciseId: 1, name: 'A', modality: 'strength'),
      );
      await controller.addExercise(
        const ExerciseReference(exerciseId: 2, name: 'B', modality: 'strength'),
      );

      // Move A from index 0 to index 1
      await controller.reorderExercises(0, 1);

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );

      expect(state.asData!.value.draft.exercises[0].exercise.name, equals('B'));
      expect(state.asData!.value.draft.exercises[1].exercise.name, equals('A'));
    });

    test('addWarmupSet adds a set with SetType.warmup', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Bench Press',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;

      expect(state.asData!.value.draft.exercises.first.sets.length, equals(1));

      await controller.addWarmupSet(exerciseId);

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final sets = state.asData!.value.draft.exercises.first.sets;
      expect(sets.length, equals(2));
      expect(sets.last.setType, equals(SetType.warmup));
      expect(sets.first.setType, equals(SetType.working));
    });

    test('updateSetType changes set type of a set', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Squat',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;
      final setId = state.asData!.value.draft.exercises.first.sets.first.id;

      expect(
        state.asData!.value.draft.exercises.first.sets.first.setType,
        equals(SetType.working),
      );

      await controller.updateSetType(
        exerciseDraftId: exerciseId,
        setId: setId,
        setType: SetType.warmup,
      );

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      expect(
        state.asData!.value.draft.exercises.first.sets.first.setType,
        equals(SetType.warmup),
      );
    });

    test('addSet with SetType.warmup creates warmup set', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'DL',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;

      await controller.addSet(exerciseId, setType: SetType.warmup);

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final sets = state.asData!.value.draft.exercises.first.sets;
      expect(sets.length, equals(2));
      expect(sets.last.setType, equals(SetType.warmup));
    });

    test('warmup set survives save mapping (roundtrip)', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )).notifier,
      );

      await controller.future;
      await controller.renameWorkout('Test Warmup');
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Press',
          modality: 'strength',
        ),
      );

      var state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final exerciseId = state.asData!.value.draft.exercises.first.id;
      await controller.addWarmupSet(exerciseId);

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      final updatedSets = state.asData!.value.draft.exercises.first.sets;

      await controller.updateSet(
        exerciseDraftId: exerciseId,
        setId: updatedSets.first.id,
        prescription: updatedSets.first.copyWith(prescribedWeightKg: 40),
      );
      await controller.updateSet(
        exerciseDraftId: exerciseId,
        setId: updatedSets.last.id,
        prescription: updatedSets.last.copyWith(prescribedWeightKg: 20),
      );

      await controller.saveWorkout();

      state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.create,
          savedWorkoutId: null,
        )),
      );
      expect(state.asData?.value.isDirty, isFalse);
      expect(state.asData?.value.savedWorkoutId, isNotNull);
    });
  });

  group('WorkoutBuilderController (edit mode)', () {
    test('loads aggregate and returns editing state in edit mode', () async {
      final t = DateTime(2025, 1, 1);
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: SavedWorkout(
          id: 'w1',
          name: 'My Saved Workout',
          source: 'manual',
          creationMethod: 'manual',
          status: 'active',
          goalTagsJson: '[]',
          equipmentJson: '[]',
          imported: false,
          createdAt: t,
          updatedAt: t,
        ),
        exercises: [
          SavedWorkoutExercise(
            id: 'ex1',
            savedWorkoutId: 'w1',
            exerciseId: 1,
            sortOrder: 0,
            exerciseRef: 'Bench Press',
            createdAt: t,
          ),
        ],
        sets: [
          SavedWorkoutExerciseSet(
            id: 's1',

            savedWorkoutExerciseId: 'ex1',
            setIndex: 0,
            setType: SetType.working.dbValue,
            prescribedRepsMin: 8,
            prescribedWeightKg: 60.0,
            isCalibrationEstimate: false,
            createdAt: t,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) => _FakeSavedWorkoutRepository(aggregate: aggregate),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.edit,
          savedWorkoutId: 'w1',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.mode, equals(WorkoutBuilderMode.edit));
      expect(state.phase, equals(WorkoutBuilderPhase.editing));
      expect(state.draft.name, equals('My Saved Workout'));
      expect(state.draft.exercises.length, equals(1));
      expect(state.draft.exercises.first.sets.length, equals(1));
      expect(state.isDirty, isFalse);
    });

    test('load, edit, and save round-trips through the controller', () async {
      final t = DateTime(2025, 1, 1);
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: SavedWorkout(
          id: 'w1',
          name: 'Original',
          source: 'manual',
          creationMethod: 'manual',
          status: 'active',
          goalTagsJson: '[]',
          equipmentJson: '[]',
          imported: false,
          createdAt: t,
          updatedAt: t,
        ),
        exercises: [],
        sets: [],
      );

      final container = ProviderContainer(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) => _FakeSavedWorkoutRepository(aggregate: aggregate),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.edit,
          savedWorkoutId: 'w1',
        )).notifier,
      );

      await controller.future;
      await controller.renameWorkout('Renamed');
      await controller.addExercise(
        const ExerciseReference(
          exerciseId: 1,
          name: 'Squat',
          modality: 'strength',
        ),
      );

      final state = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.edit,
          savedWorkoutId: 'w1',
        )),
      );
      expect(state.asData?.value.draft.name, equals('Renamed'));
      expect(state.asData?.value.draft.exercises.length, equals(1));
      expect(state.asData?.value.isDirty, isTrue);
    });

    test('surfaces error when repository throws', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.savedWorkoutRepositoryProvider.overrideWith(
            (ref) => _FakeSavedWorkoutRepository(shouldThrowOnGet: true),
          ),
        ],
      );

      final controller = container.read(
        AppProviders.workoutBuilderControllerProvider((
          mode: WorkoutBuilderMode.edit,
          savedWorkoutId: 'nonexistent',
        )).notifier,
      );

      final state = await controller.future;

      expect(state.mode, equals(WorkoutBuilderMode.edit));
      expect(state.phase, equals(WorkoutBuilderPhase.failure));
      expect(state.errorCode, equals('load_failed'));
    });
  });
}
