import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/programmes/application/saved_workout_to_template_converter.dart';

SavedWorkout _fakeSavedWorkout() {
  return SavedWorkout(
    id: 'sw-1',
    name: 'Upper Body A',
    description: 'A great upper body workout',
    source: 'manual',
    creationMethod: 'manual',
    status: 'active',
    estimatedDurationMinutes: 45,
    goalTagsJson: '[]',
    equipmentJson: '[]',
    imported: false,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );
}

SavedWorkoutExercise _fakeExercise({
  String id = 'ex-1',
  int exerciseId = 1,
  int sortOrder = 0,
  String? supersetGroupId,
  int? supersetOrder,
}) {
  return SavedWorkoutExercise(
    id: id,
    savedWorkoutId: 'sw-1',
    exerciseId: exerciseId,
    sortOrder: sortOrder,
    supersetGroupId: supersetGroupId,
    supersetOrder: supersetOrder,
    exerciseRef: 'Bench Press',
    createdAt: DateTime(2025),
  );
}

SavedWorkoutExerciseSet _fakeSet({
  String id = 'set-1',
  String exerciseId = 'ex-1',
  int setIndex = 0,
  String setType = 'working',
  int prescribedRepsExact = 10,
}) {
  return SavedWorkoutExerciseSet(
    id: id,
    savedWorkoutExerciseId: exerciseId,
    setIndex: setIndex,
    setType: setType,
    prescribedRepsExact: prescribedRepsExact,
    isCalibrationEstimate: false,
    createdAt: DateTime(2025),
  );
}

void main() {
  group('SavedWorkoutToTemplateConverter', () {
    const converter = SavedWorkoutToTemplateConverter();

    test('converts name and description', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [],
        sets: [],
      );
      final template = converter.convert(aggregate);

      expect(template.name, 'Upper Body A');
      expect(template.description, 'A great upper body workout');
      expect(template.estimatedDurationMinutes, 45);
    });

    test('generates fresh IDs for template', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [],
        sets: [],
      );
      final template = converter.convert(aggregate);

      expect(template.id, isNotEmpty);
      expect(template.templateKey, isNotEmpty);
      expect(template.id, isNot(equals(template.templateKey)));
      expect(template.id, isNot(equals('sw-1')));
    });

    test('converts exercises preserving sort order', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [
          _fakeExercise(id: 'ex-1', exerciseId: 1, sortOrder: 0),
          _fakeExercise(id: 'ex-2', exerciseId: 2, sortOrder: 1),
        ],
        sets: [
          _fakeSet(id: 's1', exerciseId: 'ex-1'),
          _fakeSet(id: 's2', exerciseId: 'ex-2'),
        ],
      );
      final template = converter.convert(aggregate);

      expect(template.exercises.length, 2);
      expect(template.exercises[0].exerciseId, 1);
      expect(template.exercises[0].sortOrder, 0);
      expect(template.exercises[1].exerciseId, 2);
      expect(template.exercises[1].sortOrder, 1);
    });

    test('converts sets with correct exercise mapping', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [_fakeExercise(id: 'ex-1', exerciseId: 1)],
        sets: [
          _fakeSet(
            id: 's1',
            exerciseId: 'ex-1',
            setIndex: 0,
            setType: 'warmup',
            prescribedRepsExact: 8,
          ),
          _fakeSet(
            id: 's2',
            exerciseId: 'ex-1',
            setIndex: 1,
            setType: 'working',
            prescribedRepsExact: 10,
          ),
        ],
      );
      final template = converter.convert(aggregate);

      expect(template.exercises.length, 1);
      expect(template.exercises[0].sets.length, 2);
      expect(template.exercises[0].sets[0].setIndex, 0);
      expect(template.exercises[0].sets[0].setType.name, 'warmup');
      expect(template.exercises[0].sets[0].prescribedRepsExact, 8);
      expect(template.exercises[0].sets[1].setIndex, 1);
      expect(template.exercises[0].sets[1].setType.name, 'working');
      expect(template.exercises[0].sets[1].prescribedRepsExact, 10);
    });

    test('generates fresh IDs for exercises and sets', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [_fakeExercise(id: 'ex-1')],
        sets: [_fakeSet(id: 's1', exerciseId: 'ex-1')],
      );
      final template = converter.convert(aggregate);

      final ex = template.exercises[0];
      expect(ex.id, isNot(equals('ex-1')));
      expect(ex.sets[0].id, isNot(equals('s1')));
    });

    test('preserves superset grouping on exercises', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [
          _fakeExercise(
            id: 'ex-1',
            exerciseId: 1,
            sortOrder: 0,
            supersetGroupId: 'group-1',
            supersetOrder: 0,
          ),
          _fakeExercise(
            id: 'ex-2',
            exerciseId: 2,
            sortOrder: 1,
            supersetGroupId: 'group-1',
            supersetOrder: 1,
          ),
        ],
        sets: [
          _fakeSet(exerciseId: 'ex-1'),
          _fakeSet(exerciseId: 'ex-2'),
        ],
      );
      final template = converter.convert(aggregate);

      expect(template.exercises[0].supersetGroupId, 'group-1');
      expect(template.exercises[0].supersetOrder, 0);
      expect(template.exercises[1].supersetGroupId, 'group-1');
      expect(template.exercises[1].supersetOrder, 1);
    });

    test('handles empty exercises gracefully', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [],
        sets: [],
      );
      final template = converter.convert(aggregate);

      expect(template.exercises, isEmpty);
    });

    test('filters sets correctly per exercise', () {
      final aggregate = SavedWorkoutAggregate(
        savedWorkout: _fakeSavedWorkout(),
        exercises: [
          _fakeExercise(id: 'ex-1', exerciseId: 1),
          _fakeExercise(id: 'ex-2', exerciseId: 2),
        ],
        sets: [
          _fakeSet(id: 's1', exerciseId: 'ex-1', setIndex: 0),
          _fakeSet(id: 's2', exerciseId: 'ex-1', setIndex: 1),
          _fakeSet(id: 's3', exerciseId: 'ex-2', setIndex: 0),
        ],
      );
      final template = converter.convert(aggregate);

      expect(template.exercises[0].sets.length, 2);
      expect(template.exercises[1].sets.length, 1);
    });
  });
}
