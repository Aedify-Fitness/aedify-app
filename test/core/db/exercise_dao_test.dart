import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseDao candidate engine', () {
    late AppDatabase db;
    late ExerciseDao dao;

    Future<void> seedExercise({
      required int id,
      required String name,
      bool isCustom = false,
      bool deleted = false,
    }) async {
      await dao.insertExercisesBulk([
        ExercisesCompanion(
          id: Value(id),
          name: Value(name),
          nameNormalized: Value(name.toLowerCase()),
          source: Value(isCustom ? 'user' : 'musclewiki'),
          primaryMusclesJson: Value(json.encode(['Test'])),
          muscleGroupsJson: Value(json.encode(['Test'])),
          modality: const Value('strength'),
          equipment: const Value('barbell'),
          gripsJson: Value(json.encode(['none'])),
          stepsJson: Value(json.encode(['Step 1'])),
          isCustom: Value(isCustom),
          deletedAt: deleted ? Value(DateTime.now()) : const Value(null),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      ]);
    }

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseDao(db);

      await seedExercise(id: 1, name: 'Bench Press');
      await seedExercise(id: 2, name: 'Squat');
      await seedExercise(id: 3, name: 'Custom Exercise', isCustom: true);
      await seedExercise(id: 4, name: 'Deleted Exercise', deleted: true);
    });

    tearDown(() {
      db.close();
    });

    test('returns source and custom exercises for candidate engine', () async {
      final results = await dao.getExercisesForCandidateEngine();
      expect(results.length, 3);
      final names = results.map((e) => e.name).toSet();
      expect(names, containsAll(['Bench Press', 'Squat', 'Custom Exercise']));
    });

    test('candidate source query excludes deleted rows', () async {
      final results = await dao.getExercisesForCandidateEngine();
      final names = results.map((e) => e.name).toSet();
      expect(names, isNot(contains('Deleted Exercise')));
    });

    test(
      'excludes custom exercises when includeCustomExercises is false',
      () async {
        final results = await dao.getExercisesForCandidateEngine(
          includeCustomExercises: false,
        );
        expect(results.length, 2);
        final names = results.map((e) => e.name).toSet();
        expect(names, containsAll(['Bench Press', 'Squat']));
        expect(names, isNot(contains('Custom Exercise')));
      },
    );
  });

  group('ExerciseDao custom exercise CRUD', () {
    late AppDatabase db;
    late ExerciseDao dao;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseDao(db);
    });

    tearDown(() {
      db.close();
    });

    Future<void> insertSourceExercise(int id, String name) async {
      await dao.insertExercisesBulk([
        ExercisesCompanion(
          id: Value(id),
          name: Value(name),
          nameNormalized: Value(name.toLowerCase()),
          source: const Value('musclewiki'),
          primaryMusclesJson: Value(json.encode(['Test'])),
          muscleGroupsJson: Value(json.encode(['Test'])),
          modality: const Value('strength'),
          equipment: const Value('barbell'),
          gripsJson: Value(json.encode(['none'])),
          stepsJson: Value(json.encode(['Step 1'])),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      ]);
    }

    Future<void> insertCustomExercise({
      required int id,
      required String name,
      String? uuid,
    }) async {
      await dao.insertCustomExercise(
        ExercisesCompanion(
          id: Value(id),
          isCustom: const Value(true),
          customExerciseUuid: Value(
            uuid ?? 'ce-$id-${DateTime.now().millisecondsSinceEpoch}',
          ),
          source: const Value('custom'),
          name: Value(name),
          nameNormalized: Value(name.toLowerCase()),
          primaryMusclesJson: Value(json.encode(['Chest'])),
          muscleGroupsJson: Value(json.encode(['Chest'])),
          modality: const Value('strength'),
          equipment: const Value('dumbbell'),
          gripsJson: const Value('[]'),
          stepsJson: const Value('[]'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    test('insertCustomExercise stores custom exercise', () async {
      await insertCustomExercise(id: -1, name: 'My Custom', uuid: 'my-uuid');
      final all = await dao.getAllExercises();
      expect(all.length, 1);
      expect(all.first.name, 'My Custom');
      expect(all.first.isCustom, true);
      expect(all.first.customExerciseUuid, 'my-uuid');
      expect(all.first.source, 'custom');
    });

    test('getCustomExercises returns only custom exercises', () async {
      await insertSourceExercise(1, 'Bench Press');
      await insertCustomExercise(id: -1, name: 'Custom Curl');
      await insertCustomExercise(id: -2, name: 'Custom Press');

      final custom = await dao.getCustomExercises();
      expect(custom.length, 2);
      expect(custom.every((e) => e.isCustom), true);
    });

    test('getCustomExerciseByUuid returns correct record', () async {
      await insertCustomExercise(
        id: -1,
        name: 'Glute Bridge',
        uuid: 'uuid-abc',
      );
      await insertCustomExercise(
        id: -2,
        name: 'Other Custom',
        uuid: 'uuid-xyz',
      );

      final found = await dao.getCustomExerciseByUuid('uuid-abc');
      expect(found, isNotNull);
      expect(found!.name, 'Glute Bridge');

      final notFound = await dao.getCustomExerciseByUuid('nonexistent');
      expect(notFound, isNull);
    });

    test('getLowestExerciseId returns minimum id', () async {
      await insertSourceExercise(10, 'Exercise A');
      await insertSourceExercise(20, 'Exercise B');
      expect(await dao.getLowestExerciseId(), 10);
    });

    test('getLowestExerciseId works with negative custom ids', () async {
      await insertCustomExercise(id: -5, name: 'Custom 1');
      await insertSourceExercise(10, 'Source');
      await insertCustomExercise(id: -1, name: 'Custom 2');
      // Negative IDs are lower, so -5 should be the minimum
      expect(await dao.getLowestExerciseId(), -5);
    });

    test('getLowestExerciseId returns 0 when table is empty', () async {
      expect(await dao.getLowestExerciseId(), 0);
    });

    test('deleteCustomExerciseById removes only custom exercise', () async {
      await insertCustomExercise(id: -1, name: 'Custom 1');
      await insertSourceExercise(1, 'Bench Press');
      await insertCustomExercise(id: -2, name: 'Custom 2');

      await dao.deleteCustomExerciseById(-1);

      final remaining = await dao.getAllExercises();
      expect(remaining.length, 2);
      expect(remaining.every((e) => e.id != -1), true);
    });

    test('updateCustomExercise updates mutable fields', () async {
      await insertCustomExercise(id: -1, name: 'Old Name');
      await dao.updateCustomExercise(
        ExercisesCompanion(
          id: const Value(-1),
          name: const Value('New Name'),
          nameNormalized: const Value('new name'),
          modality: const Value('hypertrophy'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updated = await dao.getExerciseById(-1);
      expect(updated, isNotNull);
      expect(updated!.name, 'New Name');
      expect(updated.modality, 'hypertrophy');
    });
  });
}
