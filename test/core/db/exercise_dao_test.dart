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
}
